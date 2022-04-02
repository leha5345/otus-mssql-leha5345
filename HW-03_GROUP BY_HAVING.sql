
--1.
--Посчитать среднюю цену товара, общую сумму продажи по месяцам.

use [WideWorldImporters]
	select
		Sales.InvoiceLines.StockItemID
		,Sales.InvoiceLines.Description
		,MONTH.MONTH
		,AVG(Sales.InvoiceLines.UnitPrice) as UnitPrice
		,SUM(Sales.InvoiceLines.Quantity * Sales.InvoiceLines.UnitPrice) as AMOUNT
		from Sales.Invoices
		JOIN Sales.InvoiceLines		
			ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
		JOIN 
			(
				select Sales.Invoices.InvoiceID,concat(MONTH(Sales.Invoices.InvoiceDate),'.',YEAR(Sales.Invoices.InvoiceDate)) as MONTH from Sales.Invoices WHERE Sales.Invoices.IsCreditNote = 0
			) as MONTH
			ON MONTH.InvoiceID = Sales.Invoices.InvoiceID
	WHERE
		 Sales.Invoices.IsCreditNote = 0
	GROUP BY 
		Sales.InvoiceLines.StockItemID
		,Sales.InvoiceLines.Description
		,MONTH
	ORDER BY 1,3

--2.
--Отобразить все месяцы, где общая сумма продаж превысила 10 000
use [WideWorldImporters]
	select
		MONTH.MONTH
		,MONTH.YEAR
		,SUM(Sales.InvoiceLines.Quantity * Sales.InvoiceLines.UnitPrice) as AMOUNT
		from Sales.Invoices
		JOIN Sales.InvoiceLines		
			ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
		JOIN 
			(
				select 
					Sales.Invoices.InvoiceID,
					MONTH(Sales.Invoices.InvoiceDate) as MONTH,
					YEAR(Sales.Invoices.InvoiceDate) as YEAR 
				from Sales.Invoices 
				WHERE Sales.Invoices.IsCreditNote = 0
			) as MONTH
			ON MONTH.InvoiceID = Sales.Invoices.InvoiceID
	WHERE
		 Sales.Invoices.IsCreditNote = 0
	GROUP BY 
		MONTH.MONTH
		,MONTH.YEAR
	HAVING SUM(Sales.InvoiceLines.Quantity * Sales.InvoiceLines.UnitPrice) > 10000
	ORDER BY 2,1,3
	
--3.
--Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. 
--Группировка должна быть по году, месяцу, товару. 
--Опционально: Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж, то этот месяц также отображался бы в результатах, но там были нули.

use [WideWorldImporters]
	select top 1
		Sales.InvoiceLines.StockItemID
		,MONTH.MONTH
		,MONTH.YEAR
		,SUM(Sales.InvoiceLines.Quantity) as Qty
		,SUM(Sales.InvoiceLines.Quantity * Sales.InvoiceLines.UnitPrice) as AMOUNT
		from Sales.Invoices
		JOIN Sales.InvoiceLines		
			ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
		JOIN 
			(
				select 
					Sales.Invoices.InvoiceID,
					MONTH(Sales.Invoices.InvoiceDate) as MONTH,
					YEAR(Sales.Invoices.InvoiceDate) as YEAR 
				from Sales.Invoices 
				WHERE Sales.Invoices.IsCreditNote = 0
			) as MONTH
			ON MONTH.InvoiceID = Sales.Invoices.InvoiceID
	WHERE
		 Sales.Invoices.IsCreditNote = 0
	GROUP BY
		Sales.InvoiceLines.StockItemID
		,MONTH.MONTH
		,MONTH.YEAR
	HAVING SUM(Sales.InvoiceLines.Quantity) < 50
	order by 3,2

