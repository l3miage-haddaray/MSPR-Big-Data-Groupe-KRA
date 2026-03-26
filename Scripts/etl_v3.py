"""
========================================================
ETL PIPELINE v3 - MSPR Electio-Analytics
Département du Rhône (69)
========================================================
Principe : Extract → Filter(dep=69) → Load
Aucun calcul, aucune modification de structure.
Les fichiers output ont exactement le même format
que les fichiers sources.
========================================================
"""

import pandas as pd
import numpy as np
import os
import glob
import warnings
warnings.filterwarnings('ignore')

# ============================================================
# CONFIGURATION
# ============================================================

BASE_PATH   = "/Users/kchaou/Desktop/MSPR DATA"
OUTPUT_PATH = os.path.join(BASE_PATH, "output")
os.makedirs(OUTPUT_PATH, exist_ok=True)

DEP_CODE = "69"

print("=" * 60)
print("ETL v3 — Electio-Analytics — Rhône (69)")
print("Principe : filtre dep=69, format source conservé")
print("=" * 60)


# ============================================================
# UTILITAIRE — Lecture CSV propre
# ============================================================

def read_csv_clean(path, sep=',', **kwargs):
    """Lit un CSV avec détection automatique encodage et BOM"""
    for enc in ['utf-8-sig', 'utf-8', 'latin-1']:
        try:
            df = pd.read_csv(path, encoding=enc, sep=sep, **kwargs)
            # Nettoyer BOM dans les noms de colonnes
            df.columns = [
                c.replace('\ufeff', '').replace('ï»¿', '').strip()
                for c in df.columns
            ]
            return df, enc
        except Exception:
            continue
    raise ValueError(f"Impossible de lire : {path}")

def save_clean(df, filename):
    """Sauvegarde en UTF-8 avec BOM pour compatibilité Excel"""
    path = os.path.join(OUTPUT_PATH, filename)
    df.to_csv(path, index=False, encoding='utf-8-sig')
    size = os.path.getsize(path) / 1024
    print(f"    ✓ {filename} — {len(df):,} lignes × {len(df.columns)} colonnes — {size:.1f} Ko")


# ============================================================
# 1. ÉLECTIONS
# ============================================================

print("\n[1/6] ÉLECTIONS...")

df, enc = read_csv_clean(
    os.path.join(BASE_PATH, "general_results.csv"),
    sep=None, engine='python'
)
print(f"    Source : {len(df):,} lignes × {len(df.columns)} colonnes (encodage: {enc})")
print(f"    Colonnes : {df.columns.tolist()}")

# Filtre département 69
df_out = df[df['code_departement'].astype(str) == DEP_CODE].copy()
print(f"    Après filtre dep=69 : {len(df_out):,} lignes")

save_clean(df_out, "elections_rhone.csv")


# ============================================================
# 2. POPULATION
# ============================================================

print("\n[2/6] POPULATION...")

df = pd.read_excel(
    os.path.join(BASE_PATH, "POPULATION_MUNICIPALE_COMMUNES_FRANCE.xlsx"),
    engine='openpyxl'
)
print(f"    Source : {len(df):,} lignes × {len(df.columns)} colonnes")
print(f"    Colonnes : {df.columns.tolist()}")

# Identifier colonne département
dep_col = None
for col in df.columns:
    if str(col).lower() in ['dep', 'code_dep', 'departement', 'dept']:
        dep_col = col
        break
if not dep_col:
    # Chercher par contenu
    for col in df.columns:
        vals = df[col].dropna().astype(str).str.zfill(2).unique()
        if DEP_CODE in vals:
            dep_col = col
            break

print(f"    Colonne département identifiée : {dep_col}")
df_out = df[df[dep_col].astype(str).str.zfill(2) == DEP_CODE].copy()
print(f"    Après filtre dep=69 : {len(df_out):,} lignes")

save_clean(df_out, "population_rhone.csv")


# ============================================================
# 3. SÉCURITÉ
# ============================================================

print("\n[3/6] SÉCURITÉ...")

secu_files = glob.glob(os.path.join(BASE_PATH, "donnee-dep*.csv"))
df, enc = read_csv_clean(secu_files[0], sep=None, engine='python')

# Nettoyer nom première colonne (souvent pollué par BOM)
df.columns.values[0] = 'Code_departement'
print(f"    Source : {len(df):,} lignes × {len(df.columns)} colonnes (encodage: {enc})")
print(f"    Colonnes : {df.columns.tolist()}")

df_out = df[df['Code_departement'].astype(str) == DEP_CODE].copy()
print(f"    Après filtre dep=69 : {len(df_out):,} lignes")

save_clean(df_out, "securite_rhone.csv")


# ============================================================
# 4. EMPLOI / CHÔMAGE (DARES)
# ============================================================

print("\n[4/6] EMPLOI...")

emploi_files = glob.glob(os.path.join(BASE_PATH, "dares*.csv"))
df, enc = read_csv_clean(emploi_files[0], sep=None, engine='python')
print(f"    Source : {len(df):,} lignes × {len(df.columns)} colonnes (encodage: {enc})")
print(f"    Colonnes : {df.columns.tolist()}")

# Identifier colonne département
dep_col_e = None
for col in df.columns:
    if 'partement' in col.lower() and 'code' in col.lower():
        dep_col_e = col
        break
if not dep_col_e:
    for col in df.columns:
        if 'partement' in col.lower():
            dep_col_e = col
            break

print(f"    Colonne département identifiée : {dep_col_e}")
df_out = df[df[dep_col_e].astype(str).str.zfill(2) == DEP_CODE].copy()
print(f"    Après filtre dep=69 : {len(df_out):,} lignes")
print(f"    Tranches d'âge : {df_out[df_out.columns[-2]].unique() if len(df_out.columns) >= 2 else 'N/A'}")

save_clean(df_out, "emploi_rhone.csv")


# ============================================================
# 5. FILOSOFI — PAUVRETÉ / REVENUS
# ============================================================

print("\n[5/6] FILOSOFI...")

filo_saved = []

# --- 2015 ---
filo_2015 = os.path.join(BASE_PATH, "base-cc-filosofi-2015.xls")
if os.path.exists(filo_2015):
    try:
        df = pd.read_excel(filo_2015, sheet_name='COM', header=5, engine='xlrd')
        df.columns = [str(c).strip() for c in df.columns]
        code_col = df.columns[0]
        df['dep'] = df[code_col].astype(str).str[:2]
        df_out = df[df['dep'] == DEP_CODE].drop(columns=['dep']).copy()
        print(f"    Filosofi 2015 : {len(df_out)} communes × {len(df_out.columns)} colonnes")
        save_clean(df_out, "filosofi_2015_rhone.csv")
        filo_saved.append(2015)
    except ImportError:
        print("    [!] xlrd manquant — pip install xlrd")
    except Exception as e:
        print(f"    [!] Filosofi 2015 erreur : {e}")

# --- 2016 ---
filo_2016 = os.path.join(BASE_PATH, "base-cc-filosofi-2016.xls")
if os.path.exists(filo_2016):
    try:
        df = pd.read_excel(filo_2016, sheet_name='COM', header=5, engine='xlrd')
        df.columns = [str(c).strip() for c in df.columns]
        code_col = df.columns[0]
        df['dep'] = df[code_col].astype(str).str[:2]
        df_out = df[df['dep'] == DEP_CODE].drop(columns=['dep']).copy()
        print(f"    Filosofi 2016 : {len(df_out)} communes × {len(df_out.columns)} colonnes")
        save_clean(df_out, "filosofi_2016_rhone.csv")
        filo_saved.append(2016)
    except ImportError:
        print("    [!] xlrd manquant — pip install xlrd")
    except Exception as e:
        print(f"    [!] Filosofi 2016 erreur : {e}")

# --- 2017 : fichier COM.CSV ---
filo_2017 = os.path.join(BASE_PATH, "base-filosofi-2017_CSV", "cc_filosofi_2017_COM.CSV")
if os.path.exists(filo_2017):
    df, enc = read_csv_clean(filo_2017, sep=';')
    print(f"    Filosofi 2017 colonnes : {df.columns.tolist()[:5]}...")
    code_col = df.columns[0]  # CODGEO
    df_out = df[df[code_col].astype(str).str[:2] == DEP_CODE].copy()
    print(f"    Filosofi 2017 : {len(df_out)} communes × {len(df_out.columns)} colonnes")
    save_clean(df_out, "filosofi_2017_rhone.csv")
    filo_saved.append(2017)

# --- 2018 : fichier IRIS ---
filo_2018_candidates = [
    os.path.join(BASE_PATH, "BASE_TD_FILO_DEC_IRIS_2018 2", "BASE_TD_FILO_DEC_IRIS_2018.csv"),
    os.path.join(BASE_PATH, "BASE_TD_FILO_DEC_IRIS_2018.csv"),
]
for filo_2018 in filo_2018_candidates:
    if os.path.exists(filo_2018):
        df, enc = read_csv_clean(filo_2018, sep=';')
        print(f"    Filosofi 2018 colonnes : {df.columns.tolist()}")
        # Code commune = 5 premiers chiffres du code IRIS
        df_out = df[df['IRIS'].astype(str).str[:2] == DEP_CODE].copy()
        print(f"    Filosofi 2018 (IRIS) : {len(df_out)} lignes × {len(df_out.columns)} colonnes")
        save_clean(df_out, "filosofi_2018_iris_rhone.csv")
        filo_saved.append(2018)
        break

print(f"    Années Filosofi sauvegardées : {filo_saved}")


# ============================================================
# 6. VIE ASSOCIATIVE (RNA)
# ============================================================

print("\n[6/6] RNA — VIE ASSOCIATIVE...")

rna_file = os.path.join(BASE_PATH, "rna_waldec_20260306",
                        f"rna_waldec_20260306_dpt_{DEP_CODE}.csv")

if os.path.exists(rna_file):
    try:
        df = pd.read_csv(rna_file, sep=';', encoding='utf-8', low_memory=False)
    except:
        df = pd.read_csv(rna_file, sep=';', encoding='latin-1', low_memory=False)

    print(f"    Source : {len(df):,} lignes × {len(df.columns)} colonnes")
    print(f"    Colonnes : {df.columns.tolist()[:8]}...")

    # Le fichier est déjà filtré sur le département 69
    # On garde tel quel — même format source
    save_clean(df, "associations_rhone.csv")
else:
    print(f"    [!] Fichier RNA 69 non trouvé : {rna_file}")


# ============================================================
# RÉSUMÉ FINAL
# ============================================================

print("\n" + "=" * 60)
print("RÉSUMÉ ETL v3 — Fichiers output :")
print("=" * 60)
print(f"{'Fichier':<45} {'Lignes':>8}  {'Colonnes':>9}  {'Taille':>8}")
print("-" * 75)

for f in sorted(glob.glob(os.path.join(OUTPUT_PATH, "*.csv"))):
    df_check = pd.read_csv(f, nrows=0, encoding='utf-8-sig')
    nb_lignes = sum(1 for _ in open(f, encoding='utf-8-sig')) - 1
    size_ko   = os.path.getsize(f) / 1024
    print(f"  {os.path.basename(f):<43} {nb_lignes:>8,}  {len(df_check.columns):>9}  {size_ko:>7.1f} Ko")

print("\nETL v3 terminé — Format source conservé")
print("=" * 60)
