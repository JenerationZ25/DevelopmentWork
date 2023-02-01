from baraja_it_common.sharepoint import SharePointConnector
from baraja_it_common.etl import BarajaETL
from baraja_it_common.path_handler import PathHandler
import pandas as pd
from datetime import datetime, timedelta
import json
import os
import logging
# import logging.config
from baraja_it_common.bar_logging import BarLogging
_logger = logging.getLogger(__name__)


class OdooSharePointETL(BarajaETL):
    def transform_data(self, df):
        if 'lot_serial' in df.columns:
            df['lot_serial'] = df['lot_serial'].str.strip()
        return df

class TaskOdooSharepointETL:
    def __init__(self):
        self.odooSharePointETL = OdooSharePointETL()
        self.path_handler = PathHandler()
        self.sp = SharePointConnector()
        self.current_dir = os.path.dirname(os.path.realpath(__file__))

        # customize logging, logfile will saved in Logs/ folder
        self.bar_logging = BarLogging().set_bar_logging(script_dir=self.current_dir, logfile_relatvie_path='Logs/pipeline_odoo_etl_sharepoint.log')

    def etl_from_odoo_to_sharepoint(self):

        # reading model and view mapping from json configuration file
        model_view_config_filepath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config', 'datamart_model_view.json')
        model_view_config = None
        with open(model_view_config_filepath, 'r') as f:
            model_view_config = json.load(f)

        if model_view_config is not None:
            model_view_sql_mapping = []
            models_list = []
            for model in model_view_config:
                models_list.append(model)

            for model in models_list:
                views = model_view_config.get(model)
                for view in views:
                    sql_query = os.path.join(self.current_dir, 'sqls', view + '.sql')
                    _logger.info(f'current SQLs file is {sql_query}')

                    with open(sql_query, 'r') as query:
                        sql = query.read()

                        # create a mapping for each model, view with correspoing sql query
                        model_view_sql_mapping.append({'model': model, 'view': view, 'sql': sql})

            for element in model_view_sql_mapping:
                # ETL - Extract data
                df = self.odooSharePointETL.extract_data(element['sql'])

                # ETL - Transform data
                df = self.odooSharePointETL.transform_data(df)

                # ETL - Export data to csv file
                output_dir = self.path_handler.create_folder(self.current_dir, element['model'])
                filename = element['view'] + '.csv'
                output_file_path = self.path_handler.join_file_path(output_dir, filename)
                self.odooSharePointETL.export_data_to_csv(df, output_file_path)

                # ETL - Upload csv file to data mart which is sharepoint here
                remote_sp_dir = self.path_handler.join_folder("Data Mart", element['model'])
                self.odooSharePointETL.upload_to_datamart(self.sp, output_file_path, remote_sp_dir, filename)


    def export_difot(self):
        # ETL - Extract data
        csv_po_detail = self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'Purchase'), "PO_detail.csv")
        csv_po_header =self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'Purchase'), "PO_header.csv")
        csv_product_supplier = self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'Purchase'), "Product_Supplier_Info.csv")
        csv_transfer_detail = self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'Inventory'), "Transfer_detail.csv")
        csv_transfer_header = self.path_handler.join_file_path(self.path_handler.join_folder(self.current_dir, 'Inventory'), "Transfer_header.csv")

        # df_po_detail contains 1 po number, and the financial + order information
        df_po_header = pd.read_csv(csv_po_header)
        # df_po_detail contains 1 po line, product information, department, quantity per item, how many we've received
        df_po_detail = pd.read_csv(csv_po_detail)
        # df_product_supplier contains vendor - product - delay (lead time) per minimum quantity
        df_product_supplier = pd.read_csv(csv_product_supplier)
        # df_transfer_detail contains every time we receive goods, how much quantity (as an int transfer)
        df_transfer_detail = pd.read_csv(csv_transfer_detail)
        # df_transfer_header contains every time we receive goods, how much quantity (as an int transfer)
        df_transfer_header = pd.read_csv(csv_transfer_header)

        # for data transformation, and to plug into power BI, we need to populate a final df
        # the df should have the following info, so that we  can do sums, and the calculations on power bi, but we can still have granular info now:
        # po_ref, vendor, product, difot date, quantity ordered, quantity received before difot date, difot_score
        difot_df = pd.DataFrame(
            columns=['po_ref', 'vendor_name', 'product_reference', 'order_date', 'difot_date', 'order_qty',
                     'received_qty_before_difot', 'line_difot_score'])

        po_range = range(0, len(df_po_header))

        for i in po_range:
            # print i
            po_ref = df_po_header.iloc[i]['po_reference']

            # we also want to get the PO details
            # if the received_quantity = billed_quantity, then we can search the internal transfer lines
            # else, if we haven't received everything yet, then it could be an automatic 0, depending on the lead time

            # look at which POs have transfers associated
            # then get the transfer detail identifier - which internal transfer was it?
            df_transfer_header.loc[df_transfer_header['source_document'] == po_ref]['internal_transfer_id']

            product_df = pd.DataFrame(columns=list(df_transfer_detail))
            for index, row in df_transfer_header.loc[df_transfer_header['source_document'] == po_ref].iterrows():
                int_xfer_id = row['internal_transfer_id']
                # then find the row in the transfer_detail
                # get rid of the ones that aren't WH/IN,WH/INT are the transfers from stock > elsewhere in the company.
                # reserved_qty > 0 and done_qty = 0 means that transfer is yet to be completed
                # reserved_qty = 0 and done_qty > 0 means that transfer is complete
                rows_int_transfer_detail = df_transfer_detail.loc[
                    (df_transfer_detail['internal_transfer_id'] == int_xfer_id) & (
                        df_transfer_detail['transfer_name'].str.contains("WH/IN/"))]
                if len(rows_int_transfer_detail) > 0:
                    product_df = product_df.append(rows_int_transfer_detail, ignore_index=True)
            product_list = product_df['product_reference'].tolist()
            product_list = list(dict.fromkeys(product_list))  # get rid of duplicates
            # we want to check the lead time on the product_reference
            # get the vendor
            vendor_name = (df_po_header.loc[df_po_header['po_reference'] == po_ref]['vendor_name']).max()

            # we should add this all to a df with the columns:
            po_df = pd.DataFrame(columns=list(['name', 'default_code', 'delay', 'difot_date']))
            for index, row in df_po_detail.loc[df_po_detail['po_reference'] == po_ref].iterrows():
                product_reference = row['product_reference']
                # for each product, try find the product_reference & vendor match in df_product_supplier
                product_supplier_match = df_product_supplier[(df_product_supplier['name'].str.contains(vendor_name)) & (
                            df_product_supplier['default_code'] == product_reference)]
                # and get the lead time
                if len(product_supplier_match['delay']) > 0:
                    lead_time = product_supplier_match['delay'].tolist()[0]
                elif len(product_supplier_match['delay']) == 0:
                    #              print 'lead time was blank. set default to 28 days'
                    lead_time = 28
                    # make lead time + order_date a new date to verify against
                # get the order date
                order_date = datetime.strptime(
                    (df_po_header.loc[df_po_header['po_reference'] == po_ref]['order_date'].tolist()[0]),
                    '%Y-%m-%d %H:%M:%S.%f')
                # difot date is order date + lead time + 7 extra days (+- 7 days)
                difot_date = order_date + timedelta(days=(int(lead_time) + 7))
                # append to the po_df
                po_df.loc[len(po_df)] = [vendor_name, product_reference, lead_time, difot_date]

            # we can start doing checks to see if it passes difot or not
            # first, if on the PO it has not been finished yet and the date has passed (received_quantity < billed_quantity & difot_date has passed)
            try:
                # received_qty = df_po_detail.loc[df_po_detail['po_reference'] == po_ref]['received_quantity'].tolist()[0]
                order_qty = df_po_detail.loc[df_po_detail['po_reference'] == po_ref]['quantity'].tolist()[0]
            except IndexError:
                continue
            # this should be done PER PRODUCT
            po_difot_score = 0
            for product in product_list:
                # print product
                #            if isinstance(product, float):
                #       #        if np.isnan(product): #print 'Product was NaN, i.e. doesn\'t have a product number'
                if isinstance(product, str):
                    valid_product_count = 0
                    product_df['create_date'] = pd.to_datetime(
                        product_df['create_date'])  # change create_date column to timeseries
                    try:
                        difot_date = po_df.loc[po_df['default_code'] == product]['difot_date'].tolist()[0]
                    except IndexError:
                        continue
                    order_qty = df_po_detail.loc[
                        (df_po_detail['po_reference'] == po_ref) & (df_po_detail['product_reference'] == product)][
                        'quantity'].tolist()[0]
                    received_qty_before_difot = \
                    product_df[(product_df['product_reference'] == product) & (product_df['create_date'] < difot_date)][
                        'done_qty'].sum()
                    difot_capable = True
                    # if the difot date hasn't passed yet, and received_qty = order_qty, then difot has passed
                    if ((received_qty_before_difot == order_qty) and (difot_date > datetime.now())):
                        #                    print 'passed difot'
                        po_difot_score += 1
                        valid_product_count += 1
                    # if the difot date hasn't passed yet, and received_qty < order_qty, we can't make a judgement call yet
                    elif ((received_qty_before_difot < order_qty) and (difot_date > datetime.now())):
                        #                    print 'cant determine difot yet'
                        difot_capable = False
                    # if the difot date has passed, and received_qty = order_qty, then we now have to check from the internal transfer records
                    elif ((received_qty_before_difot <= order_qty) and (difot_date < datetime.now())):
                        #                    print 'look at records, partial or failed difot'
                        valid_product_count += 1
                        # do a date comparison and sum the ones we received before the difot date
                        # for this product-supplier match, get a score.
                        if order_qty != 0:
                            line_difot_score = (float(received_qty_before_difot) / order_qty)
                        else:
                            line_difot_score = 0
                        po_difot_score += line_difot_score

                    if (difot_capable):
                        # add to the difot_df
                        difot_df.loc[len(difot_df)] = [po_ref, vendor_name, product, order_date, difot_date, order_qty,
                                                       received_qty_before_difot, line_difot_score]

        # then per PO (& per supplier) we'll have a final score

        # ETL - Export data to csv file
        model = "DIFOT"
        difot_df = difot_df.dropna()
        output_dir = self.path_handler.create_folder(self.current_dir, 'DIFOT')
        filename = 'difot_data.csv'
        output_file_path = self.path_handler.join_file_path(output_dir, filename)
        self.odooSharePointETL.export_data_to_csv(difot_df, output_file_path)

        # ETL - Upload csv files to data mart which is shaprepoint here
        remote_sp_dir = self.path_handler.join_folder("Data Mart", model)
        self.odooSharePointETL.upload_to_datamart(self.sp, output_file_path, remote_sp_dir, filename)
        _logger.info("Finished DIFOT")


if __name__ == "__main__":
    task = TaskOdooSharepointETL()
    task.etl_from_odoo_to_sharepoint()
    task.export_difot()