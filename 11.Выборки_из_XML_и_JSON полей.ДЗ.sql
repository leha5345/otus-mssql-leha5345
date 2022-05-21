
/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--Вариант OPENXML
DECLARE @xmlDoc  xml
	SELECT @xmlDoc = BulkColumn -- Считываем XML-файл в переменную
		FROM OPENROWSET (BULK 'E:\Леха\sql\StockItems.xml',SINGLE_CLOB) as data 
--SELECT @xmlDoc as [@xmlDoc] -- Проверяем, что в @xmlDoc
DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDoc
SELECT *
	FROM OPENXML(@docHandle, N'/StockItems/Item')
		WITH ( 
			 [SupplierID] nvarchar(10) 'SupplierID'
			,[UnitPackageID] int 'Package/UnitPackageID'
			,[OuterPackageID] int 'Package/OuterPackageID'
			,[QuantityPerOuter] int 'Package/QuantityPerOuter'
			,[TypicalWeightPerUnit] numeric (20,4) 'Package/TypicalWeightPerUnit'

			,[LeadTimeDays] int 'LeadTimeDays'
			,[IsChillerStock] int 'IsChillerStock'
			,[TaxRate] numeric (20,4) 'TaxRate'
			,[UnitPrice] numeric (20,4) 'UnitPrice'
			)

--Вариант XQuery-------------------------------------------------------------------------
DECLARE @xmlDoc2 xml
DECLARE @SupplierID nvarchar(10)
	SELECT @xmlDoc2 = BulkColumn -- Считываем XML-файл в переменную
		FROM OPENROWSET (BULK 'E:\Леха\sql\StockItems.xml',SINGLE_CLOB) as data 
-- вытащить строку
--  SET @SupplierID	= @xmlDoc2.value('(/StockItems/Item/SupplierID)[1]','nvarchar(10)')
--  select @SupplierID as SupplierID
-- или так: --  ,ltrim(@xmlDoc2.value('(/StockItems/Item/SupplierID)[1]', 'varchar(10)')) as [SupplierID2]
	SELECT 
		 xml.Doc2.value('(SupplierID)[1]','nvarchar(10)') as SupplierID
		,xml.Doc2.value('(Package/UnitPackageID)[1]','int') as UnitPackageID
		,xml.Doc2.value('(Package/OuterPackageID)[1]','int') as OuterPackageID
		,xml.Doc2.value('(Package/QuantityPerOuter)[1]','int') as QuantityPerOuter
		,xml.Doc2.value('(Package/TypicalWeightPerUnit)[1]','numeric(20,4)') as TypicalWeightPerUnit
		,xml.Doc2.value('(LeadTimeDays)[1]','int') as LeadTimeDays
		,xml.Doc2.value('(IsChillerStock)[1]','int') as IsChillerStock
		,xml.Doc2.value('(TaxRate)[1]','numeric(20,4)') as TaxRate
		,xml.Doc2.value('(UnitPrice)[1]','numeric(20,4)') as UnitPrice
		FROM @xmlDoc2.nodes(N'/StockItems/Item') as xml(Doc2)

/*

2. Выгрузить данные из таблицы StockItems в таблицу
Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
*/

select top 3
	'red shirt XML tag t-shirt (Black) 3XXL"' as [@Name],
	StockItemID as [SupplierID],
	UnitPackageID as [Package/UnitPackageID],
	OuterPackageID as [Package/OuterPackageID],
	QuantityPerOuter as [Package/QuantityPerOuter],
	TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	LeadTimeDays as [LeadTimeDays],
	IsChillerStock as [IsChillerStock],
	TaxRate as [TaxRate],
	UnitPrice as [UnitPrice]
	from Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems')




/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
select 
	StockItemID
	,StockItemName
	,JSON_VALUE(CustomFields,'$.CountryOfManufacture') as "CountryOfManufacture",*
from Warehouse.StockItems 

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле
*/


select
	StockItemID
--	,JSON_QUERY(CustomFields, '$.Tags') as Tags
--	,s.[key]
	,s.value as CustomFields_Vintage
from Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') as s
WHERE s.value = 'Vintage'
