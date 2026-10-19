"""Control de entrega: CSV -> tablas LaTeX -> PDF; no ejecuta análisis PCA.

Ejecutar desde la raíz con Python y pypdf. No modifica el informe.
"""
import csv
import hashlib
import re
from pathlib import Path
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'resultados/descriptivos_sensibilidades_20261018'
PDF = ROOT / 'docs/informe1_metodologico/Informe1_Metodologico.pdf'

def rows(path):
    with path.open(encoding='utf-8-sig', newline='') as f:
        return list(csv.DictReader(f))

def compact(s):
    return re.sub(r'\s+', '', s)

reader = PdfReader(PDF)
pages = [compact(p.extract_text()) for p in reader.pages]
checks = []
def check(name, ok):
    checks.append({'control': name, 'cumple': bool(ok)})

# Las cuatro filas se reconstruyen directamente desde el CSV numérico.
for r in rows(OUT / 'descriptivos_cuatro_informe.csv'):
    values = [r['n']] + [f"{100*float(r[k]):.2f}".replace('.', ',') for k in
        ('media','de_poblacional','mediana','q1','q3','minimo','maximo')]
    check('CSV descriptivos: ' + r['indicador'], any(''.join(values) in p for p in pages))

# Comprueba todas las filas numéricas de las cuatro tablas generadas por R.
for tex in sorted((OUT / 'tablas_tex').glob('*.tex')):
    for line in tex.read_text(encoding='utf-8').splitlines():
        cells = line.rstrip('\\ ').split('&')
        if len(cells) < 2 or not re.fullmatch(r'\s*\d+(?:,\d+)?\s*', cells[1]):
            continue
        numeric = compact(''.join(cells[1:]))
        check(tex.name + ': ' + cells[0].strip(), any(numeric in p for p in pages))

integrity = rows(OUT / 'integridad_insumos.csv')
check('Hashes de insumos conservados', all(r['sin_cambios']=='TRUE' for r in integrity))
state = {r['hecho']:r['valor'] for r in rows(OUT / 'resumen_ejecucion.csv')}
check('Sin PCA en esta corrida', state['PCA_ejecutado']=='FALSE')
check('Sin faltantes en matriz', state['NA_matriz']=='0')
check('Fórmulas sin discrepancias', state['violaciones_formulas']=='0')
log = (ROOT / 'docs/informe1_metodologico/main.log').read_text(encoding='utf-8', errors='replace')
check('Compilación sin referencias indefinidas ni desbordamientos', not re.search(
    r'undefined|Overfull|Missing character|LaTeX Warning|Package .* Warning', log))
with (OUT / 'verificacion_tablas_pdf.csv').open('w', encoding='utf-8', newline='') as f:
    w = csv.DictWriter(f, fieldnames=['control','cumple']); w.writeheader(); w.writerows(checks)
print(f'PDF: {len(reader.pages)} páginas; controles: {len(checks)}; fallos: {sum(not c["cumple"] for c in checks)}')
print('SHA256:', hashlib.sha256(PDF.read_bytes()).hexdigest())
assert all(c['cumple'] for c in checks), 'Revisar verificacion_tablas_pdf.csv'
