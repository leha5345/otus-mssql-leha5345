/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
--  1) вложенный запрос

select 
	Application.People.PersonID,
	Application.People.FullName
	from Application.People 
WHERE Application.People.IsSalesPerson = 1
	AND Application.People.PersonID IN 
				(select SalespersonPersonID from Sales.Invoices WHERE Sales.Invoices.InvoiceDate <> '2015-07-04' GROUP BY SalespersonPersonID)
ORDER BY 1
--  2) через WITH 
;WITH SalesInvoicesCTE (SalespersonPersonID)
	AS (select SalespersonPersonID from Sales.Invoices WHERE Sales.Invoices.InvoiceDate <> '2015-07-04' GROUP BY SalespersonPersonID)
select 
	Application.People.PersonID,
	Application.People.FullName
	from Application.People 
	JOIN SalesInvoicesCTE 
		ON Application.People.PersonID = SalesInvoicesCTE.SalespersonPersonID
WHERE Application.People.IsSalesPerson = 1
ORDER BY 1
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
--  1) вложенный запрос
SELECT 
	Items.StockItemID, 
	Items.StockItemName, 
	(
	SELECT min(UnitPrice) 
		FROM Warehouse.StockItems 
	WHERE Warehouse.StockItems.StockItemID = Items.StockItemID
		AND Warehouse.StockItems.UnitPrice = Items.UnitPrice
	GROUP BY Warehouse.StockItems.StockItemID
	)
FROM Warehouse.StockItems as Items
ORDER BY 1

--  2) через WITH 
;WITH ItemsCTE (StockItemID, StockItemName, UnitPrice)
	AS (SELECT StockItemID, StockItemName, UnitPrice FROM Warehouse.StockItems)
select 
	ItemsCTE.StockItemID,
	ItemsCTE.StockItemName,
	(
	SELECT min(UnitPrice) 
		FROM Warehouse.StockItems 
	WHERE Warehouse.StockItems.StockItemID = ItemsCTE.StockItemID
		AND Warehouse.StockItems.UnitPrice = ItemsCTE.UnitPrice
	GROUP BY Warehouse.StockItems.StockItemID
	)
	from ItemsCTE
ORDER BY 1
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

--  1) вложенный запрос

select TOP 5 
	Sales.CustomerTransactions.CustomerID,
	(
		select MAX(TransactionAmount) 
			FROM Sales.CustomerTransactions as TR 
		WHERE TR.CustomerID = Sales.CustomerTransactions.CustomerID
			AND TR.TransactionAmount = Sales.CustomerTransactions.TransactionAmount
	)
	from Sales.CustomerTransactions 
ORDER BY 2 DESC


--  2) через WITH 
;WITH TRCTE (CustomerID,TransactionAmount) 
	AS (select CustomerID,TransactionAmount from Sales.CustomerTransactions)
select TOP 5
	TRCTE.CustomerID,
	(
		select MAX(TransactionAmount) 
			FROM Sales.CustomerTransactions as TR 
		WHERE TR.CustomerID = TRCTE.CustomerID
			AND TR.TransactionAmount = TRCTE.TransactionAmount
	)
	from TRCTE
ORDER BY 2 DESC
	

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

---- этом задании не написаны таблицы из которых надо брать данные поэтому я сам додумывал
--- например товары брать по продажам или по справочнику, упаковку заказов брать по накладным или заказам и с какой таблицы брать ид города

--  1) вложенный запрос
select TOP 3
	Sales.InvoiceLines.StockItemID,
	MAX(Sales.InvoiceLines.UnitPrice) as Price,
	Application.Cities.CityID,
	Application.Cities.CityName,
	Application.People.FullName
	from Sales.Invoices
		JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID			=  Sales.InvoiceLines.InvoiceID
		JOIN Application.People	ON Sales.Invoices.PackedByPersonID	= Application.People.PersonID
		JOIN Sales.Customers	ON Sales.Invoices.CustomerID		= Sales.Customers.CustomerID
		JOIN Application.Cities ON Sales.Customers.DeliveryCityID	= Application.Cities.CityID
GROUP BY 	Application.Cities.CityID,Application.Cities.CityName,Application.People.FullName, Sales.InvoiceLines.StockItemID
ORDER BY 2 DESC

--  2) через WITH 
;WITH MAXItemPriceCTE (StockItemID,UnitPrice,CityID,CityName,FullName)
	AS (
select 
	Sales.InvoiceLines.StockItemID,
	Sales.InvoiceLines.UnitPrice,
	Application.Cities.CityID,
	Application.Cities.CityName,
	Application.People.FullName
	from Sales.Invoices
		JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID			=  Sales.InvoiceLines.InvoiceID
		JOIN Application.People	ON Sales.Invoices.PackedByPersonID	= Application.People.PersonID
		JOIN Sales.Customers	ON Sales.Invoices.CustomerID		= Sales.Customers.CustomerID
		JOIN Application.Cities ON Sales.Customers.DeliveryCityID	= Application.Cities.CityID
		)
select TOP 3
	MAXItemPriceCTE.StockItemID,
	MAX(MAXItemPriceCTE.UnitPrice),
	MAXItemPriceCTE.CityID,
	MAXItemPriceCTE.CityName,
	MAXItemPriceCTE.FullName
	from MAXItemPriceCTE
GROUP BY 	MAXItemPriceCTE.CityID,MAXItemPriceCTE.CityName,MAXItemPriceCTE.FullName, MAXItemPriceCTE.StockItemID
ORDER BY 2 DESC
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: так как задание опциональное, т.е. можно не делать, я его не выполнял
