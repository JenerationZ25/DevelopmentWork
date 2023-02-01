
with 
user_id as 
(select a.id as userid ,b.name as user_name from res_users a inner join res_partner b on a.partner_id=b.id),
PO_stat as 
(    select case when b.cnt = 0 then 'yes' else 'no' end shipped,
    a.name
    from Purchase_Order a left join (
        select a.purchase_order_id, count(b.id) as cnt
        from purchase_order_stock_picking_rel a
            left join stock_picking b on a.stock_picking_id = b.id and b.state not in ('done', 'cancel')
        group by a.purchase_order_id
        )b on a.id = b.purchase_order_id),
PO_pay as 
(
select a.id,(sum(b.amount_total)-sum(b.amount_residual) )as Financial_paid_amount from purchase_order a 
left join account_move b on b.invoice_origin=a.name
where b.move_type='in_invoice' and (b.state ='posted') 
group by a.id
    )
select
a.id as PO_id,
a.name as PO_reference,
a.date_order as order_date,
case when h.days is null then a.date_order
else a.date_order + h.days * interval '1' day
end contractual_date,
--a.date_order + h.days * interval '1' day AS contractual_date,
a.Write_date as updated_date,
a.date_planned as scheduled_date,
a.due_date as due_date,
a.Amount_total as total_amount,
a.Amount_tax as taxed_amount,
a.Amount_untaxed as untaxed_amount,
a.Paid_amount as paid_amount,
a.unpaid_amount as unpaid_amount,
j.Financial_paid_amount as Paid_amount_AUD,
k.name as currency_rate,
case
when j.Financial_paid_amount =0 or a.Paid_amount =0 then 0
when a.Paid_amount <> 0 then a.Paid_amount/j.Financial_paid_amount
end currency,
case 
when  round(CAST(a.unpaid_amount AS DECIMAL),5) <=0 then 'Paid' 

Else 'Not Paid'
end payment,

a.state as Po_status,
a.partner_ref as vendor_reference,
a.expense_type as expense_type,
0 as receipt_count,
b.name as vendor_name,
c.name as requested_by,
d.user_name as created_by,
e.user_name as updated_by,
f.name as department,
g.shipped as Received,
h.days as payment_terms,
(case when a.purchase_type = 1 then 'Inventor' when a.purchase_type=2 then 'Capital' when a.purchase_type = 3 then 'Expense' else 'Not Specified' end) PurchaseType
from 
Purchase_Order a
left join res_partner b on a.partner_id=b.id
left join hr_employee c on a.requested_by=c.id
left join user_id d on a.create_uid=d.userid
left join user_id e on a.write_uid=e.userid
left join hr_department f on a.department_id=f.id
left join PO_stat g on a.name =g.name
left join account_payment_term_line h on h.payment_id=a.payment_term_id  and h.value='balance'
left join po_pay j on a.id=j.id
left join res_currency k on k.id=a.currency_id