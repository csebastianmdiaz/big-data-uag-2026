# Guardar como test_boto3.py y ejecutar: python test_boto3.py
import boto3

session = boto3.Session(profile_name='inbest', region_name='us-east-1')
sts = session.client('sts')
identity = sts.get_caller_identity()
print(f"Cuenta AWS: {identity['Account']}")
print(f"ARN: {identity['Arn']}")
print("boto3 configurado correctamente.")