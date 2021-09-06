# -*- coding: utf-8 -*-
"""
Created on Sat Aug 28 14:33:01 2021
script: connecting to mysql database
@author: Ashish
"""

from mysql.connector import connect, Error

def connect_mysql():
    try:
        with connect(
                host = "localhost",
                user = input("Enter mysql username: "),
                password = input("Enter database password: "),
                database = "sakila"
                ) as connection:
            print()
            
    except Error as err:
        print(err)
    
    return connection


cnx = connect_mysql()
cnx.reconnect()
# instantiate the connection

cursor = cnx.cursor()

# execute sql queries
# cursor.execute("show tables")
actor_info_query = "select * from actor_info limit 10"
cursor.execute(actor_info_query)
result = cursor.fetchall()
for row in result:
    print(row)

