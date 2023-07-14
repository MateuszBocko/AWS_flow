import os
import psycopg2 as pg
import pandas as pd
import boto3
import io

database_name = os.environ['db_name']
username = os.environ['username']
password = os.environ['password']
port = os.environ['port']
host_name = os.environ['host']
s3_bucket_name = os.environ['s3_bucket_name']

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    cxn = pg.connect(user=username,
                     password=password,
                     host=host_name,
                     port=port,
                     database=database_name)

    print(cxn)
    #
    # obj = s3_client.get_object(Bucket=s3_bucket_name, Key=csv_filename)
    # # This should prevent the 2GB download limit from a python ssl internal
    # chunks = (chunk for chunk in obj["Body"].iter_chunks(chunk_size=1024 ** 3))
    # data = io.BytesIO(b"".join(chunks))  # This keeps everything fully in memory
    # df = pd.read_csv(data)  # here you can provide also some necessary args and kwargs


    # read the s3 data into df
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    s3_file_name = event["Records"][0]["s3"]["object"]["key"]
    obj = s3_client.get_object(Bucket=bucket_name, Key=s3_file_name)
    df = pd.read_csv(obj['Body'])  # 'Body' is a key word

    temp = "CREATE EXTENSION aws_commons; CREATE EXTENSION aws_s3"
    query = """
        CREATE EXTENSION aws_s3;
        SELECT aws_s3.table_import_from_s3(
            'cities',
            '',
            '(format csv)',
            aws_commons.create_s3_uri(
                'videotrendingdb',
                'cities.csv',
                'eu-central-1'
                )
                )
                """
    # query to upload the data
    query_create = """
    CREATE TABLE [IF NOT EXISTS] cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL,
    population INT NOT NULL
    );"""
    csr = cxn.cursor()
    csr.execute(query_create)
    cxn.commit()

    # # get the data from
    # cursor = cxn.cursor()
    # query_create_table = f"SELECT * FROM cities"
    # cursor.execute(query_create_table)
    # random_record = cursor.fetchall()