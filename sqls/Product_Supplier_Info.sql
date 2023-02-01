select c.name,a.default_code,a.name,b.delay,b.min_qty,b.date_start,b.date_end,d.id from product_template a 
inner join product_supplierinfo b on a.id=b.product_tmpl_id
inner join res_partner c on c.id = b.name
inner join product_product d on a.id=d.product_tmpl_id