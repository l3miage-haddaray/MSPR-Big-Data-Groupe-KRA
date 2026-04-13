-- =============================================================================
-- BASE DE DONNÉES : Electio Analytics Lyon
-- Modèle : MERISE / MCD → MPD SQL
-- Projet : MSPR TPRE813 — Big Data & Analyse de données — EPSI Grenoble
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Création de la base
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS electio_analytics_lyon
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE electio_analytics_lyon;

-- =============================================================================
-- TABLE : ELECTION
-- =============================================================================
CREATE TABLE ELECTION (
    id_election       INT            NOT NULL AUTO_INCREMENT,
    annee             YEAR           NOT NULL,
    type_election     VARCHAR(50)    NOT NULL,    -- ex: 'municipale'
    tour              TINYINT        NOT NULL,    -- 1 ou 2
    libelle_election  VARCHAR(100)   NOT NULL,
    PRIMARY KEY (id_election)
);

-- =============================================================================
-- TABLE : ARRONDISSEMENT
-- =============================================================================
CREATE TABLE ARRONDISSEMENT (
    code_arrondissement     INT            NOT NULL,
    nom_arrondissement      VARCHAR(100)   NOT NULL,
    population_2022         INT            NOT NULL,
    nb_menages              INT            NOT NULL,
    taille_moyenne_menage   DECIMAL(4,2)   NOT NULL,
    densite_pop             DECIMAL(10,2)  NULL,    -- calculable ultérieurement
    PRIMARY KEY (code_arrondissement)
);

-- =============================================================================
-- TABLE : RESULTAT_ELECTORAL  (association ARRONDISSEMENT × ELECTION)
-- =============================================================================
CREATE TABLE RESULTAT_ELECTORAL (
    code_arrondissement     INT            NOT NULL,
    id_election             INT            NOT NULL,
    inscrits                INT            NOT NULL,
    votants                 INT            NOT NULL,
    participation_pct       DECIMAL(5,2)   NOT NULL,
    abstention_pct          DECIMAL(5,2)   NOT NULL,
    bloc_gagnant            VARCHAR(20)    NOT NULL,  -- 'gauche','droite','ecologiste'
    score_gagnant_pct       DECIMAL(5,2)   NOT NULL,
    bloc_gagnant_num        TINYINT        NOT NULL,  -- 0=gauche, 1=droite, 2=ecologiste
    PRIMARY KEY (code_arrondissement, id_election),
    CONSTRAINT fk_re_arrondissement FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_re_election FOREIGN KEY (id_election)
        REFERENCES ELECTION (id_election)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- TABLE : INDICATEUR_SOCIOECO
-- =============================================================================
CREATE TABLE INDICATEUR_SOCIOECO (
    id_indicateur               INT            NOT NULL AUTO_INCREMENT,
    code_arrondissement         INT            NOT NULL UNIQUE,
    -- Emploi et activité
    taux_activite_15_64         DECIMAL(5,2)   NOT NULL,
    taux_emploi_15_64           DECIMAL(5,2)   NOT NULL,
    taux_chomage_15_64          DECIMAL(5,2)   NOT NULL,
    -- Catégories socio-professionnelles
    pct_cadres                  DECIMAL(5,2)   NOT NULL,
    pct_prof_intermediaires     DECIMAL(5,2)   NOT NULL,
    pct_employes                DECIMAL(5,2)   NOT NULL,
    pct_ouvriers                DECIMAL(5,2)   NOT NULL,
    -- Revenus et pauvreté
    revenu_median_uc            DECIMAL(10,2)  NOT NULL,
    taux_pauvrete               DECIMAL(5,2)   NOT NULL,
    rapport_interdecile_D9_D1   DECIMAL(5,2)   NOT NULL,
    -- Logement
    pct_proprietaires           DECIMAL(5,2)   NOT NULL,
    pct_locataires_prives       DECIMAL(5,2)   NOT NULL,
    pct_hlm                     DECIMAL(5,2)   NOT NULL,
    -- Formation
    pct_diplome_bac_plus_5      DECIMAL(5,2)   NOT NULL,
    pct_sans_diplome            DECIMAL(5,2)   NOT NULL,
    PRIMARY KEY (id_indicateur),
    CONSTRAINT fk_socioeco_arr FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- TABLE : INDICATEUR_SECURITE
-- =============================================================================
CREATE TABLE INDICATEUR_SECURITE (
    id_securite                 INT            NOT NULL AUTO_INCREMENT,
    code_arrondissement         INT            NOT NULL UNIQUE,
    taux_delinquance_pour_1000  DECIMAL(6,2)   NOT NULL,
    nb_cambriolages_2022        INT            NOT NULL,
    nb_vols_sans_violence       INT            NOT NULL,
    nb_coups_blessures          INT            NOT NULL,
    PRIMARY KEY (id_securite),
    CONSTRAINT fk_securite_arr FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- TABLE : INDICATEUR_ASSOCIATIONS
-- =============================================================================
CREATE TABLE INDICATEUR_ASSOCIATIONS (
    id_asso                         INT            NOT NULL AUTO_INCREMENT,
    code_arrondissement             INT            NOT NULL UNIQUE,
    nb_associations_totales         INT            NULL,
    nb_associations_actives         INT            NOT NULL,
    nb_creations_2020_2022          INT            NOT NULL,
    densite_asso_pour_1000_hab      DECIMAL(6,2)   NOT NULL,
    densite_associations            DECIMAL(6,2)   NULL,
    PRIMARY KEY (id_asso),
    CONSTRAINT fk_asso_arr FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- TABLE : INDICATEUR_ECONOMIE
-- =============================================================================
CREATE TABLE INDICATEUR_ECONOMIE (
    id_economie                 INT            NOT NULL AUTO_INCREMENT,
    code_arrondissement         INT            NOT NULL UNIQUE,
    nb_etablissements_actifs    INT            NOT NULL,
    nb_creations_entreprises    INT            NOT NULL,
    taux_creation_entreprises   DECIMAL(5,2)   NOT NULL,
    nb_salaries_secteur_prive   INT            NOT NULL,
    ratio_salaries_population   DECIMAL(6,3)   NOT NULL,
    indice_dynamisme_eco        DECIMAL(6,3)   NOT NULL,
    PRIMARY KEY (id_economie),
    CONSTRAINT fk_economie_arr FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- TABLE : FEATURES_ML  (entité dérivée, liée à ELECTION et ARRONDISSEMENT)
-- =============================================================================
CREATE TABLE FEATURES_ML (
    id_feature_ml               INT            NOT NULL AUTO_INCREMENT,
    code_arrondissement         INT            NOT NULL UNIQUE,
    -- Variables inter-élections
    evolution_participation_pts DECIMAL(6,2)   NOT NULL,
    evolution_inscrits_pct      DECIMAL(6,2)   NOT NULL,
    -- Indices synthétiques
    indice_precarite            DECIMAL(6,3)   NOT NULL,
    -- Variables cibles ML
    participation_classe_2020   VARCHAR(10)    NOT NULL,  -- 'haute','moyenne','basse'
    changement_bloc             TINYINT        NOT NULL,  -- 0 ou 1
    -- Qualité
    controle_qualite_pct        DECIMAL(5,2)   NOT NULL,
    controle_cle_ok             TINYINT        NOT NULL,
    controle_dataset_ok         TINYINT        NOT NULL,
    PRIMARY KEY (id_feature_ml),
    CONSTRAINT fk_fml_arr FOREIGN KEY (code_arrondissement)
        REFERENCES ARRONDISSEMENT (code_arrondissement)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================================
-- DONNÉES : ELECTION (2 scrutins — municipales 2014 et 2020, tour 2)
-- =============================================================================
INSERT INTO ELECTION (annee, type_election, tour, libelle_election) VALUES
(2014, 'municipale', 2, 'Élections municipales 2014 — Second tour'),
(2020, 'municipale', 2, 'Élections municipales 2020 — Second tour');

-- =============================================================================
-- DONNÉES : ARRONDISSEMENT
-- =============================================================================
INSERT INTO ARRONDISSEMENT (code_arrondissement, nom_arrondissement, population_2022, nb_menages, taille_moyenne_menage) VALUES
(69381, 'Lyon 1er', 29040,  16380, 1.75),
(69382, 'Lyon 2e',  31245,  17234, 1.79),
(69383, 'Lyon 3e',  104520, 54678, 1.88),
(69384, 'Lyon 4e',  36890,  19234, 1.89),
(69385, 'Lyon 5e',  48234,  24567, 1.94),
(69386, 'Lyon 6e',  50718,  26789, 1.87),
(69387, 'Lyon 7e',  82456,  42345, 1.92),
(69388, 'Lyon 8e',  85123,  43567, 1.93),
(69389, 'Lyon 9e',  52678,  25678, 2.02);

-- =============================================================================
-- DONNÉES : RESULTAT_ELECTORAL
-- id_election 1 = municipales 2014, id_election 2 = municipales 2020
-- =============================================================================

-- --- 2014 ---
INSERT INTO RESULTAT_ELECTORAL
    (code_arrondissement, id_election, inscrits, votants, participation_pct, abstention_pct, bloc_gagnant, score_gagnant_pct, bloc_gagnant_num)
VALUES
(69381, 1, 20845, 12069, 57.9, 42.1, 'gauche',     52.3, 0),
(69382, 1, 22341, 13452, 60.2, 39.8, 'droite',     54.1, 1),
(69383, 1, 68912, 38123, 55.3, 44.7, 'gauche',     48.7, 0),
(69384, 1, 25678, 14521, 56.6, 43.4, 'gauche',     51.2, 0),
(69385, 1, 35421, 20134, 56.8, 43.2, 'gauche',     49.8, 0),
(69386, 1, 38754, 24567, 63.4, 36.6, 'droite',     58.9, 1),
(69387, 1, 54123, 29876, 55.2, 44.8, 'gauche',     47.6, 0),
(69388, 1, 58967, 30721, 52.1, 47.9, 'gauche',     46.3, 0),
(69389, 1, 42876, 22556, 52.6, 47.4, 'gauche',     48.9, 0);

-- --- 2020 ---
INSERT INTO RESULTAT_ELECTORAL
    (code_arrondissement, id_election, inscrits, votants, participation_pct, abstention_pct, bloc_gagnant, score_gagnant_pct, bloc_gagnant_num)
VALUES
(69381, 2, 22134, 8990,  40.6, 59.4, 'gauche',     54.2, 0),
(69382, 2, 23567, 10234, 43.4, 56.6, 'droite',     52.8, 1),
(69383, 2, 72345, 28456, 39.3, 60.7, 'gauche',     51.3, 0),
(69384, 2, 26789, 10234, 38.2, 61.8, 'gauche',     53.1, 0),
(69385, 2, 36234, 13567, 37.4, 62.6, 'ecologiste', 48.7, 2),
(69386, 2, 40123, 17234, 42.9, 57.1, 'droite',     55.4, 1),
(69387, 2, 56789, 20456, 36.0, 64.0, 'gauche',     49.8, 0),
(69388, 2, 62345, 18329, 29.4, 70.6, 'gauche',     52.1, 0),
(69389, 2, 45678, 14478, 31.7, 68.3, 'gauche',     51.6, 0);

-- =============================================================================
-- DONNÉES : INDICATEUR_SOCIOECO
-- =============================================================================
INSERT INTO INDICATEUR_SOCIOECO
    (code_arrondissement, taux_activite_15_64, taux_emploi_15_64, taux_chomage_15_64,
     pct_cadres, pct_prof_intermediaires, pct_employes, pct_ouvriers,
     revenu_median_uc, taux_pauvrete, rapport_interdecile_D9_D1,
     pct_proprietaires, pct_locataires_prives, pct_hlm,
     pct_diplome_bac_plus_5, pct_sans_diplome)
VALUES
(69381, 77.5, 67.8, 12.5, 29.0, 28.5, 18.2, 4.5,  25980, 15.0, 4.2, 30.3, 55.6, 14.1, 39.2, 8.4),
(69382, 78.2, 69.4, 11.3, 32.4, 27.8, 17.4, 3.8,  28450, 12.4, 3.8, 35.6, 52.4, 12.0, 42.8, 7.2),
(69383, 76.8, 66.2, 13.8, 28.6, 26.4, 19.6, 6.2,  24680, 16.8, 4.5, 32.4, 48.6, 19.0, 36.4, 10.6),
(69384, 75.4, 64.8, 14.1, 26.8, 25.6, 20.4, 7.4,  23450, 17.2, 4.6, 34.8, 46.2, 19.0, 34.2, 11.2),
(69385, 74.2, 63.4, 14.5, 24.2, 24.8, 21.2, 8.6,  22890, 18.4, 4.8, 38.2, 42.8, 19.0, 30.6, 12.8),
(69386, 72.8, 66.7, 8.4,  38.5, 25.2, 16.8, 2.8,  34560,  8.2, 3.4, 48.6, 45.2,  6.2, 48.2, 5.4),
(69387, 75.6, 64.5, 14.7, 27.4, 26.8, 20.2, 7.8,  24120, 17.6, 4.7, 31.2, 47.4, 21.4, 35.8, 11.4),
(69388, 73.2, 60.8, 16.9, 18.6, 24.2, 23.4, 12.4, 20450, 22.4, 5.2, 28.4, 42.6, 29.0, 24.6, 16.2),
(69389, 71.8, 58.2, 18.9, 14.2, 22.4, 25.6, 16.2, 18670, 26.8, 5.8, 26.8, 38.4, 34.8, 18.4, 20.4);

-- =============================================================================
-- DONNÉES : INDICATEUR_SECURITE
-- =============================================================================
INSERT INTO INDICATEUR_SECURITE
    (code_arrondissement, taux_delinquance_pour_1000, nb_cambriolages_2022, nb_vols_sans_violence, nb_coups_blessures)
VALUES
(69381, 32.4, 186, 1456, 234),
(69382, 41.2, 234, 2867, 345),
(69383, 28.6, 412, 2234, 456),
(69384, 18.4, 145,  678, 156),
(69385, 16.2, 178,  712, 178),
(69386, 14.8, 198,  823, 145),
(69387, 22.4, 312, 1567, 312),
(69388, 24.6, 289, 1345, 378),
(69389, 26.8, 226, 1123, 289);

-- =============================================================================
-- DONNÉES : INDICATEUR_ASSOCIATIONS
-- =============================================================================
INSERT INTO INDICATEUR_ASSOCIATIONS
    (code_arrondissement, nb_associations_actives, nb_creations_2020_2022, densite_asso_pour_1000_hab)
VALUES
(69381, 1234, 312, 42.5),
(69382, 1567, 423, 50.2),
(69383, 2345, 567, 22.4),
(69384,  876, 189, 23.7),
(69385, 1123, 234, 23.3),
(69386, 1456, 312, 28.7),
(69387, 1789, 389, 21.7),
(69388, 1567, 312, 18.4),
(69389, 1234, 267, 23.4);

-- =============================================================================
-- DONNÉES : INDICATEUR_ECONOMIE
-- =============================================================================
INSERT INTO INDICATEUR_ECONOMIE
    (code_arrondissement, nb_etablissements_actifs, nb_creations_entreprises, taux_creation_entreprises, nb_salaries_secteur_prive, ratio_salaries_population, indice_dynamisme_eco)
VALUES
(69381, 5193,  1199, 23.1, 21589, 0.743, 0.821),
(69382, 8456,  1567, 18.5, 45678, 1.462, 0.860),
(69383, 9234,  1823, 19.7, 52345, 0.501, 0.697),
(69384, 3456,   678, 19.6, 12345, 0.335, 0.677),
(69385, 4123,   812, 19.7, 18234, 0.378, 0.651),
(69386, 6789,  1234, 18.2, 34567, 0.682, 0.872),
(69387, 7234,  1456, 20.1, 38456, 0.466, 0.683),
(69388, 5678,  1123, 19.8, 28234, 0.332, 0.567),
(69389, 4234,   867, 20.5, 18567, 0.352, 0.543);

-- =============================================================================
-- DONNÉES : FEATURES_ML
-- =============================================================================
INSERT INTO FEATURES_ML
    (code_arrondissement, evolution_participation_pts, evolution_inscrits_pct,
     indice_precarite, participation_classe_2020, changement_bloc,
     controle_qualite_pct, controle_cle_ok, controle_dataset_ok)
VALUES
(69381, -17.30, 6.18,  0.545, 'haute',   0, 1.0, 1, 1),
(69382, -16.80, 5.49,  0.469, 'haute',   0, 1.0, 1, 1),
(69383, -16.00, 4.98,  0.631, 'moyenne', 0, 1.0, 1, 1),
(69384, -18.40, 4.33,  0.645, 'moyenne', 0, 1.0, 1, 1),
(69385, -19.40, 2.30,  0.677, 'moyenne', 1, 1.0, 1, 1),
(69386, -20.50, 3.53,  0.318, 'haute',   0, 1.0, 1, 1),
(69387, -19.20, 4.93,  0.675, 'moyenne', 0, 1.0, 1, 1),
(69388, -22.70, 5.73,  0.849, 'basse',   0, 1.0, 1, 1),
(69389, -20.90, 6.54,  1.000, 'basse',   0, 1.0, 1, 1);

-- =============================================================================
-- VUES ANALYTIQUES UTILES
-- =============================================================================

-- Vue complète : résultats + indicateurs par arrondissement et élection
CREATE OR REPLACE VIEW v_resultats_complets AS
SELECT
    a.code_arrondissement,
    a.nom_arrondissement,
    e.annee,
    e.libelle_election,
    re.inscrits,
    re.votants,
    re.participation_pct,
    re.abstention_pct,
    re.bloc_gagnant,
    re.score_gagnant_pct,
    s.pct_cadres,
    s.revenu_median_uc,
    s.taux_pauvrete,
    s.taux_chomage_15_64,
    sec.taux_delinquance_pour_1000,
    eco.indice_dynamisme_eco,
    fml.indice_precarite,
    fml.participation_classe_2020,
    fml.changement_bloc
FROM RESULTAT_ELECTORAL re
JOIN ARRONDISSEMENT      a   ON a.code_arrondissement = re.code_arrondissement
JOIN ELECTION            e   ON e.id_election         = re.id_election
JOIN INDICATEUR_SOCIOECO s   ON s.code_arrondissement = re.code_arrondissement
JOIN INDICATEUR_SECURITE sec ON sec.code_arrondissement = re.code_arrondissement
JOIN INDICATEUR_ECONOMIE eco ON eco.code_arrondissement = re.code_arrondissement
JOIN FEATURES_ML         fml ON fml.code_arrondissement = re.code_arrondissement;

-- Vue : évolution de la participation entre 2014 et 2020
CREATE OR REPLACE VIEW v_evolution_participation AS
SELECT
    a.nom_arrondissement,
    r14.participation_pct  AS participation_2014,
    r20.participation_pct  AS participation_2020,
    fml.evolution_participation_pts,
    r14.bloc_gagnant       AS bloc_2014,
    r20.bloc_gagnant       AS bloc_2020,
    fml.changement_bloc
FROM ARRONDISSEMENT a
JOIN RESULTAT_ELECTORAL r14 ON r14.code_arrondissement = a.code_arrondissement AND r14.id_election = 1
JOIN RESULTAT_ELECTORAL r20 ON r20.code_arrondissement = a.code_arrondissement AND r20.id_election = 2
JOIN FEATURES_ML fml        ON fml.code_arrondissement = a.code_arrondissement;

-- =============================================================================
-- FIN DU SCRIPT
-- =============================================================================
