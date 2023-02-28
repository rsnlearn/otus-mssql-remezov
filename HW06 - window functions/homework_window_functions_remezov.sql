/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29  | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

SET STATISTICS TIME, IO ON
--напишите здесь свое решение
SELECT
	i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,il.Quantity * il.UnitPrice AS UnitSum
	,(  SELECT
			SUM(sil.Quantity * sil.UnitPrice)
		FROM 
			Sales.Invoices si
		INNER JOIN
			Sales.InvoiceLines sil
			ON sil.InvoiceID = si.InvoiceID
		WHERE
			si.InvoiceDate BETWEEN N'20150101' AND EOMONTH(i.InvoiceDate)
	) AS MonthSalesTotalCumulative
FROM 
	 Sales.Invoices i
INNER JOIN
	Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
INNER JOIN
	Sales.Customers c
ON c.CustomerID = i.CustomerID
WHERE i.InvoiceDate >= N'20150101'
ORDER BY i.InvoiceDate, InvoiceID, UnitSum DESC;

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

--напишите здесь свое решение
SELECT
	i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,il.Quantity * il.UnitPrice AS UnitSum
	,SUM(il.Quantity * il.UnitPrice) OVER (ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)) AS MonthSalesTotalCumulative
FROM 
	 Sales.Invoices i
INNER JOIN
	Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
INNER JOIN
	Sales.Customers c
ON c.CustomerID = i.CustomerID
WHERE i.InvoiceDate >= N'20150101'
ORDER BY i.InvoiceDate, InvoiceID, UnitSum DESC;

-- статистика выполнения запросов
/*
1-й запрос
(101356 rows affected)
Table 'InvoiceLines'. Scan count 888, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 322, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 444, segment skipped 0.
Table 'Worktable'. Scan count 443, logical reads 164589, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Invoices'. Scan count 2, logical reads 22800, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 50938 ms,  elapsed time = 54162 ms.

2-й запрос
(101356 rows affected)
Table 'InvoiceLines'. Scan count 2, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 161, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 406 ms,  elapsed time = 2097 ms.
*/

-- по результатам анализа статистики второй запрос (с применением оконных функций) примерно на два порядка быстрее первого запроса (с использованием подзапроса)

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

--напишите здесь свое решение
SELECT
	st.InvoiceMonth
	,st.StockItemName
	,st.SalesQuantityTotal
	,st.SalesRank
FROM (
	SELECT
		MONTH(i.InvoiceDate) AS InvoiceMonth
		,si.StockItemName
		,SUM(il.Quantity) AS SalesQuantityTotal
		,ROW_NUMBER() OVER (PARTITION BY MONTH(i.InvoiceDate) ORDER BY SUM(il.Quantity) DESC, si.StockItemName) AS SalesRank
	FROM 
		 Sales.Invoices i
	INNER JOIN
		Sales.InvoiceLines il
		ON il.InvoiceID = i.InvoiceID
	INNER JOIN
		Warehouse.StockItems si
		ON si.StockItemID = il.StockItemID
	WHERE
		i.InvoiceDate BETWEEN '20160101' AND '20161231'
	GROUP BY MONTH(i.InvoiceDate), si.StockItemName) st
WHERE st.SalesRank <= 2
ORDER BY st.InvoiceMonth, st.SalesRank

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
	StockItemID
	,StockItemName
	,Brand
	,UnitPrice
	,ROW_NUMBER() OVER(PARTITION BY UPPER(LEFT(StockItemName, 1)) ORDER BY StockItemName) AS RowNumByFirstChar
	,COUNT(*) OVER() AS StockItemsCount
	,COUNT(*) OVER(PARTITION BY UPPER(LEFT(StockItemName, 1)))  AS StockItemsCountByFirstChar
	,LEAD(StockItemID) OVER(ORDER BY StockItemName) AS NextStockItemIdByName
	,LAG(StockItemID) OVER(ORDER BY StockItemName) AS PrevStockItemIdByName
	,LAG(StockItemName, 2, 'No items') OVER(ORDER BY StockItemName) AS PrevStockItemIdByName
	,NTILE(30) OVER(ORDER BY TypicalWeightPerUnit) AS GroupByUnitWeight
FROM
	Warehouse.StockItems
ORDER BY
	StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT 	 
	SalespersonPersonID
	,FullName
	,CustomerName AS LastInvoiceCustomerName
	,InvoiceDate AS LastInvoiceDate
	,InvoiceSum AS LastInvoiceSum
FROM
	(SELECT
		i.SalespersonPersonID
		,p.FullName
		,c.CustomerName
		,i.InvoiceDate
		,SUM(il.Quantity * il.UnitPrice) OVER (PARTITION BY i.InvoiceID) AS InvoiceSUM
		,DENSE_RANK() OVER(PARTITION BY i.SalespersonPersonID ORDER BY i.InvoiceID DESC) AS SalePersonInvoiceRank
		,ROW_NUMBER() OVER(PARTITION BY i.SalespersonPersonID, i.InvoiceID ORDER BY il.StockItemID) AS SalePersonInvoiceLineRank
	FROM
		Sales.Invoices i
	INNER JOIN
		Sales.InvoiceLines il
		ON il.InvoiceID = i.InvoiceID
	INNER JOIN
		Sales.Customers c
		ON c.CustomerID = i.CustomerID
	INNER JOIN
		Application.People p
		ON p.PersonID = i.SalespersonPersonID) spil
WHERE
	spil.SalePersonInvoiceRank = 1
	AND spil.SalePersonInvoiceLineRank = 1
ORDER BY spil.FullName

-- вариант без оконных функций
SELECT
	spli.SalespersonPersonID
	,sp.FullName
	,c.CustomerName AS LastInvoiceCustomerName
	,i.InvoiceDate AS LastInvoiceDate
	,ils.InvoiceSum AS LastInvoiceSum
FROM
	(SELECT SalespersonPersonID, MAX(InvoiceID) AS LastInvoiceID
	FROM Sales.Invoices
	GROUP BY SalespersonPersonID) spli
INNER JOIN	
	Sales.Invoices i
	ON i.InvoiceID = spli.LastInvoiceID
INNER JOIN
	Sales.Customers c
	ON c.CustomerID = i.CustomerID
INNER JOIN
	(SELECT PersonID, FullName FROM Application.People WHERE IsSalesperson = 1) sp
	ON sp.PersonID = spli.SalespersonPersonID
INNER JOIN
	(SELECT InvoiceID, SUM(Quantity * UnitPrice) AS InvoiceSum FROM Sales.InvoiceLines GROUP BY InvoiceID) ils
	ON ils.InvoiceID = spli.LastInvoiceID
ORDER BY sp.FullName

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT 
	CustomerID
	,CustomerName
	,StockItemID
	,UnitPrice
	,InvoiceDate
FROM
	(SELECT
		CustomerID
		,CustomerName
		,StockItemID
		,UnitPrice
		,InvoiceDate
		,SUM(CustomerItemRowRank) OVER(PARTITION BY cil.CustomerName ORDER BY UnitPrice DESC, InvoiceDate DESC) AS UqItemsCount
	FROM (
		SELECT
			c.CustomerID
			,c.CustomerName
			,il.StockItemID
			,il.UnitPrice
			,i.InvoiceDate
			,ROW_NUMBER() OVER(PARTITION BY c.CustomerName, il.StockItemID ORDER BY il.UnitPrice DESC, i.InvoiceDate DESC) AS CustomerItemRowRank
		FROM
			Sales.Invoices i
		INNER JOIN
			Sales.Customers c
			ON c.CustomerID = i.CustomerID
		INNER JOIN
			Sales.InvoiceLines il
			ON il.InvoiceID = i.InvoiceID
		) cil
	WHERE CustomerItemRowRank = 1) simp
WHERE UqItemsCount <= 2
ORDER BY CustomerName, UnitPrice DESC, StockItemID

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 