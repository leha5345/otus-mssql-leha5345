/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "06 - Оконные функции".
Задания выполняются с использованием базы данных WideWorldImporters.
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
--я не понимаю суть задания, поэтому решил сделать по своему (суть же показать понимание темы лекции)
--показал в запросе по каждому клиенту помесячно нарастающий итог, тоже самое в следующем задании только через оконную функцию


;WITH Sales
	AS (

	select 
		Sales.Invoices.CustomerID		--код клиента
		,YEAR(Sales.Invoices.InvoiceDate)*100 + MONTH(Sales.Invoices.InvoiceDate) as Date
		,SUM(Sales.InvoiceLines.TaxAmount) as Amount	--сумма продаж
	from Sales.Invoices
	JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
	WHERE
		Sales.Invoices.InvoiceDate > '2015-01-01'
	GROUP BY 
	Sales.Invoices.CustomerID		--код клиента
	,YEAR(Sales.Invoices.InvoiceDate)*100 + MONTH(Sales.Invoices.InvoiceDate)
	)
select 
	Cur.CustomerID, 
	Cur.Date,
	Cur.Amount,
	(select SUM(Nxt.Amount) 
	from Sales as Nxt
	WHERE Cur.CustomerID = Nxt.CustomerID
		AND Cur.Date > = Nxt.Date) as Total
from Sales as Cur
ORDER BY 1,2,3




/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/



USE [WideWorldImporters]
GO
select 
	Sales.Invoices.CustomerID		--код клиента
	,YEAR(Sales.Invoices.InvoiceDate) as YEAR
	,MONTH(Sales.Invoices.InvoiceDate) as MONTH
	,SUM(Sales.InvoiceLines.TaxAmount)	as Amount --сумма продажи
	,SUM(SUM(Sales.InvoiceLines.TaxAmount)) OVER (PARTITION BY Sales.Invoices.CustomerID 
											ORDER BY YEAR(Sales.Invoices.InvoiceDate)
													,MONTH(Sales.Invoices.InvoiceDate) RANGE UNBOUNDED PRECEDING) as Total
from Sales.Invoices
JOIN Sales.InvoiceLines ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
WHERE
		Sales.Invoices.InvoiceDate > '2015-01-01'
GROUP BY 
	Sales.Invoices.CustomerID		--код клиента
	,YEAR(Sales.Invoices.InvoiceDate) 
	,MONTH(Sales.Invoices.InvoiceDate)
ORDER BY 1,2,3

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;WITH Sales
	AS (
		select 
			MONTH(Sales.Invoices.InvoiceDate) as MONTH
			,Sales.InvoiceLines.StockItemID -- код продукта
			,SUM(Sales.InvoiceLines.Quantity) TotalQty	-- количество
		FROM Sales.InvoiceLines
		JOIN Sales.Invoices ON Sales.Invoices.InvoiceID = Sales.InvoiceLines.InvoiceID
		WHERE
			Sales.Invoices.InvoiceDate BETWEEN '2016-01-01' AND '2016-12-31'
		GROUP BY MONTH(Sales.Invoices.InvoiceDate),Sales.InvoiceLines.StockItemID
		)

select 
	Lines.MONTH
	,Lines.StockItemID
	,Lines.TotalQTY
	from (
		select 
			Sales.StockItemID -- код продукта
			,Sales.MONTH
			,Sales.TotalQty	-- количество
			,ROW_NUMBER() OVER (PARTITION BY MONTH
								ORDER BY Sales.TotalQty desc) as Rn
		FROM Sales
		) as Lines
WHERE
	Lines.Rn IN (1,2)
ORDER BY 1,2


----------------------



/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
2 посчитайте общее количество товаров и выведете полем в этом же запросе
3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
5 предыдущий ид товара с тем же порядком отображения (по имени)
6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
7 сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select 
	St.StockItemID
	,St.Brand
	,St.StockItemName
	,St.StItem			-- первый символ в наименовании товара
	,St.UnitPrice
	,TypicalWeightPerUnit -- вес товара
	,ROW_NUMBER() OVER  (PARTITION BY St.StItem ORDER BY St.StockItemName)	--1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
	,SUM(St.QuantityPerOuter)	OVER() as TotalQty							--2 посчитайте общее количество товаров и выведете полем в этом же запросе
	,SUM(St.QuantityPerOuter)	OVER(PARTITION BY St.StItem) as TotalQty	--3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
	,LEAD(St.StockItemName)		OVER (ORDER BY St.StockItemName) as leadv	--4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
	,LAG(St.StockItemName)		OVER (ORDER BY St.StockItemName) as lagv	--5 предыдущий ид товара с тем же порядком отображения (по имени)
	,LAG(St.StockItemName,2,'No items')	OVER (ORDER BY St.StockItemName) as lagv_2	--6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"

from (
	select
		StockItemID			-- id товара
		,Brand				-- брэнд
		,StockItemName		-- название товара
		,LEFT(StockItemName,1)  as StItem
		,UnitPrice			-- цена
		,QuantityPerOuter	-- кол-во
		,TypicalWeightPerUnit -- вес товара

	from Warehouse.StockItems
	) as St
ORDER BY 3 -- отсортировал по имени товара для четвертого и пятого заданий

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/


select TOP(1) with ties
	Sales.Orders.OrderID
	,Sales.Orders.ContactPersonID
	,Application.People.FullName
	,Sales.Orders.CustomerID
	,CustPeople.FullName
	,Sales.Orders.OrderDate
	,Sales.OrderLines.Quantity
	,Sales.OrderLines.UnitPrice
	,(Sales.OrderLines.Quantity * Sales.OrderLines.UnitPrice) as AMOUNT
from Sales.Orders
	JOIN Application.People					ON Sales.Orders.ContactPersonID = Application.People.PersonID
	JOIN Application.People as CustPeople	ON Sales.Orders.CustomerID		= CustPeople.PersonID
	JOIN Sales.OrderLines					ON Sales.Orders.OrderID			= Sales.OrderLines.OrderID
ORDER BY row_number() OVER (partition by Sales.Orders.ContactPersonID order by Sales.Orders.CustomerID DESC)

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select *
	from (

select 
	Sales.Orders.CustomerID			--клиент
	,CustPeople.FullName			--имя клиента
	,Sales.OrderLines.StockItemID	--код товара
	,Sales.OrderLines.UnitPrice		--цена
	,Sales.Orders.OrderDate			--дата заказа
	,ROW_NUMBER() OVER  (PARTITION BY Sales.Orders.CustomerID order by Sales.OrderLines.UnitPrice	desc) as ROWNUM
from Sales.Orders
	JOIN Application.People					ON Sales.Orders.ContactPersonID = Application.People.PersonID
	JOIN Application.People as CustPeople	ON Sales.Orders.CustomerID		= CustPeople.PersonID
	JOIN Sales.OrderLines					ON Sales.Orders.OrderID			= Sales.OrderLines.OrderID
) as S
WHERE
	S.ROWNUM <= 2