__author__ = 'jambo'

import MySQLdb
db = MySQLdb.connect(user="root", db="mail", use_unicode=True)

def read_from_file(filename):
    with open(filename, mode="r") as file:
        return [line.strip().decode('utf8') for line in file.readlines()]


regions = read_from_file("../regions.csv")
cities = read_from_file("../cities.csv")
streets = read_from_file("../streets.csv")

c = db.cursor()

# print c.execute(
#     u'INSERT INTO Regions (Name, CountryId) VALUES %s'
#     % u", ".join([u"('%s', 1)" % region for region in regions])
# )
#
# print c.execute(
#     "INSERT INTO Subregions (Name, RegionId) "
#     "SELECT '', r.Id from Regions r"
# )

# Cities have to be matched by hand

# c.execute(
#     "SELECT Id FROM Subregions LIMIT 1"
# )
#
# _id = c.fetchone()[0]
#
# print c.execute(
#     u'INSERT INTO Cities (Name, SubregionId) VALUES %s'
#     % u", ".join([u"('%s', %d)" % (city, _id) for city in cities])
# )

# c.execute(
#     u'SELECT Id from Cities'
# )
# ids = [row[0] for row in c.fetchall()]
# import random
#
#
# print c.execute(
#     u'INSERT INTO Streets (Name, CityId) VALUES %s'
#     % u", ".join([u"('%s', %d)" % (street, random.choice(ids)) for street in streets])
# )

# print id

db.commit()



