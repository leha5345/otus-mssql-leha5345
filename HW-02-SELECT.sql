

--��������/��������� ���������� ���������� ��������� �������:
--����� �������� ������� ������� � ���������� � ������ ��������.
--�������� ������� ��� ����, ����� ��������:



--1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
use [WideWorldImporters]
	select *
		from Warehouse.StockItems
	WHERE
		StockItemName LIKE '%urgent%'
		OR
		StockItemName LIKE 'Animal%'

--2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
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

--3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ ���� ����������� ������ (Quantity) ������ ����� 20 ����� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
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

--4. ������ ����������� (Purchasing.Suppliers), ������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ���� � ��������� "Air Freight" ��� 
--"Refrigerated Air Freight" (DeliveryMethodName) � ������� ��������� (IsOrderFinalized).	
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

-- 5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������, ������� ������� ����� (SalespersonPerson). ������� ��� �����������.
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

--6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� "Chocolate frogs 250g".
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
