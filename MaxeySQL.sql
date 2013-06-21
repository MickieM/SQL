--SQL Code Examples
--Mickie Maxey
--More available upon request

--Question 1. 
CREATE VIEW InvoiceBasic 
AS
	SELECT TOP 100 PERCENT VendorName, InvoiceNumber, InvoiceTotal	
	FROM Vendors JOIN Invoices
		ON Vendors.VendorID = Invoices.VendorID
	WHERE VendorName LIKE '[NOP]%'
	ORDER BY VendorName
	

--Question 2

CREATE VIEW Top10PaidInvoices
AS
	SELECT VendorName, MAX(InvoiceDate) AS LastInvoice, SUM(InvoiceTotal) AS SumOfInvoices
	FROM Invoices JOIN Vendors
		ON Invoices.VendorID = Vendors.VendorID
	WHERE InvoiceTotal - PaymentTotal - CreditTotal = 0
	GROUP BY VendorName

--Question 3
CREATE VIEW VendorAddress
AS
	SELECT VendorID, VendorAddress1, VendorAddress2, VendorCity, VendorState, VendorZipCode
	FROM Vendors
	
SELECT * FROM VendorAddress
WHERE VendorID = 4

UPDATE VendorAddress
SET VendorAddress2 = RIGHT(VendorAddress1,7), VendorAddress1 = SUBSTRING(VendorAddress1,1,LEN(VendorAddress1) - 8)
WHERE VendorID = 4	

SELECT * FROM VendorAddress
WHERE VendorID = 4


--Question 4

SELECT *
FROM sys.foreign_key_columns



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

--Question 1
USE AP
IF OBJECT_ID('spBalanceRange') IS NOT NULL
	DROP PROC spBalanceRange
GO

CREATE PROC spBalanceRange
	@VendorVar varchar(40) = '%', 
	@BalanceMin money = NULL,
	@BalanceMax money = NULL
AS
	IF @BalanceMin IS NULL AND @BalanceMax IS NULL
	
	SELECT VendorName, InvoiceNumber, InvoiceTotal - CreditTotal - PaymentTotal as Balance
	FROM Invoices JOIN Vendors
	ON Invoices.VendorID = Invoices.InvoiceID
	WHERE (InvoiceTotal - CreditTotal - PaymentTotal) > 0 AND VendorName LIKE @VendorVar
	ORDER BY Balance DESC
	
	ELSE 
	SELECT VendorName, InvoiceNumber, InvoiceTotal - CreditTotal - PaymentTotal as Balance
	FROM Invoices JOIN Vendors
	ON Invoices.VendorID = Invoices.InvoiceID
	WHERE (InvoiceTotal - CreditTotal - PaymentTotal) BETWEEN @BalanceMin AND @BalanceMax 
	ORDER BY Balance DESC
	
--Question 2

--A
DECLARE @MyVendor varchar(40)

EXEC spBalanceRange 'Z%'

--B

DECLARE @BalMin money = 200
DECLARE @BalMax money = 1000


EXEC spBalanceRange @BalanceMin = @BalMin, @BalanceMax = @BalMax

--C

DECLARE @BalMax money = 200


EXEC spBalanceRange '%<G', @BalanceMax = @BalMax


--Question 3

USE AP
IF OBJECT_ID('spDateRange') IS NOT NULL
	DROP PROC spDateRange
GO

CREATE PROC spDateRange
	@DateMin DATE = NULL, 
	@DateMax DATE = NULL
AS

IF @DateMin = NULL AND @DateMax = NULL	
	BEGIN 
		RAISERROR ('Must have dates',11,1) 
	END	
	
IF @DateMax < @DateMin
	RAISERROR ('End date must be later than begin date',11,1)

ELSE
	SELECT InvoiceNumber, InvoiceDate, InvoiceTotal, (InvoiceTotal-CreditTotal-PaymentTotal) AS Balance
	FROM Invoices
	WHERE InvoiceDate BETWEEN @DateMin AND @DateMax
	ORDER BY InvoiceDate ASC
	
--Question 4

 USE AP
 
 EXEC spDateRange '4/10/2008', '4/20/2008'

--Question 5
CREATE FUNCTION fnUnpaidInvoiceID()
	RETURNS INT
	
AS
BEGIN
	DECLARE @InvoiceID INT;
	SET @InvoiceID = (SELECT TOP 1 InvoiceID
		FROM Invoices
		WHERE (InvoiceTotal - CreditTotal - PaymentTotal) > 0
		ORDER BY InvoiceDate);
	RETURN (@InvoiceID);
END



SELECT VendorName, InvoiceNumber, InvoiceDueDate, InvoiceTotal - PaymentTotal - CreditTotal  AS Balance
FROM Vendors JOIN Invoices 
	ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceID = dbo.fnUnpaidInvoiceID()


--Question 6
CREATE FUNCTION fnDateRange
(@DateMin SMALLDATETIME = NULL, 
 @DateMax SMALLDATETIME = NULL)
 RETURNS table
RETURN
	(SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,InvoiceTotal-CreditTotal-PaymentTotal AS Balance  
	FROM Invoices
	WHERE InvoiceDate BETWEEN @DateMin AND @DateMax)
	
	
	
SELECT * 
FROM dbo.fnDateRange('4/8/2008','4/20/2008')


--Question 7

SELECT Vendors.VendorName, myFunction.InvoiceNumber, myFunction.InvoiceDate, Balance 
FROM Invoices JOIN dbo.fnDateRange(DEFAULT, DEFAULT) AS myFunction
	ON Invoices.VendorID = myFunction.InvoiceNumber JOIN
	Vendors ON Invoices.InvoiceID = Vendors.VendorID



--Question 8

CREATE TABLE ShippingLabels
	(VendorName varchar(50),
	VendorAddress1 varchar(50),
	VendorAddress2 varchar(50),
	VendorCity varchar(50),
	VendorState char(2),
	VendorZipCode varchar(20))
	
CREATE TRIGGER InvoicePaymentUpdate
ON Invoices
AFTER UPDATE

AS
UPDATE ShippingLabels
SET VendorName = Vendors.VendorName, VendorAddress1 = Vendors.VendorAddress1 
FROM Vendors JOIN Invoices
	ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceID = (SELECT InvoiceID From INSERTED)

UPDATE Invoices 
SET PaymentTotal = 67.92, PaymentDate = '2008-08-23'
WHERE InvoiceID = 100

--Question 9

CREATE TABLE TestUniqueNulls
(RowID   int IDENTITY NOT NULL,
NoDupName varchar(20) NULL)

CREATE TRIGGER NoDupes
 ON TestUniqueNulls
 AFTER INSERT, UPDATE
 
 AS
 IF EXISTS 
 (SELECT NoDupName FROM TestUniqueNulls)
BEGIN
  RAISERROR ('Nulls exceeded',11,1)
  ROLLBACK TRAN
END














































