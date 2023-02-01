select b.name,a.name,a.rate,a.currency_id from res_currency_rate a  
inner join res_currency b on b.id=a.currency_id