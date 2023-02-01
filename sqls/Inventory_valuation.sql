select b.id, b.default_code,e.name as product_desc,c.name as location_name,d.name as serial_num,g.value_float as cost,a.quantity,f.name as categ from stock_quant a 
left join product_product b on a.product_id=b.id
left join product_template e on b.product_tmpl_id=e.id
left join stock_location c on a.location_id=c.id
left join stock_production_lot d on a.lot_id=d.id
left join product_category f on e.categ_id=f.id
inner join ir_property g on g.res_id = concat('product.product,',cast(b.id as text))
where c.usage = 'internal'