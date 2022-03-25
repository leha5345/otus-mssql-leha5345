

select t.name as tablename, c.name as fieldname
from sys.columns c
join sys.tables t on t.object_id=c.object_id
where t.name='StockItems'
ORDER BY 2

select * 
	from Warehouse.StockItems
WHERE
	StockItemName LIKE '%urgent%'
	OR StockItemName LIKE 'Animal%'


	---------------