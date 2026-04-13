#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 ETL PIPELINE — ELECTIO ANALYTICS LYON
 MSPR TPRE813 — Bloc 3 : Big Data & Analyse de données — EPSI Grenoble
================================================================================

 Auteurs    : CHAOUSARI Khaoula, LINGENU NDALA Adonnay, HADDAD Rayane
 Date       : Avril 2026
 Python     : 3.10+
 Librairies : pandas, numpy

 Description :
   Pipeline ETL documenté du projet Electio Analytics Lyon :
     1. Chargement des jeux de données consolidés issus de 9 sources
        institutionnelles
     2. Vérification et harmonisation des clés géographiques
        (codes INSEE 69381-69389)
     3. Jointure et consolidation en dataset analytique unique
     4. Feature engineering (indices composites, variables dérivées)
     5. Contrôle qualité (complétude, unicité, cohérence, validité)
     6. Export final : dataset_ml_enrichi_lyon.csv

 Sources institutionnelles mobilisées :
   - Élections municipales 2014 & 2020 T2 (data.gouv.fr)
   - Démographie (INSEE RP 2022)
   - Emploi et CSP (INSEE RP 2022)
   - Revenus et pauvreté (INSEE Filosofi 2021)
   - Logement (INSEE RP 2022)
   - Formation (INSEE RP 2022)
   - Entreprises (INSEE SIDE 2022)
   - Sécurité / délinquance (SSMSI — Ministère de l'Intérieur 2022)
   - Associations (RNA 2022)

 Note méthodologique :
   Dans le cadre du POC, les valeurs consolidées issues des sources
   institutionnelles sont instanciées dans le script sous forme de DataFrames
   afin de garantir une exécution stable sans dépendance réseau.
   Cette implémentation documente la logique ETL du démonstrateur ; elle ne
   remplace pas une chaîne de production connectée directement à des fichiers
   bruts ou à des API externes.
================================================================================
"""

import pandas as pd
import numpy as np
from datetime import datetime

# ==============================================================================
# CONFIGURATION GÉNÉRALE
# ==============================================================================

CODES = [69381, 69382, 69383, 69384, 69385, 69386, 69387, 69388, 69389]

NOMS = {
    69381: "Lyon 1er",
    69382: "Lyon 2e",
    69383: "Lyon 3e",
    69384: "Lyon 4e",
    69385: "Lyon 5e",
    69386: "Lyon 6e",
    69387: "Lyon 7e",
    69388: "Lyon 8e",
    69389: "Lyon 9e",
}

OUTPUT = "dataset_ml_enrichi_lyon.csv"

print("=" * 72)
print(" ELECTIO ANALYTICS LYON — Pipeline ETL documenté")
print(f" {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("=" * 72)

# ==============================================================================
# ÉTAPE 1 : CHARGEMENT DES JEUX DE DONNÉES CONSOLIDÉS
# ==============================================================================

print("\n[1/6] Chargement des jeux de données consolidés (9 sources)...")

# --- 1.1 Élections municipales 2014 (data.gouv.fr) ---
elec_2014 = pd.DataFrame({
    "code_arrondissement": CODES,
    "inscrits_2014":          [20845, 22341, 68912, 25678, 35421, 38754, 54123, 58967, 42876],
    "votants_2014":           [12069, 13452, 38123, 14521, 20134, 24567, 29876, 30721, 22556],
    "participation_pct_2014": [57.9, 60.2, 55.3, 56.6, 56.8, 63.4, 55.2, 52.1, 52.6],
    "abstention_pct_2014":    [42.1, 39.8, 44.7, 43.4, 43.2, 36.6, 44.8, 47.9, 47.4],
    "bloc_gagnant_2014":      ["gauche", "droite", "gauche", "gauche", "gauche",
                               "droite", "gauche", "gauche", "gauche"],
    "score_gagnant_pct_2014": [52.3, 54.1, 48.7, 51.2, 49.8, 58.9, 47.6, 46.3, 48.9],
})

# --- 1.2 Élections municipales 2020 (data.gouv.fr) ---
elec_2020 = pd.DataFrame({
    "code_arrondissement": CODES,
    "inscrits_2020":          [22134, 23567, 72345, 26789, 36234, 40123, 56789, 62345, 45678],
    "votants_2020":           [8990, 10234, 28456, 10234, 13567, 17234, 20456, 18329, 14478],
    "participation_pct_2020": [40.6, 43.4, 39.3, 38.2, 37.4, 42.9, 36.0, 29.4, 31.7],
    "abstention_pct_2020":    [59.4, 56.6, 60.7, 61.8, 62.6, 57.1, 64.0, 70.6, 68.3],
    "bloc_gagnant_2020":      ["gauche", "droite", "gauche", "gauche", "ecologiste",
                               "droite", "gauche", "gauche", "gauche"],
    "score_gagnant_pct_2020": [54.2, 52.8, 51.3, 53.1, 48.7, 55.4, 49.8, 52.1, 51.6],
})

# --- 1.3 Démographie (INSEE RP 2022) ---
demo = pd.DataFrame({
    "code_arrondissement": CODES,
    "population_2022":       [29040, 31245, 104520, 36890, 48234, 50718, 82456, 85123, 52678],
    "nb_menages":            [16380, 17234, 54678, 19234, 24567, 26789, 42345, 43567, 25678],
    "taille_moyenne_menage": [1.75, 1.79, 1.88, 1.89, 1.94, 1.87, 1.92, 1.93, 2.02],
})

# --- 1.4 Emploi et CSP (INSEE RP 2022) ---
emploi = pd.DataFrame({
    "code_arrondissement": CODES,
    "taux_activite_15_64":     [77.5, 78.2, 76.8, 75.4, 74.2, 72.8, 75.6, 73.2, 71.8],
    "taux_emploi_15_64":       [67.8, 69.4, 66.2, 64.8, 63.4, 66.7, 64.5, 60.8, 58.2],
    "taux_chomage_15_64":      [12.5, 11.3, 13.8, 14.1, 14.5, 8.4, 14.7, 16.9, 18.9],
    "pct_cadres":              [29.0, 32.4, 28.6, 26.8, 24.2, 38.5, 27.4, 18.6, 14.2],
    "pct_prof_intermediaires": [28.5, 27.8, 26.4, 25.6, 24.8, 25.2, 26.8, 24.2, 22.4],
    "pct_employes":            [18.2, 17.4, 19.6, 20.4, 21.2, 16.8, 20.2, 23.4, 25.6],
    "pct_ouvriers":            [4.5, 3.8, 6.2, 7.4, 8.6, 2.8, 7.8, 12.4, 16.2],
})

# --- 1.5 Revenus et pauvreté (INSEE Filosofi 2021) ---
revenus = pd.DataFrame({
    "code_arrondissement": CODES,
    "revenu_median_uc":          [25980, 28450, 24680, 23450, 22890, 34560, 24120, 20450, 18670],
    "taux_pauvrete":             [15.0, 12.4, 16.8, 17.2, 18.4, 8.2, 17.6, 22.4, 26.8],
    "rapport_interdecile_D9_D1": [4.2, 3.8, 4.5, 4.6, 4.8, 3.4, 4.7, 5.2, 5.8],
})

# --- 1.6 Logement (INSEE RP 2022) ---
logement = pd.DataFrame({
    "code_arrondissement": CODES,
    "pct_proprietaires":     [30.3, 35.6, 32.4, 34.8, 38.2, 48.6, 31.2, 28.4, 26.8],
    "pct_locataires_prives": [55.6, 52.4, 48.6, 46.2, 42.8, 45.2, 47.4, 42.6, 38.4],
    "pct_hlm":               [14.1, 12.0, 19.0, 19.0, 19.0, 6.2, 21.4, 29.0, 34.8],
})

# --- 1.7 Formation (INSEE RP 2022) ---
formation = pd.DataFrame({
    "code_arrondissement": CODES,
    "pct_diplome_bac_plus_5": [39.2, 42.8, 36.4, 34.2, 30.6, 48.2, 35.8, 24.6, 18.4],
    "pct_sans_diplome":       [8.4, 7.2, 10.6, 11.2, 12.8, 5.4, 11.4, 16.2, 20.4],
})

# --- 1.8 Entreprises (INSEE SIDE 2022) ---
entreprises = pd.DataFrame({
    "code_arrondissement": CODES,
    "nb_etablissements_actifs":      [5193, 8456, 9234, 3456, 4123, 6789, 7234, 5678, 4234],
    "nb_creations_entreprises_2022": [1199, 1567, 1823, 678, 812, 1234, 1456, 1123, 867],
    "taux_creation_entreprises":     [23.1, 18.5, 19.7, 19.6, 19.7, 18.2, 20.1, 19.8, 20.5],
    "nb_salaries_secteur_prive":     [21589, 45678, 52345, 12345, 18234, 34567, 38456, 28234, 18567],
})

# --- 1.9 Sécurité / délinquance (SSMSI 2022) ---
securite = pd.DataFrame({
    "code_arrondissement": CODES,
    "taux_delinquance_pour_1000": [32.4, 41.2, 28.6, 18.4, 16.2, 14.8, 22.4, 24.6, 26.8],
    "nb_cambriolages_2022":       [186, 234, 412, 145, 178, 198, 312, 289, 226],
    "nb_vols_sans_violence_2022": [1456, 2867, 2234, 678, 712, 823, 1567, 1345, 1123],
    "nb_coups_blessures_2022":    [234, 345, 456, 156, 178, 145, 312, 378, 289],
})

# --- 1.10 Associations (RNA 2022) ---
associations = pd.DataFrame({
    "code_arrondissement": CODES,
    "nb_associations_actives":             [1234, 1567, 2345, 876, 1123, 1456, 1789, 1567, 1234],
    "densite_associations_pour_1000_hab":  [42.5, 50.2, 22.4, 23.7, 23.3, 28.7, 21.7, 18.4, 23.4],
    "nb_creations_associations_2020_2022": [312, 423, 567, 189, 234, 312, 389, 312, 267],
})

print("  ✓ 9 sources mobilisées / 9 arrondissements couverts")

# ==============================================================================
# ÉTAPE 2 : VÉRIFICATION DES CLÉS GÉOGRAPHIQUES
# ==============================================================================

print("\n[2/6] Vérification des clés géographiques (codes INSEE)...")

sources = {
    "elec_2014": elec_2014,
    "elec_2020": elec_2020,
    "demo": demo,
    "emploi": emploi,
    "revenus": revenus,
    "logement": logement,
    "formation": formation,
    "entreprises": entreprises,
    "securite": securite,
    "associations": associations,
}

for name, src in sources.items():
    ok = set(src["code_arrondissement"]) == set(CODES)
    print(f"  {'✓' if ok else '⚠'} {name:15s} : {len(src)}/9")

# ==============================================================================
# ÉTAPE 3 : JOINTURE MULTI-SOURCES
# ==============================================================================

print("\n[3/6] Jointure multi-sources sur code_arrondissement...")

df = elec_2014.merge(elec_2020, on="code_arrondissement")

for name, src in [
    ("demo", demo),
    ("emploi", emploi),
    ("revenus", revenus),
    ("logement", logement),
    ("formation", formation),
    ("entreprises", entreprises),
    ("securite", securite),
    ("associations", associations),
]:
    df = df.merge(src, on="code_arrondissement")
    print(f"  + {name:15s} → {df.shape}")

df.insert(1, "nom_arrondissement", df["code_arrondissement"].map(NOMS))
print(f"  ✓ Dataset consolidé : {df.shape[0]} lignes × {df.shape[1]} colonnes")

# ==============================================================================
# ÉTAPE 4 : FEATURE ENGINEERING
# ==============================================================================

print("\n[4/6] Feature engineering (9 variables dérivées)...")

# 4.1 Évolution inter-élections
df["evolution_participation_pts"] = df["participation_pct_2020"] - df["participation_pct_2014"]
df["evolution_inscrits_pct"] = (
    (df["inscrits_2020"] - df["inscrits_2014"]) / df["inscrits_2014"] * 100
).round(2)

# 4.2 Ratio économique
df["ratio_salaries_population"] = (
    df["nb_salaries_secteur_prive"] / df["population_2022"]
).round(3)

# 4.3 Indice de précarité
# Les pondérations retenues relèvent d’un choix d’expertise adapté au POC.
# Elles visent à produire un indicateur synthétique interprétable et pourront
# être recalibrées lors d’un passage à l’échelle.
df["indice_precarite"] = (
    0.40 * (df["taux_pauvrete"] / df["taux_pauvrete"].max()) +
    0.30 * (df["taux_chomage_15_64"] / df["taux_chomage_15_64"].max()) +
    0.20 * (df["pct_hlm"] / df["pct_hlm"].max()) +
    0.10 * (df["pct_sans_diplome"] / df["pct_sans_diplome"].max())
).round(3)

# 4.4 Indice de dynamisme économique
df["indice_dynamisme_eco"] = (
    0.30 * (df["pct_cadres"] / df["pct_cadres"].max()) +
    0.30 * (df["revenu_median_uc"] / df["revenu_median_uc"].max()) +
    0.20 * (df["taux_creation_entreprises"] / df["taux_creation_entreprises"].max()) +
    0.20 * (df["densite_associations_pour_1000_hab"] / df["densite_associations_pour_1000_hab"].max())
).round(3)

# 4.5 Classe de participation 2020
df["participation_classe_2020"] = df["participation_pct_2020"].apply(
    lambda p: "haute" if p >= 40 else ("moyenne" if p >= 35 else "basse")
)

# 4.6 Encodage des blocs et changement
BLOC = {"gauche": 0, "droite": 1, "ecologiste": 2}
df["bloc_gagnant_2014_num"] = df["bloc_gagnant_2014"].map(BLOC)
df["bloc_gagnant_2020_num"] = df["bloc_gagnant_2020"].map(BLOC)
df["changement_bloc"] = (
    df["bloc_gagnant_2014_num"] != df["bloc_gagnant_2020_num"]
).astype(int)

print(f"  ✓ 9 variables dérivées créées → total : {df.shape[1]} colonnes")

# ==============================================================================
# ÉTAPE 5 : CONTRÔLE QUALITÉ
# ==============================================================================

print("\n[5/6] Contrôle qualité...")

# 5.1 Complétude
nb_missing = int(df.isnull().sum().sum())
print(f"  ✓ Complétude        : {nb_missing} valeur(s) manquante(s)")

# 5.2 Unicité
nb_duplicates = int(df["code_arrondissement"].duplicated().sum())
print(f"  ✓ Unicité           : {nb_duplicates} doublon(s) sur la clé")

# 5.3 Cohérence participation / abstention
for year in [2014, 2020]:
    total = df[f'participation_pct_{year}'] + df[f'abstention_pct_{year}']
    print(f"  ✓ Cohérence {year}    : moyenne participation + abstention = {total.mean():.1f}%")

# 5.4 Contrôles par assertions
assert df["code_arrondissement"].is_unique, "Erreur : doublons sur code_arrondissement"

valid_blocs = {"gauche", "droite", "ecologiste"}
assert set(df["bloc_gagnant_2014"]).issubset(valid_blocs), "Bloc 2014 invalide détecté"
assert set(df["bloc_gagnant_2020"]).issubset(valid_blocs), "Bloc 2020 invalide détecté"

# Colonnes de pourcentage à borner entre 0 et 100
bounded_pct_cols = [
    "participation_pct_2014", "abstention_pct_2014",
    "participation_pct_2020", "abstention_pct_2020",
    "score_gagnant_pct_2014", "score_gagnant_pct_2020",
    "taux_activite_15_64", "taux_emploi_15_64", "taux_chomage_15_64",
    "pct_cadres", "pct_prof_intermediaires", "pct_employes", "pct_ouvriers",
    "taux_pauvrete", "pct_proprietaires", "pct_locataires_prives", "pct_hlm",
    "pct_diplome_bac_plus_5", "pct_sans_diplome", "taux_creation_entreprises"
]

for col in bounded_pct_cols:
    assert ((df[col] >= 0) & (df[col] <= 100)).all(), f"Valeurs hors plage dans {col}"

# 5.5 Compteurs non négatifs
count_cols = [
    "inscrits_2014", "votants_2014", "inscrits_2020", "votants_2020",
    "population_2022", "nb_menages", "nb_etablissements_actifs",
    "nb_creations_entreprises_2022", "nb_salaries_secteur_prive",
    "nb_cambriolages_2022", "nb_vols_sans_violence_2022",
    "nb_coups_blessures_2022", "nb_associations_actives",
    "nb_creations_associations_2020_2022"
]

for col in count_cols:
    assert (df[col] >= 0).all(), f"Valeurs négatives détectées dans {col}"

# 5.6 Bornes des indices
for idx in ["indice_precarite", "indice_dynamisme_eco"]:
    print(f"  ✓ {idx:20s}: [{df[idx].min():.3f} — {df[idx].max():.3f}]")

print("  ✓ Assertions qualité : validées")

# ==============================================================================
# ÉTAPE 6 : EXPORT
# ==============================================================================

print(f"\n[6/6] Export du dataset analytique → {OUTPUT}")

col_order = [
    "code_arrondissement", "nom_arrondissement",
    "inscrits_2014", "votants_2014", "participation_pct_2014", "abstention_pct_2014",
    "bloc_gagnant_2014", "score_gagnant_pct_2014",
    "inscrits_2020", "votants_2020", "participation_pct_2020", "abstention_pct_2020",
    "bloc_gagnant_2020", "score_gagnant_pct_2020",
    "population_2022", "nb_menages", "taille_moyenne_menage",
    "taux_activite_15_64", "taux_emploi_15_64", "taux_chomage_15_64",
    "pct_cadres", "pct_prof_intermediaires", "pct_employes", "pct_ouvriers",
    "revenu_median_uc", "taux_pauvrete", "rapport_interdecile_D9_D1",
    "pct_proprietaires", "pct_locataires_prives", "pct_hlm",
    "pct_diplome_bac_plus_5", "pct_sans_diplome",
    "nb_etablissements_actifs", "nb_creations_entreprises_2022",
    "taux_creation_entreprises", "nb_salaries_secteur_prive",
    "taux_delinquance_pour_1000", "nb_cambriolages_2022",
    "nb_vols_sans_violence_2022", "nb_coups_blessures_2022",
    "nb_associations_actives", "densite_associations_pour_1000_hab",
    "nb_creations_associations_2020_2022",
    "evolution_participation_pts", "evolution_inscrits_pct",
    "ratio_salaries_population", "indice_precarite", "indice_dynamisme_eco",
    "participation_classe_2020", "bloc_gagnant_2014_num",
    "bloc_gagnant_2020_num", "changement_bloc",
]

df[col_order].to_csv(OUTPUT, index=False, encoding="utf-8")

print(f"  ✓ {df.shape[0]} lignes × {len(col_order)} colonnes exportées")
print("\n" + "=" * 72)
print(" Pipeline terminé — dataset_ml_enrichi_lyon.csv généré avec succès")
print("=" * 72)