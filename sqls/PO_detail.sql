WITH USER_ID AS 
(
   SELECT 
		a.id AS userid,
		b.name AS user_name 
   FROM res_users a 
   INNER JOIN res_partner b ON a.partner_id=b.id
)
SELECT 
	b.name AS PO_reference,
	j.name AS product_name,
	j.default_code AS product_reference,
	a.name as product_description,
	a.date_planned AS scheduled_date,
	a.create_date AS create_date,
	a.Write_date AS updated_date,
	d.name AS analytic_account,
	a.product_qty AS quantity,
	h.name AS product_category,
	a.qty_received AS received_quantity,
	a.qty_invoiced AS billed_quantity,
	a.price_unit AS unit_price,
	a.price_total AS total_price,
	a.price_subtotal AS subtotal_price,
	a.price_tax AS tax_price,
	e.user_name AS created_by,
	f.user_name AS updated_by,
	a.id AS po_line_id,
	b.id AS po_id,
	a.x_budget_id AS budget_id,
	a.id AS purchase_order_line_id,
	a.write_date AS purchase_order_line_write_date,
	b.id AS purchase_order_id,
	b.write_date AS purchase_order_write_date,
	c.id AS product_product_id,
	c.write_date AS product_product_write_date,
	d.id AS account_analytic_account_id,
	d.write_date AS account_analytic_account_write_date,
	j.id AS product_template_id,
	j.write_date AS product_template_write_date,
	h.id AS product_category_id,
	h.write_date AS product_category_write_date,
	l.name analytic_tag,
	a.product_description_variants as custom_description
FROM purchase_order_line a
INNER JOIN purchase_order b ON a.order_id=b.id
LEFT JOIN product_product c ON a.product_id=c.id
LEFT JOIN product_template j ON c.product_tmpl_id=j.id
LEFT JOIN account_analytic_account d ON a.account_analytic_id = d.id
LEFT JOIN user_id e ON a.create_uid=e.userid
LEFT JOIN user_id f ON a.write_uid=f.userid
LEFT JOIN product_category h ON j.categ_id=h.id 
LEFT JOIN account_analytic_tag_purchase_order_line_rel k on k.purchase_order_line_id = a.id
LEFT JOIN account_analytic_tag l on k.account_analytic_tag_id = l.id 