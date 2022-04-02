
--1.
--��������� ������� ���� ������, ����� ����� ������� �� �������.

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
--���������� ��� ������, ��� ����� ����� ������ ��������� 10 000.
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
--������� ����� ������, ���� ������ ������� � ���������� ���������� �� �������, �� �������, ������� ������� ����� 50 �� � �����. 
--����������� ������ ���� �� ����, ������, ������. 
--�����������: �������� ������� 2-3 ���, ����� ���� � �����-�� ������ �� ���� ������, �� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.
--����������� ����� ��: 15.03.2022

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

