# coding=utf-8
from decimal import Decimal
import random

__author__ = 'jambo'


import MySQLdb
db = MySQLdb.connect(user="root", db="mail", use_unicode=True)
c = db.cursor()

RECEIVED_STATUS = 1


def new_mail(send_name, send_index, send_address_id,
             reciever_name, reciever_index, reciever_address_id,
             weight, tariff, courier_service):
    weight = Decimal(weight)
    c.execute("START TRANSACTION")
    sender_params = (send_index, send_address_id, send_name)
    c.execute("INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (%s, %s, %s)", sender_params)

    c.execute("Select Id from FullAddress Where (PostIndex, AddressId, PersonName) = (%s, %s, %s)", sender_params)
    send_id = c.fetchone()[0]

    reciever_params = (reciever_index, reciever_address_id, reciever_name)
    c.execute("INSERT IGNORE INTO FullAddress (PostIndex, AddressId, PersonName) VALUES (%s, %s, %s)", reciever_params)
    c.execute("Select Id from FullAddress Where (PostIndex, AddressId, PersonName) = (%s, %s, %s)", reciever_params)
    recieve_id = c.fetchone()[0]

    if (courier_service):
        c.execute("select Price from courierservice where id = %s", (courier_service, ))
        courier_price = c.fetchone()[0]
    else:
        courier_price = 0

    c.execute("select ConstPrice, WeightPrice from tarification where id = %s", (tariff, ))
    const_price, weight_price = c.fetchone()
    price = courier_price + const_price + weight * weight_price

    c.execute("INSERT INTO Mail (FromFullAddress,"
                      "ToFullAddress,"
                      "Weight,"
                      "Tariff,"
                      "Price,"
                      "CourierService)"
    "VALUES (%s, %s, %s, %s, %s, %s)", (send_id, recieve_id, weight, tariff, price, courier_service if courier_service else None))

    c.execute("SELECT LAST_INSERT_ID()")
    mail_id, = c.fetchone()

    c.execute("INSERT INTO Tracking (MailId, AddressId, StatusId) VALUES (%s, %s, %s)", (mail_id, send_address_id, RECEIVED_STATUS))

    c.execute("COMMIT")






# names = (u"Иван Иванович Иванов", u"Сергей Сергеевич Сергеев", u"Федор Федорович Федоров", u"Алексей Алексеевич Алексеев")
#
# c.execute("select * from postoffices")
# addresses = list(c.fetchall())
#
# for _ in xrange(100000):
#     send_index, send_address = random.choice(addresses)
#     recieve_index, recieve_address = random.choice(addresses)
#     new_mail(random.choice(names), send_index, send_address, random.choice(names), recieve_index,
#              recieve_address, random.random(), random.randint(1, 3), random.randint(0, 1))
