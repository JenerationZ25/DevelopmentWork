with 
user_id as 
(select a.id as userid ,b.name as user_name from res_users a inner join res_partner b on a.partner_id=b.id)

select 
a.id as MO_id,
a.name as MO_reference,
b.default_code as product_id,
h.name as Lot_serial,
a.product_qty,a.date_planned_start as planned_start_date,
a.date_planned_finished as planned_finished_date,
a.date_start as start_date,
a.date_finished as finished_date,
c.code as bom_name,
d.name as routing,
a.state as MO_status,
case 
when a.availability = 'assigned' then 'Available' 
when a.availability = 'partially_available' then 'Partially Available' 
when a.availability = 'none' then 'None' 
when a.availability = 'waiting' then 'Waiting' 
end Material_Availability,
e.user_name as created_by,
f.user_name as updated_by,
g.user_name as Responsible,
a.date_planned_start_wo as WO_planned_start_date,
a.date_planned_finished_wo as WO_planned_finished_date

from mrp_production a 
left join product_product b on a.product_id=b.id
left join mrp_bom c on a.bom_id=c.id
left join mrp_routing d on a.routing_id=d.id
left join user_id e on a.create_uid=e.userid
left join user_id f on a.write_uid=f.userid
left join user_id g on a.user_id=g.userid
left join stock_production_lot h on h.id= a.x_currentlot 
