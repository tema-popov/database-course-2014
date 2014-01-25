INSERT INTO Countries (Name) VALUES ('Россия');

# next, run upload_test_data.py

# run it 5 times
INSERT IGNORE INTO Address (StreetId, HouseNumber, CorpusNumber, ApartmentsNumber)
  SELECT Id,  FLOOR(1 + RAND() * (10)), FLOOR(0 + RAND() * (3)), FLOOR(1 + RAND() * (200))
  from streets;

INSERT IGNORE INTO PostOffices (PostIndex, AddressId)
  SELECT FLOOR(100000 + RAND() * (900000)), Id from Address ORDER BY RAND() LIMIT 200;

SELECT a.Id, CONCAT('Страна: ', con.Name, ', ',
                    'Регион: ', r.Name, ', ',
                    IF(sr.Name != '', CONCAT('Район: ', sr.Name, ', '), ''),
                    'Город: ', c.Name, ', ',
                    'Улица: ', s.Name, ', ',
                    'Дом: ', a.ApartmentsNumber,
                    IF(a.CorpusNumber != 0, CONCAT('к', a.CorpusNumber), ''), ', ', 'Квартира: ', a.ApartmentsNumber) as Address from address a
  join streets s on (a.StreetId = s.Id)
  join cities c on (s.CityId = c.Id)
  join subregions sr on (c.SubregionId = sr.Id)
  join regions r on (sr.regionid = r.Id)
  join countries con on (r.CountryId = con.Id);


INSERT INTO CourierService (Name, CityId, Price) VALUES ('DHL', 1, 300), ('EMS', 1, 350), ('DHL', 2, 250), ('EMS', 2, 300);

INSERT INTO Transports (Type, RealLifeID) VALUES ('CAR', 'x777xx77');
INSERT INTO Transports (Type, RealLifeID) VALUES ('COURIER', 'Попов Артем Леонидович (1234 123456)');
INSERT INTO Transports (Type, RealLifeID) VALUES ('SHIP', 'S1');
INSERT INTO Transports (Type, RealLifeID) VALUES ('SHIP', 'S2');
INSERT INTO Transports (Type, RealLifeID) VALUES ('SHIP', 'S3');
INSERT INTO Transports (Type, RealLifeID) VALUES ('TRAIN', 'MOSKVA-SPB');
INSERT INTO Transports (Type, RealLifeID) VALUES ('TRAIN', 'SPB-MOSKVA');
INSERT INTO Transports (Type, RealLifeID) VALUES ('AIRPLANE', 'FV 156');


INSERT INTO Tarification (Name, ConstPrice, WeightPrice) VALUES ('Письмо', 10, 0), ('Бандероль', 100, 0), ('Посылка', 50, 200);

INSERT INTO Status (Description) VALUES ('Принято к отправлению'),
('Доставлено получателю'),
('В пути'),
('В сортировочном центре'),
('На таможне');


CALL addMail('Попов Артем Леонидович', 139301, 26, 'Кожевников Иван Андреевич', 831390, 28, 0.02, 3, 1);


SELECT * from MAIl where DATE_SUB(CURTIME(),INTERVAL 1 HOUR ) <= time;

SELECT * from tracking where DATE_SUB(CURTIME(),INTERVAL 1 HOUR ) <= time;


