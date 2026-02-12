# Guardar como subir_datos.py
import boto3
import os

session = boto3.Session(profile_name='inbest', region_name='us-east-1')
s3 = session.client('s3')
bucket_name = 'datalake-taxi-villarreal-2017'  # CAMBIAR

# Definir que archivo va a que zona y ruta
uploads = {
    'taxi_full.csv': 'landing/taxis/2017/taxi_full.csv',
    'taxi_enero.csv': 'landing/taxis/2017/enero/taxi_enero.csv',
    'taxi_tarjeta.csv': 'landing/taxis/2017/paytype_1/taxi_tarjeta.csv',
}

for local_file, s3_key in uploads.items():
    file_size = os.path.getsize(local_file)
    print(f"Subiendo {local_file} ({file_size:,} bytes) -> s3://{bucket_name}/{s3_key}")
    s3.upload_file(local_file, bucket_name, s3_key)

print("\nVerificando objetos en S3:")
response = s3.list_objects_v2(Bucket=bucket_name)
for obj in response.get('Contents', []):
    print(f"  {obj['Key']}  ({obj['Size']:,} bytes)")