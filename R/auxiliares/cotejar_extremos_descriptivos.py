"""Cotejo independiente, de solo lectura, contra valores cacheados del Excel.
Ejecutar desde la raiz con Python + openpyxl (runtime incluido en Codex).
No realiza PCA ni modifica el libro. Depende de la salida de R/06.
"""
import csv
import hashlib
from pathlib import Path
import openpyxl

ROOT = Path.cwd()
OUT = ROOT / 'resultados/descriptivos_sensibilidades_20261018'
SOURCE = ROOT / 'datos/CUADROS_MUNICIPALES_UNIDOS.xlsx'
def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
before = digest(SOURCE)
with (OUT / 'extremos_z_mayor_4_para_cotejo.csv').open(encoding='utf-8') as f:
    extremes = list(csv.DictReader(f))
targets = {(x['codigo_municipio'], x['indicador']) for x in extremes}
found = {}
wb = openpyxl.load_workbook(SOURCE, read_only=True, data_only=True)
for sheet, offset, first in [('VIVIENDAS',44,4),('VIVIENDAS',69,3),('PERSONA_SOCIAL',0,3)]:
    dep = code = area = None
    for row_n,row in enumerate(wb[sheet].iter_rows(values_only=True),1):
        if row_n < first:
            continue
        a,b = row[offset:offset+2]
        if a is not None and str(a).strip():
            dep = str(a).strip().split('_')[0]
            code = area = None
        if b is not None and str(b).strip():
            raw = str(b).strip().split('_')[0]
            code = raw if len(raw)==5 else str(dep)+raw
            area = None
        if row[offset+2] is not None and str(row[offset+2]).strip():
            area = str(row[offset+2]).strip().lower()
        if not code or area not in ('total','total municipal'):
            continue
        if sheet=='PERSONA_SOCIAL':
            if str(row[3]).strip().lower()!='total':
                continue
            candidates = {'actividad_vulnerabilidad_10mas_5PM':
                          (float(row[7])+float(row[9])+2*float(row[13]),2*(float(row[4])-float(row[5])),'H+J+2N','2(E-F)')}
        elif offset==44:
            candidates = {'sin_energia_8V':(float(row[50]),float(row[48]),'AY','AW'),
                          'sin_internet_8V':(float(row[66]),float(row[64])-float(row[67]),'BO','BM-BP'),
                          'sin_gas_8V':(float(row[59]),float(row[57])-float(row[60]),'BH','BF-BI')}
        else:
            candidates = {'estratos_1_2_o_sin_estrato_10V':
                          (float(row[74])+float(row[75])+float(row[76]),sum(float(v) for v in row[74:81]),'BW+BX+BY','BW:CC')}
        for indicator,(n,d,cols_n,cols_d) in candidates.items():
            if (code,indicator) in targets:
                key = (code,indicator)
                if key in found:
                    raise ValueError(f'Fila fuente duplicada: {key}')
                found[key] = dict(hoja=sheet,fila_excel=row_n,numerador=n,denominador=d,
                                  columnas_numerador=cols_n,columnas_denominador=cols_d,valor_fuente=n/d)
wb.close()
rows = []
for e in extremes:
    key = (e['codigo_municipio'],e['indicador'])
    if key not in found:
        raise ValueError(f'No encontrado en libro: {key}')
    source = found[key]
    difference = float(e['valor'])-source['valor_fuente']
    rows.append({**e,**source,'diferencia':difference,'tolerancia':1e-12,'coincide':abs(difference)<1e-12})
with (OUT / 'cotejo_extremos_excel.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.DictWriter(f,fieldnames=list(rows[0])); writer.writeheader();writer.writerows(rows)
after = digest(SOURCE)
assert before==after
assert all(r['coincide'] for r in rows)
with (OUT / 'integridad_excel_cotejo.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f);writer.writerow(['archivo','sha256_antes','sha256_despues','sin_cambios'])
    writer.writerow([str(SOURCE.relative_to(ROOT)),before,after,before==after])
print(f'Cotejadas {len(rows)} celdas en {len({r["codigo_municipio"] for r in rows})} codigos; sin discrepancias; Excel inalterado.')
