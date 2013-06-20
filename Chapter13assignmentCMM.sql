--Carla Maxey Chapter 13

--Question 1
--DOES NOT WOK YET

USE AP

DECLARE @BalanceDue money
SET @BalanceDue = (SELECT SUM(InvoiceTotal-PaymentTotal-CreditTotal) FROM Invoices)
IF @BalanceDue > 10000
BEGIN
	 SELECT VendorName, InvoiceNumber, InvoiceDueDate, InvoiceTotal-PaymentTotal-CreditTotal AS BalanceDue
	 FROM Invoices JOIN Vendors
	 ON Invoices.VendorID = Vendors.VendorID
	 WHERE InvoiceTotal-PaymentTotal-CreditTotal > 0
	 ORDER BY InvoiceDueDate DESC
END	 
ELSE
	PRINT 'Balance due is less than $10000'	


--Question 2

USE AP

IF OBJECT_ID('TempTable') IS NOT NULL
	DROP TABLE TempTable
GO

SELECT VendorName, FirstInvoiceDate, InvoiceTotal
INTO #TempTable
FROM Invoices JOIN
	(SELECT VendorID, MIN(InvoiceDate) AS FirstInvoiceDate
	 FROM Invoices
	 GROUP BY VendorID) AS FirstInvoice
ON (Invoices.VendorID = FirstInvoice.VendorID AND
	Invoices.InvoiceDate = FirstInvoice.FirstInvoiceDate)
JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID
ORDER BY VendorName, FirstInvoiceDate


--Question 3

USE AP
GO

IF OBJECT_ID('ThisView') IS NOT NULL
DROP VIEW ThisView
GO

CREATE VIEW ThisView AS

SELECT VendorName, FirstInvoiceDate, InvoiceTotal
FROM Invoices JOIN
	(SELECT VendorID, MIN(InvoiceDate) AS FirstInvoiceDate
	 FROM Invoices
	 GROUP BY VendorID) AS FirstInvoice
ON (Invoices.VendorID = FirstInvoice.VendorID AND
	Invoices.InvoiceDate = FirstInvoice.FirstInvoiceDate)
JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID

--Question 4

SELECT sysobjects.Name, sysindexes.Rows
FROM sysobjects
JOIN sysindexes
ON sysobjects.id = sysindexes.id
WHERE type = 'U'
AND sysindexes.IndId < 2
ORDER BY
sysobjects.Name

