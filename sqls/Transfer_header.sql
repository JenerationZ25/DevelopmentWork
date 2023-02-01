with transfer_amt as
(
select b.id,sum(c.amount_total) as amount from stock_move a 
inner join stock_picking b on b.id=a.picking_id
LEFT JOIN account_move c on a.id=c.stock_move_id 
group by b.id
)

select 
a.id as internal_transfer_id,
c.name as Operation_type,
a.name as Transfer_Reference,
a.Scheduled_Date as Scheduled_Date,
a.date_done as Effective_date,
a.create_date as Created_Date,
a.Write_date as updated_Date,
b.name as Back_order,
a.origin as Source_Document,
a.State as Transfer_State,
e.complete_name as source_location,
f.complete_name as destination_location,
cast(d.amount as DECIMAL) as transfer_amount
from stock_picking a 
left join stock_picking b on b.id=a.backorder_id
left join stock_picking_type c on c.id=a.picking_type_id
left join transfer_amt d on d.id=a.id
inner join stock_location e on e.id=a.location_id
inner join stock_location f on f.id=a.location_dest_id