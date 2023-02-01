with QC_State as 
(
select c.name as lot_name,b.lot_id as lotid,a.name as WO_name
,b.quality_state 
from mrp_workorder a 
inner join quality_check b on a.id=b.workorder_id
inner join stock_production_lot c on c.id= b.lot_id
where 
--b.lot_id=16980 and
  b.quality_state ='fail'
group by c.name,b.lot_id,a.name,b.quality_state ),

prod as 
(
select b.name as prod_name,b.default_code as prod_number ,a.id as prod_id from product_product a inner join product_template b 
on a.product_tmpl_id=b.id
)


select b.name as Work_Order, c.name as lot,d.name as Work_Center ,a.name as MO_id, b.duration as Real_Duration,b.state as Status
, 

case when e.quality_state ='fail' then 'Yes' end as QC_Fail,

case 
     when substring(d.name,1,6) = '[WC-SH' then 'Sensor Head'
when substring(d.name,1,7) = '[WC-SUB' then 'Sub Assem'
when substring(d.name,1,5) = '[WC-L' then 'Systems'
when substring(d.name,1,5) = '[WC-E' then 'Engine'
 end as Product_Type
,b.date_finished
,
extract(week  from b.date_finished) as Week,
extract(Year  from b.date_finished) as Year,
to_char(b.date_finished, 'Month') as Month,
f.prod_name,
f.prod_number


from mrp_production a
left  join mrp_workorder b  on b.production_id=a.id
inner join stock_production_lot c on c.id= a.x_currentlot
inner join mrp_workcenter d on b.workcenter_id=d.id
left join QC_State e on e.lotid =a.x_currentlot and b.name=e.WO_name
inner join prod f on f.prod_id=b.product_id
where b.state='done' 