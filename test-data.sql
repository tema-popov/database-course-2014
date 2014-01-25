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

DELIMITER $$

create procedure addMail(send_name varchar(200) , send_index int, send_address_id int,
                         reciever_name varchar(200), reciever_index int, reciever_address_id int,
                         weight decimal(6, 3), tariff int, courier_service int)
  BEGIN
    declare s_id, r_id, mail_id int;
    declare cost, weigth_cost, const_cost decimal(8, 3);
    INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (send_index, send_address_id, send_name);
    set s_id = (Select Id from FullAddress Where (PostIndex, AddressId, PersonName) = (send_index, send_address_id, send_name));

    INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (reciever_index, reciever_address_id, reciever_name);
    set r_id = (Select Id from FullAddress Where (PostIndex, AddressId, PersonName) = (reciever_index, reciever_address_id, reciever_name));

    if courier_service is not NULL then
      set cost = (select Price from courierservice where id = courier_service);
    else
      set cost = 0;
    end if;

    select ConstPrice, WeightPrice into const_cost, weigth_cost from tarification where id = tariff;

    set cost = cost + const_cost + weigth_cost * weight;

    INSERT INTO Mail (FromFullAddress,
                      ToFullAddress,
                      Weight,
                      Tariff,
                      Price,
                      CourierService)
      VALUES (s_id, r_id, weight, tariff, cost, courier_service);

    set mail_id = (SELECT LAST_INSERT_ID());

    INSERT INTO Tracking (MailId, AddressId, StatusId) VALUES (mail_id, reciever_address_id, 1);

  END $$


DELIMITER ;

CALL addMail('Попов Артем Леонидович', 139301, 26, 'Кожевников Иван Андреевич', 831390, 28, 0.02, 3, 1);



SELECT * from MAIl where DATE_SUB(CURTIME(),INTERVAL 1 HOUR ) <= time;
SELECT * from tracking where DATE_SUB(CURTIME(),INTERVAL 1 HOUR ) <= time;


# Загрузить транспорт
START TRANSACTION;
UPDATE mail SET TransportId = 1 where id in (1, 2, 3);
INSERT INTO Tracking (MailId, AddressId, TransportId, StatusId)
  SELECT Id, 2512, TransportId, 3 from Mail where TransportId = 1;
COMMIT;