Select a.name,a.title,a.create_date,a.date_assign as Assigned_date,a.date_close as Close_date,a.write_date as Last_updated_date ,STRING_AGG (c.name, ';') tags  from quality_alert a 
inner join quality_alert_quality_tag_rel b on a.id=b.quality_alert_id
inner join quality_tag c on b.quality_tag_id = c.id
--where a.name ='QA00060'
group by a.name,a.title,a.create_date,a.date_assign,a.date_close,a.write_date