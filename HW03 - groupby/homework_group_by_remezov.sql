/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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

USE WideWorldImporters;

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение
SELECT
	YEAR(i.InvoiceDate) AS InvoiceYear,
	MONTH(i.InvoiceDate) AS InvoiceMonth,
	AVG(il.UnitPrice) AS MonthAvgUnitPrice, -- округления до центов нет, т.к. неизвестно, что с этим результатом дальше делать
	SUM(il.UnitPrice * il.Quantity) AS MonthSalesTotal
FROM
	WideWorldImporters.Sales.Invoices i
INNER JOIN
	WideWorldImporters.Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
Сортировка по году и месяцу.

*/

-- напишите здесь свое решение
SELECT
	YEAR(i.InvoiceDate) AS InvoiceYear,
	MONTH(i.InvoiceDate) AS InvoiceMonth,
	SUM(il.UnitPrice * il.Quantity) AS MonthSalesTotal
FROM
	WideWorldImporters.Sales.Invoices i
INNER JOIN
	WideWorldImporters.Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice * il.Quantity) > 4600000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение
SELECT
	YEAR(i.InvoiceDate) AS InvoiceYear,
	MONTH(i.InvoiceDate) AS InvoiceMonth,
	si.StockItemName AS StockItemName,
	SUM(il.UnitPrice * il.Quantity) AS MonthSalesTotal,
	MIN(i.InvoiceDate) AS MonthFirstSaleDate,
	SUM(il.Quantity) AS MonthQuantityTotal
FROM
	WideWorldImporters.Sales.Invoices i
INNER JOIN
	WideWorldImporters.Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
INNER JOIN
	WideWorldImporters.Warehouse.StockItems si
ON si.StockItemID = il.StockItemID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), si.StockItemName
HAVING SUM(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), si.StockItemName;

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
4. Написать второй запрос ("Отобразить все месяцы, где общая сумма продаж превысила 4 600 000") 
за период 2015 год так, чтобы месяц, в котором сумма продаж была меньше указанной суммы также отображался в результатах,
но в качестве суммы продаж было бы '-'.
Сортировка по году и месяцу.

Пример результата:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -

*/
-- напишите здесь свое решение
SELECT
	m.Year AS InvoiceYear,
	m.Month AS InvoiceMonth,
	CASE
		WHEN SUM(il.UnitPrice * il.Quantity) > 4600000
			THEN CAST(SUM(il.UnitPrice * il.Quantity) AS NVARCHAR(50))
		ELSE 
			'-'
		END 
	AS MonthSalesTotal
FROM (SELECT *
	  FROM (VALUES (2015, 1), (2015, 2), (2015, 3),
				   (2015, 4), (2015, 5), (2015, 6),
				   (2015, 7), (2015, 8), (2015, 9),
				   (2015, 10), (2015, 11), (2015, 12)
	       ) v (Year, Month)
	 ) m
LEFT JOIN	
	WideWorldImporters.Sales.Invoices i
ON YEAR(i.InvoiceDate) = m.Year AND MONTH(i.InvoiceDate) = m.Month
INNER JOIN
	WideWorldImporters.Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
GROUP BY m.Year, m.Month
ORDER BY m.Year, m.Month;