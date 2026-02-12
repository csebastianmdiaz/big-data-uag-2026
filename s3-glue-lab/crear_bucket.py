# Guardar como crear_bucket.py
import boto3
from botocore.exceptions import ClientError

session = boto3.Session(profile_name='inbest', region_name='us-east-1')
s3 = session.client('s3')

bucket_name = 'datalake-taxi-villarreal-2017'  # CAMBIAR

try:
    # En us-east-1 no se especifica LocationConstraint
    s3.create_bucket(Bucket=bucket_name)
    print(f"Bucket creado: {bucket_name}")
except ClientError as e:
    error_code = e.response['Error']['Code']
    if error_code == 'BucketAlreadyOwnedByYou':
        print(f"El bucket {bucket_name} ya existe en tu cuenta.")
    elif error_code == 'BucketAlreadyExists':
        print(f"ERROR: El nombre {bucket_name} ya esta en uso por otra cuenta.")
        print("Cambia TUAPELLIDO por algo unico.")
    else:
        raise