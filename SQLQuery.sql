CREATE DATABASE SQLTestTask

USE SQLTestTask

--�reating the Banks table
CREATE TABLE Banks(
	BankId INT IDENTITY(1, 1) NOT NULL,
	BankName VARCHAR(20) NOT NULL,
	PRIMARY KEY (BankId)
);

--�reating the Cities table
CREATE TABLE Cities(
	CityId INT IDENTITY(1, 1) NOT NULL,
	CityName VARCHAR(20) NOT NULL,
	PRIMARY KEY (CityId)
);

--�reating the Branches table
CREATE TABLE Branches(
	BranchId INT IDENTITY(1, 1) NOT NULL,
	BankId INT,
	CityId INT,
	BranchName VARCHAR(20) NOT NULL,
	PRIMARY KEY (BranchId),
	CONSTRAINT FK_Banks_Branches FOREIGN KEY (BankId) REFERENCES Banks(BankId),
	CONSTRAINT FK_Cities_Branches FOREIGN KEY (CityId) REFERENCES Cities(CityId)
);

--�reating the SocialStatuses table
CREATE TABLE SocialStatuses(
	StatusId INT IDENTITY(1, 1) NOT NULL,
	StatusName VARCHAR(20) NOT NULL,
	PRIMARY KEY (StatusId)
);

--�reating the Customers table
CREATE TABLE Customers(
	CustomerId INT IDENTITY(1,1) NOT NULL,
	StatusId INT,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	PRIMARY KEY (CustomerID),
	CONSTRAINT FK_SocialStatuses_Customers FOREIGN KEY (StatusId) REFERENCES SocialStatuses(StatusId)
);

--�reating the Accounts table
CREATE TABLE Accounts(
	AccountId INT IDENTITY(1,1) NOT NULL,
	BankId INT,
	CustomerId INT,
	AccountBalance INT NOT NULL,
	PRIMARY KEY (AccountId),
	CONSTRAINT FK_Banks_Accounts FOREIGN KEY (BankId) REFERENCES Banks(BankId),
	CONSTRAINT FK_Customers_Accounts FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
	CONSTRAINT UC_Bank_Customer UNIQUE (BankId, CustomerId)
);

--�reating the Cards table
CREATE TABLE Cards(
	CardId INT IDENTITY(1,1) NOT NULL,
	AccountId INT,
	CardBalance INT NOT NULL,
	CONSTRAINT FK_Accounts_Cards FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId)
);


INSERT INTO Banks (BankName) VALUES
	('Belarusbank'),
	('Alfa-Bank'),
	('Tinkoff Bank'),
	('Paritetbank'),
	('J.P. Morgan');

INSERT INTO Cities (CityName) VALUES
	('Minsk'),
	('Moscow'),
	('Saint Petersburg'),
	('Gomel'),
	('New York');

INSERT INTO Branches (BankId, CityId, BranchName) VALUES
	(1, 1, 'Branch Minsk 4'),
	(1, 4, 'Branch Gomel 65'),
	(2, 2, 'Branch Moscow 7'),
	(2, 3, 'Branch Saint P 47'),
	(3, 2, 'Branch Moscow 63'),
	(3, 3, 'Branch Saint P 89'),
	(4, 1, 'Branch Minsk 9'),
	(4, 4, 'Branch Gomel 43'),
	(5, 5, 'Branch New York 34');

INSERT INTO SocialStatuses (StatusName) VALUES
	('Student'),
	('Employed'),
	('Unemployed'),
	('Retired'),
	('Invalid');

INSERT INTO Customers (StatusId, FirstName, LastName) VALUES
	(1, 'Alice', 'Smith'),
	(2, 'Bob', 'Johnson'),
	(2, 'Charlie', 'Brown'),
	(3, 'David', 'Lee'),
	(4, 'Eva', 'Williams');

INSERT INTO Accounts (BankId, CustomerId, AccountBalance) VALUES
	(1, 1, 5000),
	(1, 2, 7500),
	(2, 2, 10000),
	(2, 3, 6000),
	(3, 4, 8000),
	(3, 5, 9000),
	(4, 1, 3000),
	(4, 3, 4500),
	(5, 5, 12000);

INSERT INTO Cards (AccountId, CardBalance) VALUES
	(1, 2000),
	(1, 500),
	(3, 3000),
	(3, 800),
	(5, 1500),
	(6, 2000),
	(6, 700), 
	(6, 1000),
	(9, 2500);

--task 2
SELECT DISTINCT b.BankName
FROM Banks b
JOIN Branches br ON b.BankId = br.BankId
JOIN Cities ci ON br.CityId = ci.CityId
WHERE ci.CityName = 'Moscow';

--task3
SELECT
	c.FirstName,
	cd.CardBalance,
	b.BankName
FROM Cards cd
JOIN Accounts a ON cd.AccountId = a.AccountId
JOIN Customers c ON a.CustomerId = c.CustomerId
JOIN Banks b ON a.BankId = b.BankId;

--task4
SELECT
    a.AccountId,
    b.BankName,
    a.AccountBalance,
    a.AccountBalance - SUM(c.CardBalance) AS BalanceDifference
FROM Accounts a
JOIN Banks b ON a.BankId = b.BankId
--INNER JOIN Cards c ON a.AccountId = c.AccountId
LEFT JOIN Cards c ON a.AccountId = c.AccountId
GROUP BY a.AccountId, b.BankName, a.AccountBalance
HAVING a.AccountBalance <> SUM(c.CardBalance);

--task5(GROUP BY)
SELECT
	s.StatusName,
	COUNT(c.CardId) AS CardCount
FROM SocialStatuses s
LEFT JOIN Customers cu ON s.StatusId = cu.StatusId
LEFT JOIN Accounts a ON cu.CustomerId = a.CustomerId
LEFT JOIN Cards c ON a.AccountId = c.CardId
GROUP BY s.StatusName

--task5(���������)
SELECT
    s.StatusName,
    (
        SELECT COUNT(c.CardId)
        FROM Customers cu
        JOIN Accounts a ON cu.CustomerId = a.CustomerId
        JOIN Cards c ON a.AccountId = c.AccountId
        WHERE cu.StatusId = s.StatusId
    ) AS CardCount
FROM SocialStatuses s;

--task6
-- ������� stored procedure
USE SQLTestTask
GO
CREATE PROCEDURE AddAmountToAccounts
    @StatusId INT
AS
BEGIN
    -- �������� ������� ����������� �������
    IF NOT EXISTS (SELECT 1 FROM SocialStatuses WHERE StatusId = @StatusId)
    BEGIN
        PRINT '���������� ������ � Id ' + CAST(@StatusId AS NVARCHAR(10)) + ' �� ������.';
        RETURN;
    END

    -- �������� ������� ��������� � ������ ���������� ��������
    IF NOT EXISTS (
        SELECT 1
        FROM Customers cu
        JOIN Accounts a ON cu.CustomerId = a.CustomerId
        WHERE cu.StatusId = @StatusId
    )
    BEGIN
        PRINT '��� ����������� ������� � Id ' + CAST(@StatusId AS NVARCHAR(10)) + ' ��� ����������� ���������.';
        RETURN;
    END

    -- ���������� $10 �� ������ ���������� ������� � ������ ���������� ��������
    UPDATE Accounts
    SET AccountBalance = AccountBalance + 10
    WHERE CustomerId IN (
        SELECT cu.CustomerId
        FROM Customers cu
        WHERE cu.StatusId = @StatusId
    )
    
    -- ����� ��������� �� �������� ����������
    PRINT '��������� $10 �� ������ ���������� ������� ��� ����������� ������� � Id ' + CAST(@StatusId AS NVARCHAR(10));
END

--������������� ���������
SELECT
	a.AccountId,
	a.AccountBalance
FROM Accounts a
LEFT JOIN Customers c ON a.CustomerId = c.CustomerId
WHERE c.StatusId = 2

EXEC AddAmountToAccounts @StatusId = 2;

SELECT
	a.AccountId,
	a.AccountBalance
FROM Accounts a
LEFT JOIN Customers c ON a.CustomerId = c.CustomerId
WHERE c.StatusId = 2

--task7
SELECT
	cu.FirstName,
	cu.LastName,
	a.AccountId,
	a.AccountBalance -  ISNULL(SUM(c.CardBalance), 0) AS AvailableFunds
FROM Customers cu
LEFT JOIN Accounts a ON cu.CustomerId = a.CustomerId
LEFT JOIN Cards c ON a.AccountId = c.AccountId
GROUP BY cu.FirstName, cu.LastName, a.AccountId, a.AccountBalance

--task8
USE SQLTestTask
GO
CREATE PROCEDURE TransferFunds
	@CardId INT,
	@Amount INT
AS
BEGIN
	BEGIN TRANSACTION;

	BEGIN TRY
		--��������� AccountId
		DECLARE @AccountId INT;
		SELECT @AccountId = AccountId
		FROM Cards
		WHERE CardId = @CardId;

		--���������, ��� ����� ��� �������� �� ��������� ������� �����
		DECLARE @AvailableBalance INT;
		SELECT @AvailableBalance = a.AccountBalance - ISNULL(SUM(c.CardBalance), 0)
		FROM Accounts a
		JOIN Cards c ON a.AccountId = c.AccountId
        WHERE a.AccountId = @AccountId
		GROUP BY a.AccountBalance;

		IF @Amount <= @AvailableBalance
			BEGIN
				UPDATE Cards
				SET CardBalance = CardBalance + @Amount
				WHERE CardId = @CardId;
			END
		ELSE
			BEGIN
            -- � ������ �������������� ������� �����, ���������� ����������
            ROLLBACK;
            PRINT '������������ ������� �� ����� ��� ��������.'
        END
	END TRY
	BEGIN CATCH
		-- � ������ ������������� ������, ���������� ����������
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
	END CATCH

	COMMIT;
END;

--������������� ���������
SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

EXEC TransferFunds @CardId = 3, @Amount = 1;

SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

--task9
--������� ��� ������� Accounts
USE SQLTestTask
GO
CREATE TRIGGER CheckAccountBalance
ON Accounts
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @AccountId INT;
    DECLARE @NewAccountBalance INT;
    DECLARE @TotalCardBalance INT;

    -- �������� �������� ����� ���������� ��������
    SELECT @AccountId = i.AccountId, @NewAccountBalance = i.AccountBalance
    FROM inserted i;

    -- ��������� ����� ������� ���� ���� ��� ������� ��������
    SELECT @TotalCardBalance = SUM(CardBalance)
    FROM Cards
    WHERE AccountId = @AccountId;

    -- �������� �������
    IF @NewAccountBalance < @TotalCardBalance
    BEGIN
        PRINT '������ ���������� ������ �������� ������, ��� ����� �������� ����.';
        ROLLBACK TRANSACTION;
    END
END;

DROP TRIGGER CheckAccountBalance

--������������� UPDATE ����� �������� ������ �������� c �������� Accounts
--�������� ����������
SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

UPDATE Accounts
SET AccountBalance = 10030
WHERE AccountId = 3

SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

--��������� ����������
SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

UPDATE Accounts
SET AccountBalance = 2000
WHERE AccountId = 3

SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

--������� ��� ������� Cards
CREATE TRIGGER CheckCardBalance
ON Cards
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @CardId INT;
    DECLARE @AccountId INT;
    DECLARE @TotalCardBalance INT;
    DECLARE @AccountBalance INT;

    -- �������� �������� ����� ���������� ��������
    SELECT @CardId = i.CardId, @AccountId = i.AccountId
    FROM inserted i;

    -- ��������� ����� ������� ���� ���� ��� ������� ��������
    SELECT @TotalCardBalance = SUM(CardBalance)
    FROM Cards
    WHERE AccountId = @AccountId;

    -- �������� ������� ������ ��������
    SELECT @AccountBalance = AccountBalance
    FROM Accounts
    WHERE AccountId = @AccountId;

    -- �������� �������
    IF @TotalCardBalance > @AccountBalance
    BEGIN
        PRINT '����� �������� ���� �� ����� ���� ������ ������� ��������.';
        ROLLBACK TRANSACTION;
    END
END;

--������������� UPDATE ����� �������� ������ �������� c �������� Cards
--�������� ����������
SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

UPDATE Cards
SET CardBalance = 4000
WHERE CardId = 3

SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

--��������� ����������
SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3

UPDATE Cards
SET CardBalance = 9000
WHERE CardId = 3

SELECT
	a.AccountId,
	a.AccountBalance,
	c.CardId,
	c.CardBalance
From Accounts a
JOIN Cards c ON a.AccountId = c.AccountId
WHERE a.AccountId = 3





 














SELECT * FROM Banks;
SELECT * FROM Cities;
SELECT * FROM Branches;
SELECT * FROM SocialStatuses;
SELECT * FROM Customers;
SELECT * FROM Accounts;
SELECT * FROM Cards;

DELETE FROM Cities
DELETE FROM Branches
DELETE FROM Cards

SELECT MAX(CityId) FROM Cities;

DBCC CHECKIDENT ('Cities', RESEED, 0);
DBCC CHECKIDENT ('Cards', RESEED, 0);
DBCC CHECKIDENT ('Branches', RESEED, 0);

INSERT INTO Accounts (BankId, CustomerId, AccountBalance) VALUES
	(2, 1, 5000);

INSERT INTO Cards (AccountId, CardBalance) VALUES
	(11, 2000),
	(11, 3000);

UPDATE Cards
SET CardBalance = 3020
WHERE CardId = 2
