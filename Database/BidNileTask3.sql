-- 3.1 Country -> City
ALTER TABLE Accounts.City
ADD CONSTRAINT FK_City_Country
FOREIGN KEY (CountryCode)
REFERENCES Accounts.Country(Code);
GO

-- City ... Member
ALTER TABLE Accounts.Member
ADD CONSTRAINT FK_Member_City
FOREIGN KEY (CityId)
REFERENCES Accounts.City(Id);
GO

-- Member ...> Member 
ALTER TABLE Accounts.Member
ADD CONSTRAINT FK_Member_InvitedBy
FOREIGN KEY (InvitedByMemberId)
REFERENCES Accounts.Member(MemberId);
GO

-- Member ....> Wallet
ALTER TABLE Accounts.Wallet
ADD CONSTRAINT FK_Wallet_Member
FOREIGN KEY (MemberId)
REFERENCES Accounts.Member(MemberId);
GO

-- City ....> Warehouse
ALTER TABLE Operations.Warehouse
ADD CONSTRAINT FK_Warehouse_City
FOREIGN KEY (CityId)
REFERENCES Accounts.City(Id);
GO

-- Member ....> Employee
ALTER TABLE Operations.Employee
ADD CONSTRAINT FK_Employee_Member
FOREIGN KEY (EmployeeId)
REFERENCES Accounts.Member(MemberId);
GO

-- Warehouse ....> Employee
ALTER TABLE Operations.Employee
ADD CONSTRAINT FK_Employee_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Operations.Warehouse(WarehouseId);
GO

-- Category .....> Category (Parent)
ALTER TABLE Catalogue.Category
ADD CONSTRAINT FK_Category_Parent
FOREIGN KEY (ParentCategoryId)
REFERENCES Catalogue.Category(CategoryId);
GO

-- Member ...> Item (Seller)
ALTER TABLE Catalogue.Item
ADD CONSTRAINT FK_Item_Seller
FOREIGN KEY (SellerId)
REFERENCES Accounts.Member(MemberId);
GO

-- Category .....> Item
ALTER TABLE Catalogue.Item
ADD CONSTRAINT FK_Item_Category
FOREIGN KEY (CategoryId)
REFERENCES Catalogue.Category(CategoryId);
GO

-- Warehouse ....> Item
ALTER TABLE Catalogue.Item
ADD CONSTRAINT FK_Item_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Operations.Warehouse(WarehouseId);
GO

-- Employee .....> Item (Inspector)
ALTER TABLE Catalogue.Item
ADD CONSTRAINT FK_Item_Inspector
FOREIGN KEY (InspectorId)
REFERENCES Operations.Employee(EmployeeId);
GO

-- Item .....> Photo (Cascade Delete)
ALTER TABLE Catalogue.Photo
ADD CONSTRAINT FK_Photo_Item
FOREIGN KEY (ItemId)
REFERENCES Catalogue.Item(ItemId)
ON DELETE CASCADE;
GO

-- Item .....> Auction
ALTER TABLE Auction.Auction
ADD CONSTRAINT FK_Auction_Item
FOREIGN KEY (ItemId)
REFERENCES Catalogue.Item(ItemId);
GO

-- Auction ....> Bid
ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(AuctionId); --دننننن
GO

-- Member ....> Bid
ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Member
FOREIGN KEY (MemberId)
REFERENCES Accounts.Member(MemberId);
GO

-- Member ....> Follow
ALTER TABLE Auction.Follow
ADD CONSTRAINT FK_Follow_Member
FOREIGN KEY (MemberId)
REFERENCES Accounts.Member(MemberId);
GO

-- Auction ...> Follow
ALTER TABLE Auction.Follow
ADD CONSTRAINT FK_Follow_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(AuctionId);
GO


SELECT
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS TableSchema,
    OBJECT_NAME(fk.parent_object_id) AS TableName
FROM sys.foreign_keys fk
ORDER BY TableSchema, TableName;


-- 3.2:
ALTER TABLE Accounts.Member
ADD AppLanguage CHAR(2) NOT NULL
    CONSTRAINT DF_Member_AppLanguage DEFAULT 'ar'
    CONSTRAINT CK_Member_AppLanguage CHECK (AppLanguage IN ('ar', 'en'));
GO

-- 3.3 :
ALTER TABLE Catalogue.Item
ADD IsFeatured BIT NOT NULL
    CONSTRAINT DF_Item_IsFeatured DEFAULT 0;
GO

-- 3.4 :
EXEC sp_rename 'Auction.Bid.DeviceIP', 'DeviceIp', 'COLUMN';
GO

-- Drop the old CHECK constraint
ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_Capacity;
GO

-- Rename Capacity to MaxItems
EXEC sp_rename
    'Operations.Warehouse.Capacity',
    'MaxItems',
    'COLUMN';
GO

-- Recreate the CHECK constraint
ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO

-- 3.5 : 
ALTER TABLE Accounts.Member
ALTER COLUMN FullName NVARCHAR(150) NOT NULL;
GO


-- 3.6 : 
ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_MaxItems;
GO

ALTER TABLE Operations.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;
GO

ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO

-- 3.7 :
ALTER TABLE Catalogue.Category
DROP CONSTRAINT CK_Category_CommissionRate;
GO

ALTER TABLE Catalogue.Category
ADD CONSTRAINT CK_Category_CommissionRate
CHECK (CommissionRate BETWEEN 0 AND 25);
GO


-- 3.8 : 
ALTER TABLE Auction.Auction
DROP CONSTRAINT CK_Auction_Status;
GO

ALTER TABLE Auction.Auction
DROP CONSTRAINT DF_Auction_Status;
GO

ALTER TABLE Auction.Auction
ADD CONSTRAINT CK_Auction_Status
CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled', 'PendingReview'));
GO

ALTER TABLE Auction.Auction
ADD CONSTRAINT DF_Auction_Status
DEFAULT 'PendingReview' FOR Status;
GO

-- 3.9 : 
ALTER TABLE Auction.Auction
ADD BuyNowPrice DECIMAL(12,2) NULL;
GO

ALTER TABLE Auction.Auction
WITH CHECK
ADD CONSTRAINT CK_Auction_BuyNowPrice
CHECK (BuyNowPrice IS NULL OR BuyNowPrice > StartingPrice);
GO


-- 3.10 : 
ALTER TABLE Accounts.Member
ADD CONSTRAINT UQ_Member_Mobile UNIQUE (Mobile);
GO

-- 3.11 :
ALTER TABLE Accounts.Member
ADD VerifiedAt DATETIME2(3) NULL;
GO

ALTER TABLE Accounts.Member
DROP CONSTRAINT DF_Member_IsVerified;
GO

ALTER TABLE Accounts.Member
DROP COLUMN IsVerified;
GO

-- 3.12 :
CREATE SCHEMA Marketing;
GO

ALTER SCHEMA Marketing
TRANSFER Auction.Follow;
GO

ALTER TABLE Operations.Warehouse
ADD
    ManagerEmployeeId UNIQUEIDENTIFIER NULL,
    ManagerStartDate DATE NULL;
GO

ALTER TABLE Accounts.Country
ALTER COLUMN NAMeAr NVARCHAR(50) NOT NULL;
GO

SELECT
    SERVERPROPERTY('ProductVersion') AS SQLVersion,
    SERVERPROPERTY('Edition') AS SQLEdition;