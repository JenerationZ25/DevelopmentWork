select 
case when substring(a.name,1,2)='DA' then substring(a.name,1,6) 
 when substring(a.name,1,3)='ECO' then substring(a.name,1,7) 
end as ECO ,
case when substring(a.name,1,2)='DA' then substring(a.name,9) 
 when substring(a.name,1,3)='ECO' then substring(a.name,9) 
 else a.name
end as Description
,b.name as stage,
a.type as ECO_on,
a.effectivity_date,
a.effectivity,
a.create_date,
a.write_date as Last_updated_Date
from mrp_eco a
inner join mrp_eco_stage b on stage_id=b.id