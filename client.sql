-- Получить адрес в виде строки
SELECT Id, CONCAT('Страна: ', Country, ', ',
              'Регион: ', Region, ', ',
              IF(Subregion != '', CONCAT('Район: ', Subregion, ', '), ''),
              'Город: ', City, ', ',
              'Улица: ', Street, ', ',
              'Дом: ', ApartmentsNumber,
              IF(CorpusNumber != 0, CONCAT('к', CorpusNumber), ''), ', ', 'Квартира: ', ApartmentsNumber) as Address from AddressView;


CALL addMail('Попов Артем Леонидович', 139301, 26, 'Кожевников Иван Андреевич', 831390, 28, 0.02, 3, 1);


# Загрузить транспорт
START TRANSACTION;
UPDATE mail SET TransportId = 1 where id in (1, 2, 3);
INSERT INTO Tracking (MailId, AddressId, TransportId, StatusId)
  SELECT Id, 2512, TransportId, 3 from Mail where TransportId = 1;
COMMIT;


# Выгрузить весь груз в почтовом отделении с индексом
START TRANSACTION;
INSERT INTO Tracking (MailId, AddressId, StatusId)
  SELECT Id, po.AddressId, 6 from Mail m join PostOffices po on (po.PostIndex = 139301)
    where TransportId = 1;
UPDATE Mail set TransportId = NULL where TransportId = 1;
COMMIT;


# Посмотреть трек
SELECT * from Tracking where MailId = 100001;

# Получить груз в конкретном отделении
INSERT INTO Tracking (MailId, AddressId, StatusId) VALUES (100001, 26, 2);


# Самые медленные адреса по городам
SELECT
  MaxTime,
  t1.MailId,
  av.*
FROM Tracking t1 JOIN Tracking t2
    ON (t1.MailId = t2.MailId AND t1.StatusId = 1 AND t2.StatusId = 2)
  JOIN AddressView av
    ON (t2.AddressId = av.Id)
  JOIN (SELECT
          MAX((t2.Time - t1.Time)) AS MaxTime,
          av.City
        FROM Tracking t1 JOIN Tracking t2
            ON (t1.MailId = t2.MailId AND t1.StatusId = 1 AND t2.StatusId = 2)
          JOIN AddressView av
            ON (t2.AddressId = av.Id)
        GROUP BY City
       ) max on (max.City = av.City)
WHERE MaxTime = (t2.Time - t1.Time);



