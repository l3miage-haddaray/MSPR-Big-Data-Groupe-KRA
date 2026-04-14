-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mar. 14 avr. 2026 à 09:15
-- Version du serveur : 12.1.2-MariaDB
-- Version de PHP : 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `bdd_electio_analytics_lyon`
--

-- --------------------------------------------------------

--
-- Structure de la table `arrondissement`
--

CREATE TABLE `arrondissement` (
  `code_arrondissement` int(11) NOT NULL,
  `nom_arrondissement` varchar(100) NOT NULL,
  `population_2022` int(11) NOT NULL,
  `nb_menages` int(11) NOT NULL,
  `taille_moyenne_menage` decimal(4,2) NOT NULL,
  `densite_pop` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `arrondissement`
--

INSERT INTO `arrondissement` (`code_arrondissement`, `nom_arrondissement`, `population_2022`, `nb_menages`, `taille_moyenne_menage`, `densite_pop`) VALUES
(69381, 'Lyon 1er', 29040, 16380, 1.75, NULL),
(69382, 'Lyon 2e', 31245, 17234, 1.79, NULL),
(69383, 'Lyon 3e', 104520, 54678, 1.88, NULL),
(69384, 'Lyon 4e', 36890, 19234, 1.89, NULL),
(69385, 'Lyon 5e', 48234, 24567, 1.94, NULL),
(69386, 'Lyon 6e', 50718, 26789, 1.87, NULL),
(69387, 'Lyon 7e', 82456, 42345, 1.92, NULL),
(69388, 'Lyon 8e', 85123, 43567, 1.93, NULL),
(69389, 'Lyon 9e', 52678, 25678, 2.02, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `election`
--

CREATE TABLE `election` (
  `id_election` int(11) NOT NULL,
  `annee` year(4) NOT NULL,
  `type_election` varchar(50) NOT NULL,
  `tour` tinyint(4) NOT NULL,
  `libelle_election` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `election`
--

INSERT INTO `election` (`id_election`, `annee`, `type_election`, `tour`, `libelle_election`) VALUES
(1, '2014', 'municipale', 2, 'Élections municipales 2014 — Second tour'),
(2, '2020', 'municipale', 2, 'Élections municipales 2020 — Second tour');

-- --------------------------------------------------------

--
-- Structure de la table `features_ml`
--

CREATE TABLE `features_ml` (
  `id_feature_ml` int(11) NOT NULL,
  `code_arrondissement` int(11) NOT NULL,
  `evolution_participation_pts` decimal(6,2) NOT NULL,
  `evolution_inscrits_pct` decimal(6,2) NOT NULL,
  `indice_precarite` decimal(6,3) NOT NULL,
  `participation_classe_2020` varchar(10) NOT NULL,
  `changement_bloc` tinyint(4) NOT NULL,
  `controle_qualite_pct` decimal(5,2) NOT NULL,
  `controle_cle_ok` tinyint(4) NOT NULL,
  `controle_dataset_ok` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `features_ml`
--

INSERT INTO `features_ml` (`id_feature_ml`, `code_arrondissement`, `evolution_participation_pts`, `evolution_inscrits_pct`, `indice_precarite`, `participation_classe_2020`, `changement_bloc`, `controle_qualite_pct`, `controle_cle_ok`, `controle_dataset_ok`) VALUES
(1, 69381, -17.30, 6.18, 0.545, 'haute', 0, 1.00, 1, 1),
(2, 69382, -16.80, 5.49, 0.469, 'haute', 0, 1.00, 1, 1),
(3, 69383, -16.00, 4.98, 0.631, 'moyenne', 0, 1.00, 1, 1),
(4, 69384, -18.40, 4.33, 0.645, 'moyenne', 0, 1.00, 1, 1),
(5, 69385, -19.40, 2.30, 0.677, 'moyenne', 1, 1.00, 1, 1),
(6, 69386, -20.50, 3.53, 0.318, 'haute', 0, 1.00, 1, 1),
(7, 69387, -19.20, 4.93, 0.675, 'moyenne', 0, 1.00, 1, 1),
(8, 69388, -22.70, 5.73, 0.849, 'basse', 0, 1.00, 1, 1),
(9, 69389, -20.90, 6.54, 1.000, 'basse', 0, 1.00, 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `indicateur_associations`
--

CREATE TABLE `indicateur_associations` (
  `id_asso` int(11) NOT NULL,
  `code_arrondissement` int(11) NOT NULL,
  `nb_associations_totales` int(11) DEFAULT NULL,
  `nb_associations_actives` int(11) NOT NULL,
  `nb_creations_2020_2022` int(11) NOT NULL,
  `densite_asso_pour_1000_hab` decimal(6,2) NOT NULL,
  `densite_associations` decimal(6,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `indicateur_associations`
--

INSERT INTO `indicateur_associations` (`id_asso`, `code_arrondissement`, `nb_associations_totales`, `nb_associations_actives`, `nb_creations_2020_2022`, `densite_asso_pour_1000_hab`, `densite_associations`) VALUES
(1, 69381, NULL, 1234, 312, 42.50, NULL),
(2, 69382, NULL, 1567, 423, 50.20, NULL),
(3, 69383, NULL, 2345, 567, 22.40, NULL),
(4, 69384, NULL, 876, 189, 23.70, NULL),
(5, 69385, NULL, 1123, 234, 23.30, NULL),
(6, 69386, NULL, 1456, 312, 28.70, NULL),
(7, 69387, NULL, 1789, 389, 21.70, NULL),
(8, 69388, NULL, 1567, 312, 18.40, NULL),
(9, 69389, NULL, 1234, 267, 23.40, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `indicateur_economie`
--

CREATE TABLE `indicateur_economie` (
  `id_economie` int(11) NOT NULL,
  `code_arrondissement` int(11) NOT NULL,
  `nb_etablissements_actifs` int(11) NOT NULL,
  `nb_creations_entreprises` int(11) NOT NULL,
  `taux_creation_entreprises` decimal(5,2) NOT NULL,
  `nb_salaries_secteur_prive` int(11) NOT NULL,
  `ratio_salaries_population` decimal(6,3) NOT NULL,
  `indice_dynamisme_eco` decimal(6,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `indicateur_economie`
--

INSERT INTO `indicateur_economie` (`id_economie`, `code_arrondissement`, `nb_etablissements_actifs`, `nb_creations_entreprises`, `taux_creation_entreprises`, `nb_salaries_secteur_prive`, `ratio_salaries_population`, `indice_dynamisme_eco`) VALUES
(1, 69381, 5193, 1199, 23.10, 21589, 0.743, 0.821),
(2, 69382, 8456, 1567, 18.50, 45678, 1.462, 0.860),
(3, 69383, 9234, 1823, 19.70, 52345, 0.501, 0.697),
(4, 69384, 3456, 678, 19.60, 12345, 0.335, 0.677),
(5, 69385, 4123, 812, 19.70, 18234, 0.378, 0.651),
(6, 69386, 6789, 1234, 18.20, 34567, 0.682, 0.872),
(7, 69387, 7234, 1456, 20.10, 38456, 0.466, 0.683),
(8, 69388, 5678, 1123, 19.80, 28234, 0.332, 0.567),
(9, 69389, 4234, 867, 20.50, 18567, 0.352, 0.543);

-- --------------------------------------------------------

--
-- Structure de la table `indicateur_securite`
--

CREATE TABLE `indicateur_securite` (
  `id_securite` int(11) NOT NULL,
  `code_arrondissement` int(11) NOT NULL,
  `taux_delinquance_pour_1000` decimal(6,2) NOT NULL,
  `nb_cambriolages_2022` int(11) NOT NULL,
  `nb_vols_sans_violence` int(11) NOT NULL,
  `nb_coups_blessures` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `indicateur_securite`
--

INSERT INTO `indicateur_securite` (`id_securite`, `code_arrondissement`, `taux_delinquance_pour_1000`, `nb_cambriolages_2022`, `nb_vols_sans_violence`, `nb_coups_blessures`) VALUES
(1, 69381, 32.40, 186, 1456, 234),
(2, 69382, 41.20, 234, 2867, 345),
(3, 69383, 28.60, 412, 2234, 456),
(4, 69384, 18.40, 145, 678, 156),
(5, 69385, 16.20, 178, 712, 178),
(6, 69386, 14.80, 198, 823, 145),
(7, 69387, 22.40, 312, 1567, 312),
(8, 69388, 24.60, 289, 1345, 378),
(9, 69389, 26.80, 226, 1123, 289);

-- --------------------------------------------------------

--
-- Structure de la table `indicateur_socioeco`
--

CREATE TABLE `indicateur_socioeco` (
  `id_indicateur` int(11) NOT NULL,
  `code_arrondissement` int(11) NOT NULL,
  `taux_activite_15_64` decimal(5,2) NOT NULL,
  `taux_emploi_15_64` decimal(5,2) NOT NULL,
  `taux_chomage_15_64` decimal(5,2) NOT NULL,
  `pct_cadres` decimal(5,2) NOT NULL,
  `pct_prof_intermediaires` decimal(5,2) NOT NULL,
  `pct_employes` decimal(5,2) NOT NULL,
  `pct_ouvriers` decimal(5,2) NOT NULL,
  `revenu_median_uc` decimal(10,2) NOT NULL,
  `taux_pauvrete` decimal(5,2) NOT NULL,
  `rapport_interdecile_D9_D1` decimal(5,2) NOT NULL,
  `pct_proprietaires` decimal(5,2) NOT NULL,
  `pct_locataires_prives` decimal(5,2) NOT NULL,
  `pct_hlm` decimal(5,2) NOT NULL,
  `pct_diplome_bac_plus_5` decimal(5,2) NOT NULL,
  `pct_sans_diplome` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `indicateur_socioeco`
--

INSERT INTO `indicateur_socioeco` (`id_indicateur`, `code_arrondissement`, `taux_activite_15_64`, `taux_emploi_15_64`, `taux_chomage_15_64`, `pct_cadres`, `pct_prof_intermediaires`, `pct_employes`, `pct_ouvriers`, `revenu_median_uc`, `taux_pauvrete`, `rapport_interdecile_D9_D1`, `pct_proprietaires`, `pct_locataires_prives`, `pct_hlm`, `pct_diplome_bac_plus_5`, `pct_sans_diplome`) VALUES
(1, 69381, 77.50, 67.80, 12.50, 29.00, 28.50, 18.20, 4.50, 25980.00, 15.00, 4.20, 30.30, 55.60, 14.10, 39.20, 8.40),
(2, 69382, 78.20, 69.40, 11.30, 32.40, 27.80, 17.40, 3.80, 28450.00, 12.40, 3.80, 35.60, 52.40, 12.00, 42.80, 7.20),
(3, 69383, 76.80, 66.20, 13.80, 28.60, 26.40, 19.60, 6.20, 24680.00, 16.80, 4.50, 32.40, 48.60, 19.00, 36.40, 10.60),
(4, 69384, 75.40, 64.80, 14.10, 26.80, 25.60, 20.40, 7.40, 23450.00, 17.20, 4.60, 34.80, 46.20, 19.00, 34.20, 11.20),
(5, 69385, 74.20, 63.40, 14.50, 24.20, 24.80, 21.20, 8.60, 22890.00, 18.40, 4.80, 38.20, 42.80, 19.00, 30.60, 12.80),
(6, 69386, 72.80, 66.70, 8.40, 38.50, 25.20, 16.80, 2.80, 34560.00, 8.20, 3.40, 48.60, 45.20, 6.20, 48.20, 5.40),
(7, 69387, 75.60, 64.50, 14.70, 27.40, 26.80, 20.20, 7.80, 24120.00, 17.60, 4.70, 31.20, 47.40, 21.40, 35.80, 11.40),
(8, 69388, 73.20, 60.80, 16.90, 18.60, 24.20, 23.40, 12.40, 20450.00, 22.40, 5.20, 28.40, 42.60, 29.00, 24.60, 16.20),
(9, 69389, 71.80, 58.20, 18.90, 14.20, 22.40, 25.60, 16.20, 18670.00, 26.80, 5.80, 26.80, 38.40, 34.80, 18.40, 20.40);

-- --------------------------------------------------------

--
-- Structure de la table `resultat_electoral`
--

CREATE TABLE `resultat_electoral` (
  `code_arrondissement` int(11) NOT NULL,
  `id_election` int(11) NOT NULL,
  `inscrits` int(11) NOT NULL,
  `votants` int(11) NOT NULL,
  `participation_pct` decimal(5,2) NOT NULL,
  `abstention_pct` decimal(5,2) NOT NULL,
  `bloc_gagnant` varchar(20) NOT NULL,
  `score_gagnant_pct` decimal(5,2) NOT NULL,
  `bloc_gagnant_num` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `resultat_electoral`
--

INSERT INTO `resultat_electoral` (`code_arrondissement`, `id_election`, `inscrits`, `votants`, `participation_pct`, `abstention_pct`, `bloc_gagnant`, `score_gagnant_pct`, `bloc_gagnant_num`) VALUES
(69381, 1, 20845, 12069, 57.90, 42.10, 'gauche', 52.30, 0),
(69381, 2, 22134, 8990, 40.60, 59.40, 'gauche', 54.20, 0),
(69382, 1, 22341, 13452, 60.20, 39.80, 'droite', 54.10, 1),
(69382, 2, 23567, 10234, 43.40, 56.60, 'droite', 52.80, 1),
(69383, 1, 68912, 38123, 55.30, 44.70, 'gauche', 48.70, 0),
(69383, 2, 72345, 28456, 39.30, 60.70, 'gauche', 51.30, 0),
(69384, 1, 25678, 14521, 56.60, 43.40, 'gauche', 51.20, 0),
(69384, 2, 26789, 10234, 38.20, 61.80, 'gauche', 53.10, 0),
(69385, 1, 35421, 20134, 56.80, 43.20, 'gauche', 49.80, 0),
(69385, 2, 36234, 13567, 37.40, 62.60, 'ecologiste', 48.70, 2),
(69386, 1, 38754, 24567, 63.40, 36.60, 'droite', 58.90, 1),
(69386, 2, 40123, 17234, 42.90, 57.10, 'droite', 55.40, 1),
(69387, 1, 54123, 29876, 55.20, 44.80, 'gauche', 47.60, 0),
(69387, 2, 56789, 20456, 36.00, 64.00, 'gauche', 49.80, 0),
(69388, 1, 58967, 30721, 52.10, 47.90, 'gauche', 46.30, 0),
(69388, 2, 62345, 18329, 29.40, 70.60, 'gauche', 52.10, 0),
(69389, 1, 42876, 22556, 52.60, 47.40, 'gauche', 48.90, 0),
(69389, 2, 45678, 14478, 31.70, 68.30, 'gauche', 51.60, 0);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_evolution_participation`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_evolution_participation` (
`nom_arrondissement` varchar(100)
,`participation_2014` decimal(5,2)
,`participation_2020` decimal(5,2)
,`evolution_participation_pts` decimal(6,2)
,`bloc_2014` varchar(20)
,`bloc_2020` varchar(20)
,`changement_bloc` tinyint(4)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_resultats_complets`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_resultats_complets` (
`code_arrondissement` int(11)
,`nom_arrondissement` varchar(100)
,`annee` year(4)
,`libelle_election` varchar(100)
,`inscrits` int(11)
,`votants` int(11)
,`participation_pct` decimal(5,2)
,`abstention_pct` decimal(5,2)
,`bloc_gagnant` varchar(20)
,`score_gagnant_pct` decimal(5,2)
,`pct_cadres` decimal(5,2)
,`revenu_median_uc` decimal(10,2)
,`taux_pauvrete` decimal(5,2)
,`taux_chomage_15_64` decimal(5,2)
,`taux_delinquance_pour_1000` decimal(6,2)
,`indice_dynamisme_eco` decimal(6,3)
,`indice_precarite` decimal(6,3)
,`participation_classe_2020` varchar(10)
,`changement_bloc` tinyint(4)
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_evolution_participation`
--
DROP TABLE IF EXISTS `v_evolution_participation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_evolution_participation`  AS SELECT `a`.`nom_arrondissement` AS `nom_arrondissement`, `r14`.`participation_pct` AS `participation_2014`, `r20`.`participation_pct` AS `participation_2020`, `fml`.`evolution_participation_pts` AS `evolution_participation_pts`, `r14`.`bloc_gagnant` AS `bloc_2014`, `r20`.`bloc_gagnant` AS `bloc_2020`, `fml`.`changement_bloc` AS `changement_bloc` FROM (((`arrondissement` `a` join `resultat_electoral` `r14` on(`r14`.`code_arrondissement` = `a`.`code_arrondissement` and `r14`.`id_election` = 1)) join `resultat_electoral` `r20` on(`r20`.`code_arrondissement` = `a`.`code_arrondissement` and `r20`.`id_election` = 2)) join `features_ml` `fml` on(`fml`.`code_arrondissement` = `a`.`code_arrondissement`)) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_resultats_complets`
--
DROP TABLE IF EXISTS `v_resultats_complets`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_resultats_complets`  AS SELECT `a`.`code_arrondissement` AS `code_arrondissement`, `a`.`nom_arrondissement` AS `nom_arrondissement`, `e`.`annee` AS `annee`, `e`.`libelle_election` AS `libelle_election`, `re`.`inscrits` AS `inscrits`, `re`.`votants` AS `votants`, `re`.`participation_pct` AS `participation_pct`, `re`.`abstention_pct` AS `abstention_pct`, `re`.`bloc_gagnant` AS `bloc_gagnant`, `re`.`score_gagnant_pct` AS `score_gagnant_pct`, `s`.`pct_cadres` AS `pct_cadres`, `s`.`revenu_median_uc` AS `revenu_median_uc`, `s`.`taux_pauvrete` AS `taux_pauvrete`, `s`.`taux_chomage_15_64` AS `taux_chomage_15_64`, `sec`.`taux_delinquance_pour_1000` AS `taux_delinquance_pour_1000`, `eco`.`indice_dynamisme_eco` AS `indice_dynamisme_eco`, `fml`.`indice_precarite` AS `indice_precarite`, `fml`.`participation_classe_2020` AS `participation_classe_2020`, `fml`.`changement_bloc` AS `changement_bloc` FROM ((((((`resultat_electoral` `re` join `arrondissement` `a` on(`a`.`code_arrondissement` = `re`.`code_arrondissement`)) join `election` `e` on(`e`.`id_election` = `re`.`id_election`)) join `indicateur_socioeco` `s` on(`s`.`code_arrondissement` = `re`.`code_arrondissement`)) join `indicateur_securite` `sec` on(`sec`.`code_arrondissement` = `re`.`code_arrondissement`)) join `indicateur_economie` `eco` on(`eco`.`code_arrondissement` = `re`.`code_arrondissement`)) join `features_ml` `fml` on(`fml`.`code_arrondissement` = `re`.`code_arrondissement`)) ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `arrondissement`
--
ALTER TABLE `arrondissement`
  ADD PRIMARY KEY (`code_arrondissement`);

--
-- Index pour la table `election`
--
ALTER TABLE `election`
  ADD PRIMARY KEY (`id_election`);

--
-- Index pour la table `features_ml`
--
ALTER TABLE `features_ml`
  ADD PRIMARY KEY (`id_feature_ml`),
  ADD UNIQUE KEY `code_arrondissement` (`code_arrondissement`);

--
-- Index pour la table `indicateur_associations`
--
ALTER TABLE `indicateur_associations`
  ADD PRIMARY KEY (`id_asso`),
  ADD UNIQUE KEY `code_arrondissement` (`code_arrondissement`);

--
-- Index pour la table `indicateur_economie`
--
ALTER TABLE `indicateur_economie`
  ADD PRIMARY KEY (`id_economie`),
  ADD UNIQUE KEY `code_arrondissement` (`code_arrondissement`);

--
-- Index pour la table `indicateur_securite`
--
ALTER TABLE `indicateur_securite`
  ADD PRIMARY KEY (`id_securite`),
  ADD UNIQUE KEY `code_arrondissement` (`code_arrondissement`);

--
-- Index pour la table `indicateur_socioeco`
--
ALTER TABLE `indicateur_socioeco`
  ADD PRIMARY KEY (`id_indicateur`),
  ADD UNIQUE KEY `code_arrondissement` (`code_arrondissement`);

--
-- Index pour la table `resultat_electoral`
--
ALTER TABLE `resultat_electoral`
  ADD PRIMARY KEY (`code_arrondissement`,`id_election`),
  ADD KEY `fk_re_election` (`id_election`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `election`
--
ALTER TABLE `election`
  MODIFY `id_election` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `features_ml`
--
ALTER TABLE `features_ml`
  MODIFY `id_feature_ml` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `indicateur_associations`
--
ALTER TABLE `indicateur_associations`
  MODIFY `id_asso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `indicateur_economie`
--
ALTER TABLE `indicateur_economie`
  MODIFY `id_economie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `indicateur_securite`
--
ALTER TABLE `indicateur_securite`
  MODIFY `id_securite` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `indicateur_socioeco`
--
ALTER TABLE `indicateur_socioeco`
  MODIFY `id_indicateur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `features_ml`
--
ALTER TABLE `features_ml`
  ADD CONSTRAINT `fk_fml_arr` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `indicateur_associations`
--
ALTER TABLE `indicateur_associations`
  ADD CONSTRAINT `fk_asso_arr` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `indicateur_economie`
--
ALTER TABLE `indicateur_economie`
  ADD CONSTRAINT `fk_economie_arr` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `indicateur_securite`
--
ALTER TABLE `indicateur_securite`
  ADD CONSTRAINT `fk_securite_arr` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `indicateur_socioeco`
--
ALTER TABLE `indicateur_socioeco`
  ADD CONSTRAINT `fk_socioeco_arr` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE;

--
-- Contraintes pour la table `resultat_electoral`
--
ALTER TABLE `resultat_electoral`
  ADD CONSTRAINT `fk_re_arrondissement` FOREIGN KEY (`code_arrondissement`) REFERENCES `arrondissement` (`code_arrondissement`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_re_election` FOREIGN KEY (`id_election`) REFERENCES `election` (`id_election`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
