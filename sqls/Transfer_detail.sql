	WITH ACCT_MOVE AS (
		SELECT a.id AS stock_mov_id, SUM(c.amount_total) AS amount from stock_move a 
		INNER JOIN stock_picking b ON b.id=a.picking_id
		LEFT JOIN account_move c ON a.id=c.stock_move_id 
		WHERE a.state = 'done' 
		group by a.id
	)
	SELECT 
		a.picking_id AS internal_transfer_id,
		a.move_id AS move_id,
		b.name AS transfer_name,
		c.name AS lot_serial,
		e.name AS product_name,
		j.name AS move_name,
		a.create_date AS create_date,
		a.write_date AS updated_date,
		g.complete_name AS full_source_location,
		g.name AS source_location,
		h.complete_name AS full_destination_location,
		h.name AS destination_location,
		d.default_code AS product_reference,
		a.product_uom_qty AS reserved_qty,
		a.qty_done AS done_qty,
		CAST(f.amount as DECIMAL) AS transfer_amount,
		j.product_qty,
		CASE 
			--when j.product_qty=0 THEN CAST(0 as INTEGER)
			WHEN f.amount is null THEN CAST(0 as DECIMAL)
			WHEN j.product_qty <> 0 THEN  CAST(f.amount*a.qty_done/j.product_qty as DECIMAL)
		END unit_transfer_amount,
		CASE
			WHEN h.complete_name LIKE '%%WH/Stock%%' THEN 'Stock'
			WHEN h.complete_name LIKE '%%Virtual Locations/Prod%%' THEN 'Production'
			WHEN h.complete_name LIKE '%%Quarantine%%' THEN 'Quarantine'
			WHEN h.complete_name LIKE '%%Customer%%' THEN 'Sale'
			WHEN UPPER(h.complete_name) LIKE '%%CHINA%%' THEN 'China'
			WHEN UPPER(h.complete_name) LIKE '%%US/Stock%%' THEN 'USA'
			WHEN h.complete_name LIKE '%%Marketing%%' THEN 'Marketing'
			WHEN h.complete_name LIKE '%%Scrap%%' THEN 'Scrap'
			WHEN h.complete_name LIKE '%%Input%%' THEN 'PO Receipt'
			WHEN g.complete_name LIKE '%%Input%%' AND (h.complete_name LIKE '%%Tec Dev%%' OR h.complete_name LIKE '%%Product Dev%%') THEN 'RnD Receipt from PO'
			WHEN g.complete_name LIKE '%%Stock%%' AND (h.complete_name LIKE '%%Tec Dev%%' OR h.complete_name LIKE '%%Product Dev%%') THEN 'RnD Receipt from Stock'
			WHEN g.complete_name LIKE '%%adjustment%%' AND (h.complete_name LIKE '%%Tec Dev%%' OR h.complete_name LIKE '%%Product Dev%%') THEN 'RnD Adjust In'
			WHEN h.complete_name LIKE '%%adjustment%%' AND (g.complete_name LIKE '%%Tec Dev%%' OR g.complete_name LIKE '%%Product Dev%%') THEN 'RnD Adjust Out'
			WHEN h.complete_name LIKE '%%adjustment%%' THEN 'Adjustment'
			WHEN h.complete_name LIKE '%%Vendor%%' THEN 'Returns'
			WHEN h.complete_name LIKE '%%NPI%%' THEN 'NPI'
		ELSE
		'Others'
		END transfer_State,
		a.x_budget_id AS budget_id,
		a.id AS stock_move_line_id,
		b.id AS stock_picking_id,
		c.id AS stock_production_lot_id,
		d.id AS product_product_id,
		e.id AS product_template_id,
		g.id AS stock_location_id,
		h.id AS stock_location_dest_id,
		j.id AS stock_move_id,
		a.write_date AS stock_move_line_write_date,
		b.write_date AS stock_picking_write_date,
		c.write_date AS stock_production_lot_write_date,
		d.write_date AS product_product_write_date,
		e.write_date AS product_template_write_date,
		g.write_date AS stock_location_write_date,
		h.write_date AS stock_location_dest_write_date,
		j.write_date AS stock_move_write_date,
		x.name AS analytic_account,
		l.name analytic_tag
	FROM stock_move_line a
	LEFT JOIN stock_picking b ON a.picking_id=b.id
	LEFT JOIN stock_production_lot c ON c.id= a.lot_id
	LEFT JOIN product_product d ON d.id=a.product_id
	LEFT JOIN product_template e ON d.product_tmpl_id=e.id
	INNER JOIN stock_location g ON g.id=a.location_id
	INNER JOIN stock_location h ON h.id=a.location_dest_id
	INNER JOIN stock_move j ON a.move_id=j.id
	LEFT JOIN acct_move f ON a.move_Id=f.stock_mov_id
	LEFT JOIN account_analytic_account x ON j.analytic_account_id = x.id														
	LEFT JOIN account_analytic_tag_stock_move_rel k on k.stock_move_id = a.move_id
LEFT JOIN account_analytic_tag l on k.account_analytic_tag_id = l.id  