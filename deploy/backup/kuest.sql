-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Mar 10 Septembre 2013 à 22:04
-- Version du serveur: 5.1.53-community-log
-- Version de PHP: 5.3.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `kuest`
--

-- --------------------------------------------------------

--
-- Structure de la table `kuestevaluations`
--

CREATE TABLE IF NOT EXISTS `kuestevaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `kid` int(11) NOT NULL,
  `note` int(11) NOT NULL,
  `noteBase` int(11) NOT NULL COMMENT 'note before ponderation',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `kuestevaluations`
--

INSERT INTO `kuestevaluations` (`id`, `uid`, `kid`, `note`, `noteBase`) VALUES
(1, 12832, 7, 32, 16),
(2, 490251, 7, 38, 11),
(3, 490251, 36, 32, 5),
(4, 490251, 32, 37, 10);

-- --------------------------------------------------------

--
-- Structure de la table `kuests`
--

CREATE TABLE IF NOT EXISTS `kuests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guid` varchar(30) NOT NULL,
  `uid` int(11) NOT NULL,
  `lang` varchar(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `dataFile` varchar(100) NOT NULL,
  `published` tinyint(1) NOT NULL,
  `friends` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=53 ;

--
-- Contenu de la table `kuests`
--

INSERT INTO `kuests` (`id`, `guid`, `uid`, `lang`, `name`, `description`, `dataFile`, `published`, `friends`) VALUES
(5, '518c2438b9adf', 89, 'fr', 'Le pêcheur', 'Le pêcheur te salue et te demande ce que tu souhaites !', '1', 1, ''),
(7, '5194100a4a94f', 89, 'fr', 'Le Cristal Atlante.', 'Faites une petite course pour le pêcheur qui désire posséder l''antique Cristal Atlante.\rTout débute à l''origine en [0;0] !', '2', 1, ',883172,'),
(10, '519c25825821e', 6493, 'fr', 'test 1', 'rrr', '5', 0, ''),
(11, '519e7fe42ff5a', 754, 'fr', 'La chasse aux infos', 'Alors que les nouveaux Kommandants ont pris place dans la zone du Karré (en [1][0]), certaines personnes disent avoir vue une étrange silhouette roder dans le bâtiment le soir. Que peut-il bien vouloir ? ', '6', 0, ''),
(32, '51a208528d819', 883172, 'fr', 'Le nouveau gardien', 'Vous êtes le nouveau gardien de l''Assemblée des Augures. Rendez-vous en [0][42] pour découvrir votre première mission.', 'r', 1, ''),
(24, '51a1e15e398b4', 357393, 'fr', 'Rune des dieux', 'A la conquète de la voix des étoiles.\rRendez vous en [0][42] pour le départ!', 'j', 0, ',89,'),
(36, '51a8737f93644', 274, 'fr', 'Le labyrinthe de Tubasa', 'Résoudre le labyrinthe de Tubasa en [10;-8]', 'v', 1, ',89,883172,'),
(34, '51a20bafb6bc6', 12832, 'fr', 'La pierre du conseiller', 'Le conseiller des atlantes vous attend à l''ambassade en -1/3, il semble qu''il est une mission à vous confier.', 't', 0, ''),
(41, '51ad0d08dc8c8', 0, 'fr', '1) Messages uniques indépendants', 'Exemple de messages uniques sur des zones différentes n''ayant aucune dépendance les uns avec les autres.\nChaque message se déclenchera lorsque le joueur arrivera dans la zone concernée.', '_1', 0, ',89,'),
(39, '51aa7b6cbe1ef', 89, 'fr', 'Le labyrinthe de Tubasa (v2)', 'Résoudre le labyrinthe de Tubasa en [10;-8]', 'y', 0, ''),
(31, '51a207ff98070', 883172, 'fr', 'Le nouveau gardien', 'Vous êtes le nouveau gardien de l''Assemblée des Augures. Rendez-vous en [0][42] pour découvrir votre première mission.', 'q', 0, ',89,'),
(42, '51ad0ec570134', 0, 'fr', '2) Dépendances d''événements', 'Cet exemple montre comment rendre des événements dépendants les uns des autres.\nUn événement lié à un autre ne sera accessible que lorsque l''événement auquel il est lié aura été terminé.', '_2', 0, ',89,'),
(43, '51ad0fe2f0aa8', 0, 'fr', '3) Proposer des choix', 'Cet exemple vous montre comment proposer des choix au joueur.', '_3', 0, ',89,'),
(44, '51ad12eca65b6', 0, 'fr', '4) Donner et utiliser des objets.', 'Cet exemple vous montre comment donner un objet au joueur puis lui demander de l''utiliser.', '_4', 0, ',89,'),
(45, '51ae54669c980', 0, 'fr', '5) Evénements temporels', 'Exemple d''événements déclanchés seulement durant certaines tranches horaires ou à certaines dates précises.', '_5', 0, ',89,'),
(46, '51b08a75da1a6', 12832, 'fr', 'Test boucle', 'Mais qui est cette Florence en 0,0 ?', 'F', 0, ''),
(47, '51b50eb07dcfb', 89, 'fr', 'Voyage en Atlantide', 'Visite guidée et diverses quêtes autour de l''Atlantide.', 'G', 0, ''),
(49, '51ebe46078038', 490251, 'fr', 'Corne d''abondance (à finir)', 'Il faut rechercher la corne d''abondance ! :D', 'I', 0, ',89,'),
(52, '51ec728f16b49', 490251, 'fr', 'Où est passée Mlle Grey ?', 'En compagnie de Logan et Scott, vous allez partir à la recherche de Jean Grey.\rL''aventure commence en [0][0] et ne dépasse pas l''entre-axe 5.\rBon courage et bonne chance !', 'L', 0, ',89,'),
(50, '51ebfedd68897', 490251, 'fr', 'Trocs à volonté !', 'L''objectif est de visiter des zones louées comportant une oeuvre ou un stock. Vous rencontrerez sur ces zones, divers joueurs qui vous proposeront des échanges d''objets.\rCommencez par la [0][0], Musaran vous y attend !\rPS: ne sortez pas de l''entre-axe 15.', 'J', 0, ',89,');

-- --------------------------------------------------------

--
-- Structure de la table `kuestsaves`
--

CREATE TABLE IF NOT EXISTS `kuestsaves` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT 'User ID',
  `kid` int(11) NOT NULL COMMENT 'Kuest ID',
  `dataFile` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=54 ;

--
-- Contenu de la table `kuestsaves`
--

INSERT INTO `kuestsaves` (`id`, `uid`, `kid`, `dataFile`) VALUES
(1, 89, 36, '51a8737f93644_89'),
(17, 12832, 7, '5194100a4a94f_12832'),
(11, 12832, 34, '51a20bafb6bc6_12832'),
(15, 12832, 46, '51b08a75da1a6_12832'),
(22, 89, 44, '51ad12eca65b6_89'),
(26, 490251, 7, '5194100a4a94f_490251'),
(27, 490251, 36, '51a8737f93644_490251'),
(28, 490251, 32, '51a208528d819_490251'),
(29, 490251, 5, '518c2438b9adf_490251'),
(30, 490251, 49, '51ebe46078038_490251'),
(46, 490251, 50, '51ebfedd68897_490251');

-- --------------------------------------------------------

--
-- Structure de la table `kuestusers`
--

CREATE TABLE IF NOT EXISTS `kuestusers` (
  `uid` int(11) NOT NULL COMMENT 'muxxu UID',
  `name` varchar(50) NOT NULL,
  `oAuthCode` varchar(255) NOT NULL,
  UNIQUE KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Contenu de la table `kuestusers`
--

INSERT INTO `kuestusers` (`uid`, `name`, `oAuthCode`) VALUES
(89, 'Durss', 'b22d9ff9'),
(133901, 'Suiren', 'c7cc0ba7'),
(357393, 'MlleNolwenn', '3f893a5d'),
(883172, 'Lilith', '8c5c133f'),
(754, 'TheFreeStyle', 'bf022319'),
(6493, 'Sunsky', '1348fc50'),
(1431720, 'schizoko', '3141e823'),
(12832, 'Colapsydo', '0f8fd0bf'),
(671, 'Selliato', 'dbe7fc6b'),
(274, 'Tubasa', 'ea9dfc69'),
(703, 'Bugzilla', '5bc486a8'),
(589, 'Musaran', 'd9a64a0e'),
(490251, 'Tom_', '72c29fa6'),
(3916, 'newSunshine', '06129784'),
(48, 'Durss', 'wQtH9jGgdMJR9mUi9XiuHyiI6FDxqlCy');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
