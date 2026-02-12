# Guardar como crear_dataset.py y ejecutar: python crear_dataset.py
import csv
import random
from datetime import datetime, timedelta

# Generar 500 registros de viajes en taxi
# Esto es un SUBSET del dataset real del lab (que tiene millones de registros)
header = ['vendor', 'pickup', 'dropoff', 'count', 'distance',
          'ratecode', 'storeflag', 'pulocid', 'dolocid',
          'paytype', 'fare', 'extra', 'mta_tax', 'tip',
          'tolls', 'surcharge', 'total']

random.seed(42)  # Semilla fija para resultados reproducibles

def generar_viaje(mes):
    """Genera un registro de viaje aleatorio para un mes dado."""
    vendor = random.choice(['1', '2'])
    dia = random.randint(1, 28)
    hora = random.randint(0, 23)
    minuto = random.randint(0, 59)

    pickup = datetime(2017, mes, dia, hora, minuto, 0)
    duracion = random.randint(5, 60)  # minutos
    dropoff = pickup + timedelta(minutes=duracion)

    distance = random.randint(1, 25)
    fare = round(2.50 + distance * 2.50, 2)
    tip = round(fare * random.uniform(0, 0.30), 2)
    # paytype: 1=tarjeta, 2=efectivo, 3=sin cargo, 4=disputa
    paytype = random.choices(['1', '2', '3', '4'], weights=[50, 40, 5, 5])[0]
    # Si paga en efectivo, la propina registrada suele ser 0
    if paytype == '2':
        tip = 0.00
    total = round(fare + tip + 0.50 + 0.30, 2)  # fare + tip + mta_tax + surcharge

    return [vendor, pickup.strftime('%Y-%m-%d %H:%M:%S'),
            dropoff.strftime('%Y-%m-%d %H:%M:%S'),
            random.randint(1, 4), distance, '1', 'Y',
            str(random.randint(1, 265)), str(random.randint(1, 265)),
            paytype, fare, 0.00, 0.50, tip, 0.00, 0.30, total]


# Dataset completo: enero a marzo 2017
with open('taxi_full.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    for mes in [1, 2, 3]:
        for _ in range(200):
            writer.writerow(generar_viaje(mes))

# Dataset solo enero (para ejercicio de bucketizacion)
with open('taxi_enero.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    for _ in range(200):
        writer.writerow(generar_viaje(1))

# Dataset solo pagos con tarjeta (para ejercicio de particiones)
with open('taxi_tarjeta.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    with open('taxi_full.csv', 'r') as full:
        reader = csv.DictReader(full)
        for row in reader:
            if row['paytype'] == '1':
                writer.writerow([row[h] for h in header])

print("Archivos creados:")
print("  taxi_full.csv     - 600 registros (ene-mar 2017)")
print("  taxi_enero.csv    - 200 registros (solo enero)")
print("  taxi_tarjeta.csv  - ~300 registros (solo pagos con tarjeta)")