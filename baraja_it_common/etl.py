from .db import DWHConnection
from .sharepoint import SharePointConnector
import os
import logging

_logger = logging.getLogger(__name__)

class BarajaETL:
    def __init__(self):
        pass

    def extract_data(self, sql):
        '''
        Extract data from data lake with given sql query string
        :param sql: string
        :return: df: dataframe
        '''
        with DWHConnection() as dwh:
            df = dwh.fetch(sql)
            return df

    def transform_data(self, df):
        '''
        Transform dataframe
        :param df: dataframe
        :return: modified dataframe
        '''
        return df

    def export_data_to_csv(self, df, des_file_path):
        '''
        Export dataframe result to csv file
        :param df:  dataframe
        :param des_file_path: csv file saved path
        :return:
        '''
        df.to_csv(des_file_path, header=True, index=False, sep=',')
        _logger.info(f"Export csv file {des_file_path}")

    def upload_to_datamart(self, datamart, local_file_path, remote_sp_dir, filename):
        '''
        Upload file to datamart
        :param datamart: DataMart Object
        :return:
        '''
        datamart.upload(local_file_path, remote_sp_dir, filename)



