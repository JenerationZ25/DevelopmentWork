select b.default_code as serial_num, a.product_tmpl_id as bom_prod_id, a.code as bom_ref, a.id as bom_id, a.active,
c.id as bom_line_id, c.product_id, c.product_qty, d.default_code
from mrp_bom a
left join product_product b on a.product_tmpl_id = b.product_tmpl_id
left join mrp_bom_line c on a.id = c.bom_id
left join product_product d on c.product_id = d.id
where a.code not like '%%Inactive%%' and a.code not like '%%DO NOT USE%%' and a.active = true;