CREATE TABLE Countries (Id   INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
                        Name VARCHAR(100) NOT NULL UNIQUE)
  ENGINE InnoDB;

CREATE TABLE Regions
(Id        INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
 Name      VARCHAR(100) NOT NULL,
 CountryId INT          NOT NULL,
  UNIQUE (Name, CountryId),
  FOREIGN KEY (CountryId) REFERENCES Countries (Id))
  ENGINE InnoDB;

CREATE TABLE Subregions
(Id       INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
 Name     VARCHAR(100) NOT NULL,
 RegionId INT          NOT NULL,
  UNIQUE (Name, RegionId),
  FOREIGN KEY (RegionId) REFERENCES Regions (Id))
  ENGINE InnoDB;

CREATE TABLE Cities
(Id          INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
 Name        VARCHAR(100) NOT NULL,
 SubregionId INT          NOT NULL,
  UNIQUE (Name, SubregionId),
  FOREIGN KEY (SubregionId) REFERENCES Subregions (Id))
  ENGINE InnoDB;

CREATE TABLE Streets
(Id          INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
 Name        VARCHAR(100) NOT NULL,
 CityId INT          NOT NULL,
  UNIQUE (Name, CityId),
  FOREIGN KEY (CityId) REFERENCES Cities (Id))
  ENGINE InnoDB;

CREATE TABLE Address
(
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  StreetId INT NOT NULL,
  HouseNumber INT NOT NULL,
  CorpusNumber INT NOT NULl DEFAULT -1,
  ApartmentsNumber INT NOT NULL DEFAULT -1,
  UNIQUE (StreetId, HouseNumber, CorpusNumber, ApartmentsNumber),
  FOREIGN KEY (StreetId) REFERENCES Streets (Id)
) ENGINE InnoDB;

CREATE TABLE PostOffices (
  PostIndex INT NOT NULL PRIMARY KEY,
  AddressId INT NOT NULL UNIQUE,
  FOREIGN KEY (AddressId) REFERENCES Address (Id)
) ENGINE InnoDB;


# Вроде бы это ассоциация, но у каждого письма обязательно должны быть отправления туда и обратно.
# Выходит, без айддишника никак. Иначе непонятно, как поддерживать обязательность связи.
CREATE TABLE FullAddress (
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  PostIndex INT NOT NULL,
  AddressId INT NOT NULL,
  PersonName VARCHAR(200) NOT NULL DEFAULT 'UNKNOWN',
  UNIQUE (PostIndex, AddressId, PersonName),
  FOREIGN KEY (AddressId) REFERENCES Address (Id),
  FOREIGN KEY (PostIndex) REFERENCES PostOffices (PostIndex)
) ENGINE InnoDB;

CREATE TABLE Transports (
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Type ENUM ('COURIER', 'SHIP', 'TRAIN', 'AIRPLANE', 'CAR') NOT NULL,
  RealLifeID VARCHAR(200) NOT NULL,
  UNIQUE (Type, RealLifeID)
) ENGINE InnoDB;

CREATE TABLE Status (
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Description VARCHAR(200) NOT NULL UNIQUE
) ENGINE InnoDB;

CREATE TABLE Tarification (
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(200) NOT NULL UNIQUE,
  ConstPrice DECIMAL(8, 2) NOT NULL,
  WeightPrice DECIMAL(8, 2) NOT NULL DEFAULT 0
) ENGINE InnoDB;

CREATE TABLE CourierService (
  Id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(200),
  CityId INT NOT NULL,
  Price DECIMAL(8, 2) NOT NULL,
  UNIQUE (CityId, Name),
  FOREIGN KEY (CityId) REFERENCES Cities (Id)
) ENGINE InnoDB;


CREATE TABLE Mail(
  ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  FromFullAddress INT NOT NULL,
  ToFullAddress INT NOT NULL,
  Weight DECIMAL(6, 3) NOT NULL,
  Tariff INT NOT NULL,
  Price DECIMAL(8, 2) NOT NULL,
  CourierService INT NULL,
  Time TIMESTAMP NOT NULL,
  TransportId INT NULL,
  FOREIGN KEY (FromFullAddress) REFERENCES FullAddress (Id),
  FOREIGN KEY (ToFullAddress) REFERENCES FullAddress (Id),
  FOREIGN KEY (Tariff) REFERENCES Tarification (Id),
  FOREIGN KEY (CourierService) REFERENCES CourierService (Id)
) ENGINE InnoDB;

CREATE TABLE Tracking (
  MailId INT NOT NULL,
  AddressId INT NOT NULL,
  Time TIMESTAMP NOT NULL,
  TransportId INT NULL,
  StatusId INT NOT NULL,
  FOREIGN KEY (MailId) REFERENCES Mail (Id),
  FOREIGN KEY (AddressId) REFERENCES Address (Id),
  FOREIGN KEY (TransportId) REFERENCES Transports (Id),
  FOREIGN KEY (StatusId) REFERENCES Status (Id)
) ENGINE InnoDB;



