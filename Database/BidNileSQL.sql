CREATE DATABASE BidNile;
GO

USE BidNile ;
GO

CREATE SCHEMA Accounts;
GO

CREATE SCHEMA Operations;
GO

CREATE SCHEMA Catalogue;
GO

CREATE SCHEMA Auction;
GO
CREATE TABLE Accounts.Country 
(
    Code CHAR(2) NOT NULL
      CONSTRAINT PK_Country PRIMARY KEY (Code) ,
    NAMeAr VARCHAR(50) NOT NULL,
    NAMeEn VARCHAR(50) NOT NULL,
    PhoneCode VARCHAR(50) NOT NULL
);

CREATE TABLE Accounts.City 
(
    Id INT Identity(1,1) NOT NULL 
         CONSTRAINT PK_City PRIMARY KEY (Id) ,

    Name VARCHAR(60) NOT NULL
         CONSTRAINT UQ_CityName_WithCountryCode UNIQUE (Name ,CountryCode) ,

    CountryCode CHAR(2) NOT NULL 
);


CREATE TABLE Accounts.Member
(
    MemberId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_Member_MemberId DEFAULT NEWID(),
        CONSTRAINT PK_Member PRIMARY KEY (MemberId),

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(254) NOT NULL,
            CONSTRAINT UQ_Member_Email UNIQUE (Email),

    Mobile VARCHAR(16) NOT NULL,

    NationalId VARCHAR(20) NOT NULL,
            CONSTRAINT UQ_Member_NationalId UNIQUE (NationalId),

    BirthDate DATE NOT NULL,

    IsVerified BIT NOT NULL
        CONSTRAINT DF_Member_IsVerified DEFAULT 0,

    RegisteredAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Member_RegisteredAt DEFAULT SYSDATETIME(),

    CityId INT NOT NULL,
    InvitedByMemberId UNIQUEIDENTIFIER NULL,
);
GO

CREATE TABLE Accounts.Wallet
(
    MemberId UNIQUEIDENTIFIER NOT NULL,

    Balance DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallet_Balance DEFAULT 0,

    HeldAmount DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallet_HeldAmount DEFAULT 0,

    Currency CHAR(3) NOT NULL
        CONSTRAINT DF_Wallet_Currency DEFAULT 'EGP',

    LastUpdated DATETIME2(3) NOT NULL
        CONSTRAINT DF_Wallet_LastUpdated DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Wallet PRIMARY KEY (MemberId),

    CONSTRAINT CK_Wallet_Balance
        CHECK (Balance >= 0),

    CONSTRAINT CK_Wallet_HeldAmount
        CHECK (HeldAmount >= 0 AND HeldAmount <= Balance)
);
GO

CREATE TABLE Operations.Warehouse
(
    WarehouseId INT IDENTITY(1,1) NOT NULL,
                CONSTRAINT PK_Warehouse
                        PRIMARY KEY (WarehouseId),
    Name NVARCHAR(80) NOT NULL,
              CONSTRAINT UQ_Warehouse_Name
                         UNIQUE (Name),
    Capacity INT NOT NULL,
               CONSTRAINT CK_Warehouse_Capacity
                         CHECK (Capacity > 0),
    CityId INT NOT NULL,
    Latitude DECIMAL(10,7) NOT NULL,
                CONSTRAINT CK_Warehouse_Latitude
                        CHECK (Latitude BETWEEN -90 AND 90),
    Longitude DECIMAL(10,7) NOT NULL,
                CONSTRAINT CK_Warehouse_Longitude
                        CHECK (Longitude BETWEEN -180 AND 180)
);
GO

CREATE TABLE Operations.Employee
(
    EmployeeId UNIQUEIDENTIFIER NOT NULL,
    WarehouseId INT NOT NULL,

    CONSTRAINT PK_Employee
        PRIMARY KEY (EmployeeId)
);
GO

CREATE TABLE Catalogue.Category
(
    CategoryId INT NOT NULL,
    NameEn VARCHAR(50) NOT NULL,
    NameAr NVARCHAR(50) NULL,
    CommissionRate DECIMAL(5,2) NOT NULL,
    ParentCategoryId INT NULL,

    CONSTRAINT PK_Category
        PRIMARY KEY (CategoryId),

    CONSTRAINT UQ_Category_NameEn
        UNIQUE (NameEn),

    CONSTRAINT CK_Category_CommissionRate
        CHECK (CommissionRate BETWEEN 0 AND 30)
);
GO

CREATE TABLE Catalogue.Photo
(
    ItemId INT NOT NULL,
    Position INT NOT NULL,
    Url VARCHAR(500) NOT NULL,

    IsMain BIT NOT NULL
        CONSTRAINT DF_Photo_IsMain DEFAULT 0,

    CONSTRAINT PK_Photo
        PRIMARY KEY (ItemId, Position),

    CONSTRAINT CK_Photo_Position
        CHECK (Position BETWEEN 1 AND 20)
);
GO

CREATE TABLE Catalogue.Item
(
    ItemId INT IDENTITY(1,1) NOT NULL,
    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ItemCondition INT NOT NULL,
    Specifications NVARCHAR(MAX) NOT NULL,
    SellerId UNIQUEIDENTIFIER NOT NULL,
    CategoryId INT NOT NULL,
    WarehouseId INT NULL,
    InspectorId UNIQUEIDENTIFIER NOT NULL,
    ListedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Item_ListedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Item PRIMARY KEY (ItemId),

    CONSTRAINT CK_Item_Condition
        CHECK (ItemCondition BETWEEN 1 AND 10),

    CONSTRAINT CK_Item_Specifications
        CHECK (ISJSON(Specifications) = 1),

    CONSTRAINT CK_Item_Seller_Inspector
        CHECK (SellerId <> InspectorId)
);
GO


CREATE TABLE Auction.Auction
(
    AuctionId INT IDENTITY(1,1) NOT NULL,
    ItemId INT NOT NULL,
    StartingPrice DECIMAL(12,2) NOT NULL,
    ReservePrice DECIMAL(12,2) NULL,

    BidIncrement DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Auction_BidIncrement DEFAULT 50,

    StartAt DATETIMEOFFSET NOT NULL,
    EndAt DATETIMEOFFSET NOT NULL,

    Status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Auction_Status DEFAULT 'Draft',

    CONSTRAINT PK_Auction PRIMARY KEY (AuctionId),

    CONSTRAINT CK_Auction_StartingPrice
        CHECK (StartingPrice > 0),

    CONSTRAINT CK_Auction_ReservePrice
        CHECK (ReservePrice IS NULL OR ReservePrice >= StartingPrice),

    CONSTRAINT CK_Auction_BidIncrement
        CHECK (BidIncrement > 0),

    CONSTRAINT CK_Auction_EndAt
        CHECK (EndAt > StartAt),

    CONSTRAINT CK_Auction_Status
        CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled'))
);
GO


CREATE TABLE Auction.Bid
(
    BidId BIGINT IDENTITY(1,1) NOT NULL,
    AuctionId INT NOT NULL,
    MemberId UNIQUEIDENTIFIER NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,

    PlacedAt DATETIME2(3) NOT NULL,

    DeviceIP VARCHAR(45) NOT NULL,

    CONSTRAINT PK_Bid PRIMARY KEY (BidId),

    CONSTRAINT UQ_Bid_AuctionId_Amount
        UNIQUE (AuctionId, Amount),

    CONSTRAINT CK_Bid_Amount
        CHECK (Amount > 0)
);
GO


CREATE TABLE Auction.Follow
(
    MemberId UNIQUEIDENTIFIER NOT NULL,
    AuctionId INT NOT NULL,

    FollowedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Follow_FollowedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Follow
        PRIMARY KEY (MemberId, AuctionId)
);
GO
