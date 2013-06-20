--Carla Maxey Chapter 12

--Question 1. 
CREATE VIEW InvoiceBasic 
AS
	SELECT TOP 100 PERCENT VendorName, InvoiceNumber, InvoiceTotal	
	FROM Vendors JOIN Invoices
		ON Vendors.VendorID = Invoices.VendorID
	WHERE VendorName LIKE '[NOP]%'
	ORDER BY VendorName
	
	--I don't know why we had to sort these results within the VIEW, It makes much more
	--sense to do the ORDER BY within a query that is using the VIEW


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

--6 foreign keys are defined


--Question 5

--The Management Studio inserts an ORDER BY clause

--I don't understand this question. I had to cose a TOP 100 PERCENT clause in exercise 1 to sort the results by VendorName already. 
--I had to click "Unsorted" to remove my original sort, then click the Sort Type to sort it again, to add back my original ORDER BY clause. 





