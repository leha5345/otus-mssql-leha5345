

--ќписание/ѕошагова€ инструкци€ выполнени€ домашнего задани€:
--Ѕолее подробно задание описано в материалах в личном кабинете.
--Ќапишите выборки дл€ того, чтобы получить:



--1. ¬се товары, в названии которых есть "urgent" или название начинаетс€ с "Animal".
use [WideWorldImporters]
	select *
		from Warehouse.StockItems
	WHERE
		StockItemName LIKE '%urgent%'
		OR
		StockItemName LIKE 'Animal%'

--2. ѕоставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
use [WideWorldImporters]
	select 
		Purchasing.Suppliers.SupplierID
		, Purchasing.Suppliers.SupplierName
		, Purchasing.PurchaseOrders.PurchaseOrderID
		from Purchasing.Suppliers
		LEFT JOIN Purchasing.PurchaseOrders 
			ON Purchasing.Suppliers.SupplierID = Purchasing.PurchaseOrders.SupplierID
	WHERE
		Purchasing.PurchaseOrders.PurchaseOrderID Is NULL

--3. «аказы (Orders) с ценой товара (UnitPrice) более 100$ либо количеством единиц (Quantity) товара более 20 штуки присутствующей датой комплектации всего заказа (PickingCompletedWhen).
use [WideWorldImporters]
	select
		Sales.Orders.OrderID
		, Sales.OrderLines.UnitPrice
		, Sales.OrderLines.Quantity
		, Sales.Orders.PickingCompletedWhen
		from Sales.Orders
		LEFT JOIN Sales.OrderLines
			ON Sales.Orders.OrderID = Sales.OrderLines.OrderID
	
	WHERE
		Sales.OrderLines.UnitPrice > 100
UNION
	select
		Sales.Orders.OrderID
		, Sales.OrderLines.UnitPrice
		, Sales.OrderLines.Quantity
		, Sales.Orders.PickingCompletedWhen
		from Sales.Orders
		LEFT JOIN Sales.OrderLines
			ON Sales.Orders.OrderID = Sales.OrderLines.OrderID
	WHERE
		Sales.OrderLines.Quantity > 20
		AND
		Sales.Orders.PickingCompletedWhen <>''

--4. «аказы поставщикам (Purchasing.Suppliers), которые должны быть исполнены (ExpectedDeliveryDate) в €нваре 2013 года с доставкой "Air Freight" или 
--"Refrigerated Air Freight" (DeliveryMethodName) и которые исполнены (IsOrderFinalized).	
use [WideWorldImporters]
	select 
		Purchasing.Suppliers.SupplierID
		, Purchasing.Suppliers.SupplierName
		, Purchasing.PurchaseOrders.PurchaseOrderID
		, Purchasing.PurchaseOrders.ExpectedDeliveryDate
		, Application.DeliveryMethods.DeliveryMethodName
		from Purchasing.Suppliers
		LEFT JOIN Purchasing.PurchaseOrders 
			ON Purchasing.Suppliers.SupplierID				= Purchasing.PurchaseOrders.SupplierID
		LEFT JOIN Application.DeliveryMethods 
			ON Purchasing.PurchaseOrders.DeliveryMethodID	= Application.DeliveryMethods.DeliveryMethodID
	WHERE
		Purchasing.PurchaseOrders.ExpectedDeliveryDate BETWEEN '2013-01-01' AND '2013-01-31'
		AND
		Application.DeliveryMethods.DeliveryMethodName IN ('Air Freight','Refrigerated Air Freight')

-- 5. ƒес€ть последних продаж (по дате продажи) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson). —делать без подзапросов.
use [WideWorldImporters]
	select top 10
		Sales.Orders.OrderID
		, Sales.Orders.OrderDate
		, Sales.Customers.CustomerName
		, Application.People.FullName
		from Sales.Orders
		JOIN Sales.Customers
			ON Sales.Orders.CustomerID		= Sales.Customers.CustomerID
		JOIN Application.People
			ON Sales.Orders.ContactPersonID	= Application.People.PersonID
ORDER BY 2 DESC

--6. ¬се ид и имена клиентов и их контактные телефоны, которые покупали товар "Chocolate frogs 250g".
use [WideWorldImporters]
	select DISTINCT
		Sales.Customers.CustomerID
		, Sales.Customers.CustomerName
		, Sales.Customers.PhoneNumber
		from Sales.Orders
		JOIN Sales.OrderLines
			ON Sales.Orders.OrderID = Sales.OrderLines.OrderID
		JOIN Sales.Customers
			ON Sales.Orders.CustomerID		= Sales.Customers.CustomerID
	WHERE
		Sales.OrderLines.Description = 'Chocolate frogs 250g'
order by 1
