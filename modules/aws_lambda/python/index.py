import os
import psycopg2 as pg

database_name = "videotrendingdb"
table_name = "cities"
username = os.environ['username']
password = os.environ['password']
port = os.environ['port']
host_name = os.environ['host']


def lambda_handler(event, context):
    cxn = pg.connect(user=username,
                     password=password,
                     host=host_name,
                     port=port,
                     database=database_name)

    print(cxn)