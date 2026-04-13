"""
normalisation.py — Electio-Analytics — Rhône (69)

Entrée  : fichiers dans /output
Sortie  : fichiers corrigés dans /output/normalise

Opérations :
  NORMALISATION FORMAT
    1. securite_rhone.csv        → taux_pour_mille : virgules → points
    2. Tous les fichiers         → codes communes en string 5 chiffres
    3. Tous les fichiers         → toutes valeurs numériques arrondies à 2 décimales
    4. associations_rhone.csv    → colonne id : suppression du W (ex: W691051652 → 691051652)

  TRANSFORMATION ETL
    5. filosofi_2018_iris_rhone  → IRIS (9 chiffres) → code_commune (5 chiffres)
                                   + agrégation par commune (moyenne des indicateurs)
                                   → 1 ligne par commune comme 2016 et 2017
"""

import os
import pandas as pd

BASE_PATH  = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR  = os.path.join(BASE_PATH, "output")
OUTPUT_DIR = os.path.join(BASE_PATH, "output", "normalise")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def round_numerics(df):
    """Arrondir toutes les colonnes numériques à 2 décimales."""
    for col in df.select_dtypes(include="number").columns:
        df[col] = df[col].round(2)
    return df

def save_clean(df, filename):
    path = os.path.join(OUTPUT_DIR, filename)
    df.to_csv(path, index=False, encoding="utf-8")
    print(f"    ✓ {filename} — {len(df)} lignes × {len(df.columns)} colonnes")

print("=" * 60)
print("NORMALISATION & TRANSFORMATION — Electio-Analytics")
print("=" * 60)

# ─────────────────────────────────────────────────────────
# 1. SÉCURITÉ — virgules → points + arrondi 2 décimales
# ─────────────────────────────────────────────────────────
print("\n[1/8] SÉCURITÉ — taux_pour_mille virgules → points + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "securite_rhone.csv"), encoding="utf-8-sig")
df["taux_pour_mille"] = (
    df["taux_pour_mille"]
    .astype(str)
    .str.replace(",", ".", regex=False)
)
df["taux_pour_mille"] = pd.to_numeric(df["taux_pour_mille"], errors="coerce")
df = round_numerics(df)
print(f"    Exemple taux_pour_mille : {df['taux_pour_mille'].head(3).tolist()}")
save_clean(df, "securite_rhone.csv")

# ─────────────────────────────────────────────────────────
# 2. ÉLECTIONS — code_commune 5 chiffres + arrondi
# ─────────────────────────────────────────────────────────
print("\n[2/8] ÉLECTIONS — code_commune → 5 chiffres + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "elections_rhone.csv"), encoding="utf-8-sig", dtype={"code_commune": str})
df["code_commune"] = df["code_commune"].astype(str).str.zfill(5)
df = round_numerics(df)
print(f"    Exemple code_commune : {df['code_commune'].head(3).tolist()}")
save_clean(df, "elections_rhone.csv")

# ─────────────────────────────────────────────────────────
# 3. EMPLOI — Code commune 5 chiffres + arrondi
# ─────────────────────────────────────────────────────────
print("\n[3/8] EMPLOI — Code commune → 5 chiffres + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "emploi_rhone.csv"), encoding="utf-8-sig", dtype={"Code commune": str})
df["Code commune"] = df["Code commune"].astype(str).str.zfill(5)
df = round_numerics(df)
print(f"    Exemple Code commune : {df['Code commune'].head(3).tolist()}")
save_clean(df, "emploi_rhone.csv")

# ─────────────────────────────────────────────────────────
# 4. POPULATION — codgeo 5 chiffres + arrondi
# ─────────────────────────────────────────────────────────
print("\n[4/8] POPULATION — codgeo → 5 chiffres + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "population_rhone.csv"), encoding="utf-8-sig", dtype={"codgeo": str})
df["codgeo"] = df["codgeo"].astype(str).str.zfill(5)
df = round_numerics(df)
print(f"    Exemple codgeo : {df['codgeo'].head(3).tolist()}")
save_clean(df, "population_rhone.csv")

# ─────────────────────────────────────────────────────────
# 5. FILOSOFI 2016 — CODGEO 5 chiffres + arrondi
# ─────────────────────────────────────────────────────────
print("\n[5/8] FILOSOFI 2016 — CODGEO → 5 chiffres + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "filosofi_2016_rhone.csv"), encoding="utf-8-sig", dtype={"CODGEO": str})
df["CODGEO"] = df["CODGEO"].astype(str).str.zfill(5)
df = round_numerics(df)
print(f"    Exemple CODGEO : {df['CODGEO'].head(3).tolist()}")
save_clean(df, "filosofi_2016_rhone.csv")

# ─────────────────────────────────────────────────────────
# 6. FILOSOFI 2017 — CODGEO 5 chiffres + arrondi
# ─────────────────────────────────────────────────────────
print("\n[6/8] FILOSOFI 2017 — CODGEO → 5 chiffres + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "filosofi_2017_rhone.csv"), encoding="utf-8-sig", dtype={"CODGEO": str})
df["CODGEO"] = df["CODGEO"].astype(str).str.zfill(5)
df = round_numerics(df)
print(f"    Exemple CODGEO : {df['CODGEO'].head(3).tolist()}")
save_clean(df, "filosofi_2017_rhone.csv")

# ─────────────────────────────────────────────────────────
# 7. ASSOCIATIONS — adrs_codeinsee 5 chiffres + suppression W dans id + arrondi
# ─────────────────────────────────────────────────────────
print("\n[7/8] ASSOCIATIONS — adrs_codeinsee → 5 chiffres + suppression W dans id + arrondi...")
df = pd.read_csv(os.path.join(INPUT_DIR, "associations_rhone.csv"), encoding="utf-8-sig", dtype={"adrs_codeinsee": str, "id": str})
df["adrs_codeinsee"] = df["adrs_codeinsee"].astype(str).str.zfill(5)
df["id"] = df["id"].astype(str).str.replace("W", "", regex=False)
df = round_numerics(df)
print(f"    Exemple adrs_codeinsee : {df['adrs_codeinsee'].head(3).tolist()}")
print(f"    Exemple id : {df['id'].head(3).tolist()}")
save_clean(df, "associations_rhone.csv")

# ─────────────────────────────────────────────────────────
# 8. FILOSOFI 2018 — IRIS → commune + agrégation + arrondi
# ─────────────────────────────────────────────────────────
print("\n[8/8] FILOSOFI 2018 — IRIS → commune + agrégation + arrondi...")
df = pd.read_csv(
    os.path.join(INPUT_DIR, "filosofi_2018_iris_rhone.csv"),
    encoding="utf-8-sig",
    dtype={"IRIS": str}
)
df["CODGEO"] = df["IRIS"].str[:5]
print(f"    IRIS avant agrégation : {len(df)} lignes")

cols_exclues = ["IRIS", "DEC_NOTE18", "CODGEO"]
cols_numeriques = [c for c in df.columns if c not in cols_exclues]

df_agg = df.groupby("CODGEO")[cols_numeriques].mean().reset_index()
df_agg = round_numerics(df_agg)
print(f"    Après agrégation par commune : {len(df_agg)} lignes")
print(f"    Exemple CODGEO : {df_agg['CODGEO'].head(3).tolist()}")
save_clean(df_agg, "filosofi_2018_rhone.csv")

# ─────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("RÉSUMÉ — Fichiers dans /output/normalise/")
print("=" * 60)
for f in sorted(os.listdir(OUTPUT_DIR)):
    if f.endswith(".csv"):
        taille = os.path.getsize(os.path.join(OUTPUT_DIR, f)) / 1024
        print(f"  ✓ {f:<45} {taille:.1f} Ko")
print("\nTerminé — Prêt pour DataIku / PowerBI / ML")
print("=" * 60)
