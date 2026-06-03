select db_name(database_id) as [Database Name]
, object_name(ddius.object_id) as [Table Name]
, i.name as [Index Name]
, ddius.*
from sys.dm_db_index_usage_stats as ddius
join sys.indexes as i on ddius.object_id = i.object_id and ddius.index_id = i.index_id
where database_id = db_id()
