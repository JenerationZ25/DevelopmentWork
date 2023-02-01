select a.name,a.quality_state,a.measure,a.measure_success,a.create_date,a.write_date,b.name as QCP,c.name as Transfer_ref,d.default_code as product_num,e.name as Lot_id,f.name as Work_Center,
g.name as Operation_Type,c.origin as PO_Num,i.name as Vendor,c.state as Transfer_State
from quality_check a 
left join quality_Point b on a.point_id=b.id
left join stock_picking c on a.picking_id=c.id
left join product_product d on a.product_id=d.id
left join stock_production_lot e on a.lot_id=e.id
left join mrp_workcenter f on a.workcenter_id=f.id
left join stock_picking_type g on c.picking_type_id=g.id
left join purchase_order h on c.origin = h.name
left join res_partner i on i.id=h.partner_id

