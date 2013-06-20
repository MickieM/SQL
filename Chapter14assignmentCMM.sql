--Carla Maxey
--Chapter 14

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



























