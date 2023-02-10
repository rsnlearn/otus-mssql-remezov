/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".

Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

-- напишите здесь свое решение
SELECT
	StockItemID,
	StockItemName
FROM
	WideWorldImporters.Warehouse.StockItems
WHERE
	StockItemName LIKE N'%urgent%'
	OR StockItemName LIKE N'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.

Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

-- напишите здесь свое решение
SELECT
	s.SupplierID,
	s.SupplierName
FROM
	WideWorldImporters.Purchasing.Suppliers s
LEFT JOIN
	WideWorldImporters.Purchasing.PurchaseOrders po
ON po.SupplierID = s.SupplierCategoryID
WHERE
	po.PurchaseOrderID IS NULL;

/*
3. Заказы (Orders) с товарами ценой (UnitPrice) более 100$
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).

Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ (10.01.2011)
* название месяца, в котором был сделан заказ (используйте функцию FORMAT или DATENAME)
* номер квартала, в котором был сделан заказ (используйте функцию DATEPART)
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- напишите здесь свое решение
SELECT
	o.OrderID,
	OrderDate,
	FORMAT(o.OrderDate, N'dd.MM.yyyy') AS OrderDate,
	DATEPART(quarter, o.OrderDate) AS OrderDateQuarter,
	FLOOR((MONTH(o.OrderDate) - 1) / 4) + 1 AS OrderDateThird,
	c.CustomerName
FROM
	WideWorldImporters.Sales.Orders o
INNER JOIN
	WideWorldImporters.Sales.OrderLines ol
ON ol.OrderID = o.OrderID
INNER JOIN
	WideWorldImporters.Sales.Customers c
ON o.CustomerID = c.CustomerID
WHERE
	NOT o.PickingCompletedWhen IS NULL
	AND (ol.UnitPrice > 100 OR ol.Quantity > 20)
ORDER BY
	OrderDateQuarter ASC,
	OrderDateThird ASC,
	o.OrderDate ASC
OFFSET 1000 ROWS
FETCH NEXT 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).

Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

-- напишите здесь свое решение
SELECT
	DeliveryMethodName,
	ExpectedDeliveryDate,
	s.SupplierName,
	p.FullName AS ContactPerson
FROM
	WideWorldImporters.Purchasing.Suppliers s
INNER JOIN
	WideWorldImporters.Purchasing.PurchaseOrders po
ON po.SupplierID = s.SupplierID
INNER JOIN
	WideWorldImporters.Application.DeliveryMethods dm
ON dm.DeliveryMethodID = po.DeliveryMethodID
INNER JOIN
	WideWorldImporters.Application.People p
ON p.PersonID = po.ContactPersonID
WHERE
	po.ExpectedDeliveryDate BETWEEN '20130101' AND '20130131' -- не стал добавлять время в границы промежутка, т.к. поле ExpectedDeliveryDate имеет тип date
	AND po.IsOrderFinalized = 1
	AND dm.DeliveryMethodName IN (N'Air Freight', N'Refrigerated Air Freight');

/*
5. Десять последних продаж (по дате продажи - InvoiceDate) с именем клиента (клиент - CustomerID) и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.

Вывести: ИД продажи (InvoiceID), дата продажи (InvoiceDate), имя заказчика (CustomerName), имя сотрудника (SalespersonFullName)
Таблицы: Sales.Invoices, Sales.Customers, Application.People.
*/

-- напишите здесь свое решение
SELECT TOP 10
	i.InvoiceID,
	i.InvoiceDate,
	c.CustomerName,
	p.FullName AS SalespersonFullName
FROM
	WideWorldImporters.Sales.Invoices i
INNER JOIN
	WideWorldImporters.Sales.Customers c
ON c.CustomerID = i. CustomerID
INNER JOIN
	WideWorldImporters.Application.People p
ON p.PersonID = i.SalespersonPersonID
ORDER BY
	i.InvoiceDate DESC,
	i.InvoiceID DESC;

/*
6. Все ид и имена клиентов (клиент - CustomerID) и их контактные телефоны (PhoneNumber),
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems, имена клиентов и их контакты в таблице Sales.Customers.

Таблицы: Sales.Invoices, Sales.InvoiceLines, Sales.Customers, Warehouse.StockItems.
*/

-- напишите здесь свое решение
SELECT
	c.CustomerID,
	c.CustomerName,
	c.PhoneNumber
FROM
	WideWorldImporters.Sales.Customers c
INNER JOIN
	WideWorldImporters.Sales.Invoices i
ON i.CustomerID = c.CustomerID
INNER JOIN
	WideWorldImporters.Sales.InvoiceLines il
ON il.InvoiceID = i.InvoiceID
INNER JOIN
	WideWorldImporters.Warehouse.StockItems si
ON si.StockItemID = il.StockItemID
WHERE
	si.StockItemName = N'Chocolate frogs 250g'