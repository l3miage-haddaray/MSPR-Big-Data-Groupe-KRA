import dataiku
import pandas as pd
 
# =========================
# 1) Lecture
# =========================
input_ds = dataiku.Dataset("elections_rhone")
df = input_ds.get_dataframe()
 
print(f"[INFO] Dataset source chargé : {df.shape[0]} lignes, {df.shape[1]} colonnes")
 
# =========================
# 2) Vérification
# =========================
if "id_election" not in df.columns:
    raise ValueError("La colonne 'id_election' est absente du dataset elections_rhone")
 
df["id_election"] = df["id_election"].astype(str).str.strip().str.lower()
 
# =========================
# 3) Filtre strict : législatives t1 et t2
# =========================
mask_legi = df["id_election"].str.match(r"^\d{4}_legi_t[12]$", na=False)
df_legi = df.loc[mask_legi].copy()
 
print(f"[INFO] Lignes après filtre législatives : {df_legi.shape[0]}")
 
if df_legi.empty:
    print("[DEBUG] Exemples de valeurs id_election présentes :")
    print(df["id_election"].drop_duplicates().sort_values().head(30).tolist())
    raise ValueError("Le filtre a retourné 0 ligne. Vérifie le contenu de la colonne 'id_election'.")
 
# =========================
# 4) Extraction année / tour
# =========================
df_legi["annee"] = df_legi["id_election"].str.extract(r"^(\d{4})")[0].astype(int)
df_legi["tour"] = df_legi["id_election"].str.extract(r"_t([12])$")[0].astype(int)
df_legi["type_election"] = "legislatives"
df_legi["libelle_tour"] = df_legi["tour"].map({
    1: "Premier tour",
    2: "Second tour"
})
 
# =========================
# 5) Contrôles qualité
# =========================
print("[INFO] Valeurs id_election conservées :")
for v in sorted(df_legi["id_election"].dropna().unique().tolist()):
    print("   -", v)
 
print("[INFO] Répartition par année et tour :")
print(
    df_legi.groupby(["annee", "tour"])
           .size()
           .reset_index(name="nb_lignes")
           .sort_values(["annee", "tour"])
)
 
# =========================
# 6) Écriture
# =========================
output_ds = dataiku.Dataset("elections_legislatives_rhone")
output_ds.write_with_schema(df_legi)
 
print("[OK] Dataset 'elections_legislatives_rhone' écrit avec succès")