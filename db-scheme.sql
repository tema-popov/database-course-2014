# База данных симулирует работу почтового сервиса. Есть посылки (Mail), можно отслеживать их (tracking),
# в базе хранятся различные тарифы, адреса почтовых отделений,
# контролируется, на каком транспорте перемещаются посылки. Также, можно заказать курьерскую доставку и её стоимость.


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
(Id     INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
 Name   VARCHAR(100) NOT NULL,
 CityId INT          NOT NULL,
  UNIQUE (Name, CityId),
  FOREIGN KEY (CityId) REFERENCES Cities (Id))
  ENGINE InnoDB;

CREATE TABLE Address
(
  Id               INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  StreetId         INT NOT NULL,
  HouseNumber      INT NOT NULL,
  CorpusNumber     INT NOT NULL DEFAULT -1,
  ApartmentsNumber INT NOT NULL DEFAULT -1,
  UNIQUE (StreetId, HouseNumber, CorpusNumber, ApartmentsNumber),
  FOREIGN KEY (StreetId) REFERENCES Streets (Id)
)
  ENGINE InnoDB;

CREATE TABLE PostOffices (
  PostIndex INT NOT NULL PRIMARY KEY,
  AddressId INT NOT NULL UNIQUE,
  FOREIGN KEY (AddressId) REFERENCES Address (Id)
)
  ENGINE InnoDB;


CREATE TABLE FullAddress (
  Id         INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
  PostIndex  INT          NOT NULL,
  AddressId  INT          NOT NULL,
  PersonName VARCHAR(200) NOT NULL DEFAULT 'UNKNOWN',
  UNIQUE (PostIndex, AddressId, PersonName),
  FOREIGN KEY (AddressId) REFERENCES Address (Id),
  FOREIGN KEY (PostIndex) REFERENCES PostOffices (PostIndex)
)
  ENGINE InnoDB;


CREATE TABLE Transports (
  Id         INT                                                  NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Type       ENUM ('COURIER', 'SHIP', 'TRAIN', 'AIRPLANE', 'CAR') NOT NULL,
  RealLifeID VARCHAR(200)                                         NOT NULL,
  UNIQUE (Type, RealLifeID)
)
  ENGINE InnoDB;

CREATE TABLE Status (
  Id          INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Description VARCHAR(200) NOT NULL UNIQUE
)
  ENGINE InnoDB;

CREATE TABLE Tarification (
  Id          INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Name        VARCHAR(200)  NOT NULL UNIQUE,
  ConstPrice  DECIMAL(8, 2) NOT NULL,
  WeightPrice DECIMAL(8, 2) NOT NULL DEFAULT 0
)
  ENGINE InnoDB;

CREATE TABLE CourierService (
  Id     INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
  Name   VARCHAR(200),
  CityId INT           NOT NULL,
  Price  DECIMAL(8, 2) NOT NULL,
  UNIQUE (CityId, Name),
  FOREIGN KEY (CityId) REFERENCES Cities (Id)
)
  ENGINE InnoDB;


CREATE TABLE Mail (
  Id              INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
  FromFullAddress INT           NOT NULL,
  ToFullAddress   INT           NOT NULL,
  Weight          DECIMAL(6, 3) NOT NULL,
  Tariff          INT           NOT NULL,
  Price           DECIMAL(8, 2) NOT NULL,
  CourierService  INT           NULL,
  Time            TIMESTAMP     NOT NULL,
  TransportId     INT           NULL,
  FOREIGN KEY (FromFullAddress) REFERENCES FullAddress (Id),
  FOREIGN KEY (ToFullAddress) REFERENCES FullAddress (Id),
  FOREIGN KEY (Tariff) REFERENCES Tarification (Id),
  FOREIGN KEY (CourierService) REFERENCES CourierService (Id)
)
  ENGINE InnoDB;

# Для быстрых выборок по транспорту
ALTER TABLE Mail ADD INDEX (TransportId);

CREATE TABLE Tracking (
  MailId      INT       NOT NULL,
  AddressId   INT       NOT NULL,
  Time        TIMESTAMP NOT NULL,
  TransportId INT       NULL,
  StatusId    INT       NOT NULL,
  FOREIGN KEY (MailId) REFERENCES Mail (Id),
  FOREIGN KEY (AddressId) REFERENCES Address (Id),
  FOREIGN KEY (TransportId) REFERENCES Transports (Id),
  FOREIGN KEY (StatusId) REFERENCES Status (Id)
)
  ENGINE InnoDB;


# Быстрые выборки по времени и статусу
ALTER TABLE Tracking ADD INDEX (Time) USING BTREE,
ADD INDEX (StatusId) USING HASH;


DELIMITER $$

CREATE PROCEDURE addMail(send_name     VARCHAR(200), send_index INT, send_address_id INT,
                         receiver_name VARCHAR(200), receiver_index INT, receiver_address_id INT,
                         weight        DECIMAL(6, 3), tariff INT, courier_service INT)
  BEGIN
    DECLARE s_id, r_id, mail_id INT;
    DECLARE cost, weigth_cost, const_cost DECIMAL(8, 3);
    INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (send_index, send_address_id, send_name);
    SET s_id = (SELECT
                  Id
                FROM FullAddress
                WHERE (PostIndex, AddressId, PersonName) = (send_index, send_address_id, send_name));

    INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (receiver_index, receiver_address_id, receiver_name);
    SET r_id = (SELECT
                  Id
                FROM FullAddress
                WHERE (PostIndex, AddressId, PersonName) = (receiver_index, receiver_address_id, receiver_name));

    IF courier_service IS NOT NULL
    THEN
      SET cost = (SELECT
                    Price
                  FROM courierservice
                  WHERE id = courier_service);
    ELSE
      SET cost = 0;
    END IF;

    SELECT
      ConstPrice,
      WeightPrice
    INTO const_cost, weigth_cost
    FROM tarification
    WHERE id = tariff;

    SET cost = cost + const_cost + weigth_cost * weight;

    INSERT INTO Mail (FromFullAddress,
                      ToFullAddress,
                      Weight,
                      Tariff,
                      Price,
                      CourierService)
      VALUES (s_id, r_id, weight, tariff, cost, courier_service);

    SET mail_id = (SELECT
                     LAST_INSERT_ID());

    INSERT INTO Tracking (MailId, AddressId, StatusId) VALUES (mail_id, receiver_address_id, 1);

  END $$


DELIMITER ;



SELECT * FROM





