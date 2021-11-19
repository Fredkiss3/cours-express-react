-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : db
-- Généré le : ven. 19 nov. 2021 à 15:58
-- Version du serveur : 10.6.4-MariaDB-1:10.6.4+maria~focal
-- Version de PHP : 7.4.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `ragnarok`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`%` PROCEDURE `AjouterLigneCommande` (IN `quantite` INT, IN `command_id` INT, IN `produit_id` INT)  BEGIN
    INSERT INTO LigneCommande(quantite, commande_id, produit_id) VALUES (quantite, command_id, produit_id);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `AppliquerCodePromo` (IN `code_promo_id` INT, IN `commande_id` INT)  BEGIN
    DECLARE nb_utilisations INT;
    DECLARE nb_utilisationsMax INT;
    DECLARE sommeMin FLOAT;
    DECLARE sommeCommande FLOAT;
    DECLARE date_debut DATE;
    DECLARE date_fin DATE;

    # Vérifier que le nombre d'utilisations du code promo n'est pas dépassé
SELECT nombreUtilisationMax, dateDebut, dateExpiration, sommeMinimum
INTO nb_utilisationsMax, date_debut, date_fin, sommeMin
FROM CodePromo
WHERE id = code_promo_id;

SELECT COUNT(codepromo_id)
INTO nb_utilisations
FROM Commande
WHERE codepromo_id = code_promo_id
  AND codepromo_id IS NOT NULL;

# Vérifier que le nombre d'utilisations du code promo n'est pas dépassé
    if (nb_utilisations >= nb_utilisationsMax) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Le code promo est déjà utilisé trop de fois';
END IF;

    # Vérifier que la promo est encore valide
    if (date_debut > NOW() OR date_fin < NOW()) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La promo n''est plus valide';
END IF;

    # Vérifier que la somme minimum est atteinte pour appliquer le code promo
    SET sommeCommande = CalculerSommeLignesCommande(commande_id);

    if (sommeCommande < sommeMin) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La somme minimum pour appliquer le code promo n''est pas atteinte';
END IF;

    # Application du code promo sur  la commande
UPDATE Commande
SET codepromo_id = code_promo_id
WHERE id = commande_id;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `ChangerStatutCommande` (IN `statut` ENUM('EXPEDIE','LIVRAISON','LIVREE','REMBOURSEE','PREPARATION'), IN `commande_id` INT)  BEGIN
UPDATE Commande as c
SET c.statut = statut
WHERE c.id = commande_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerAdresse` (IN `idPersonne` INT, IN `estPrestaire` BOOLEAN, IN `rue` VARCHAR(255), IN `codePostal` VARCHAR(5), IN `ville` VARCHAR(40), IN `pays` VARCHAR(40))  BEGIN
   IF estPrestaire = 1 THEN
      INSERT INTO Adresse(rue, codePostal, ville, pays, prestataire_id) VALUES(rue, codePostal, ville, pays, idPersonne);
ELSE
   	 INSERT INTO  Adresse(rue, codePostal, ville, pays, client_id) VALUES(rue, codePostal, ville, pays, idPersonne);
END IF;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerAvis` (IN `note` INT(1), IN `commentaire` TEXT, IN `client_id` INT, IN `produit_id` INT)  BEGIN
	IF (note > 5 || note < 0) THEN
    	SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La note doit être comprise entre 0 et 5';
END IF;

INSERT INTO Avis(date, note, commentaire, client_id, produit_id)
VALUES(NOW(), note, commentaire, client_id, produit_id);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerClient` (IN `nom` VARCHAR(40), IN `prenom` VARCHAR(40), IN `email` VARCHAR(255), IN `mdpHash` VARCHAR(255))  BEGIN
	INSERT INTO Client(nom, prenom, email, mdp) VALUES (nom, prenom, email, mdpHash);
INSERT INTO Portefeuille(client_id) VALUES(LAST_INSERT_ID());

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerCommande` (IN `addresse_livraison_id` INT)  BEGIN
    INSERT INTO Commande(adresse_livraison_id)  VALUES (addresse_livraison_id);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerPrestataire` (IN `nom` VARCHAR(40), IN `prenom` VARCHAR(40), IN `email` VARCHAR(255), IN `telephone` VARCHAR(15), IN `mdp` VARCHAR(15), IN `rue` VARCHAR(255), IN `codePostal` VARCHAR(5), IN `ville` VARCHAR(40), IN `pays` VARCHAR(40))  BEGIN
  INSERT
  	INTO Prestataire(nom, prenom, email, telephone, mdp)
    VALUES(nom, prenom, email, telephone, mdp);


CALL CreerAdresse(LAST_INSERT_ID(), 1, rue, codePostal, ville, pays );

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `CreerProduit` (`nom` VARCHAR(255), `prix` FLOAT UNSIGNED, `stock` INT(11), `image` VARCHAR(255), `description` TEXT, `prestataire_id` INT(11))  BEGIN

      INSERT INTO Produit(nom, prix, stock, image, description, prestataire_id)
      VALUES(nom,prix, stock, image, description, prestataire_id);

    END$$

CREATE DEFINER=`root`@`%` PROCEDURE `EffectuerPayement` (IN `mode` ENUM('BTC','PAYPAL','CB','PORTEFEUILLE'), IN `commande_id` INT, IN `client_id` INT, IN `adresse_facturation_id` INT)  BEGIN
    DECLARE somme FLOAT;
    DECLARE produit_id INT;
    DECLARE quantite INT;
    DECLARE finished BOOLEAN DEFAULT 0;

    # créer un curseur pour parcourir les lignes de la commande
    DEClARE cursorLigne CURSOR FOR (SELECT lc.produit_id, lc.quantite FROM LigneCommande as lc
        WHERE lc.commande_id = commande_id);
    # Quant le curseur ne trouve plus de ligne, mettre finished à 1 pour indiquer que le traitement est terminé
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    # On récupère la somme de la commande
    SET somme = CalculerSommeCommandeTTC(commande_id);

    # Insérer le paiement
    INSERT INTO Paiement(`mode`, `somme`, `date`, `commande_id`, `adresse_facturation_id`, `client_id`)
        VALUES (mode, somme, NOW(), commande_id, adresse_facturation_id, client_id);

    # Ouverture  du curseur
    OPEN cursorLigne;

    # On met à jour le stock de chaque produit présent dans la commande
    WHILE finished = 0 DO
        # Récupération l'Id du produit & la quantité de la ligne suivante
        FETCH cursorLigne INTO produit_id, quantite;

        # On met à jour le stock du produit concerné
        UPDATE Produit
            SET stock = stock - quantite
            WHERE id = produit_id;

    END WHILE;
    # Fermeture du curseur
    CLOSE cursorLigne;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetAllProduits` ()  BEGIN
   SELECT * FROM Produit;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetAvisForProduit` (IN `produit_id` INT)  BEGIN
   SELECT * FROM Avis AS a WHERE a.produit_id=produit_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetClientParEmail` (IN `email` VARCHAR(255))  BEGIN
	SELECT * FROM Client AS c WHERE c.email=email;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetClientParId` (IN `id` INT)  BEGIN
	SELECT *
    	FROM Client AS c
        WHERE c.id=id;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetCodePromoParCode` (IN `code` VARCHAR(15))  BEGIN
    SELECT * FROM CodePromo AS cp WHERE cp.code = code;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetFicheProduit` (IN `produit_id` INT)  BEGIN
   CALL GetProduit(produit_id);
   CALL GetAvisForProduit(produit_id);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetPaymentHistorique` (IN `clientID` INT)  BEGIN
	SELECT p.*
    	FROM Paiement AS p
        JOIN Client AS c
 	       ON c.id=p.client_id
    	    AND c.id=clientID
        ORDER BY p.date DESC;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetProduit` (IN `id` INT)  BEGIN
   SELECT * FROM Produit AS p WHERE p.id=id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `GetResumeAvisForProduit` (IN `prod_id` INT, OUT `total_5_etoiles` FLOAT, OUT `total_4_etoiles` FLOAT, OUT `total_3_etoiles` FLOAT, OUT `total_2_etoiles` FLOAT, OUT `total_1_etoiles` FLOAT, OUT `total_avis` INT)  BEGIN
    DECLARE avis_5_etoiles INT DEFAULT 0;
    DECLARE avis_4_etoiles INT DEFAULT 0;
    DECLARE avis_3_etoiles INT DEFAULT 0;
    DECLARE avis_2_etoiles INT DEFAULT 0;
    DECLARE avis_1_etoiles INT DEFAULT 0;
#     DECLARE total_avis INT DEFAULT 0;

    DECLARE note_avis INT;
    DECLARE finished BOOLEAN DEFAULT 0;

    # créer un curseur pour parcourir les lignes de la commande
    DEClARE cursorAvis CURSOR FOR (SELECT a.note FROM Avis AS a WHERE a.produit_id=prod_id AND a.note>0);
    # Quant le curseur ne trouve plus de ligne, mettre finished à 1 pour indiquer que le traitement est terminé
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    SELECT COUNT(*) INTO total_avis FROM Avis AS a WHERE a.produit_id=prod_id AND a.note>0;

    OPEN cursorAvis;

    # On met à jour le stock de chaque produit présent dans la commande
    WHILE finished = 0 DO
        FETCH cursorAvis INTO note_avis;

        CASE note_avis
            WHEN 5 THEN
                SET avis_5_etoiles = avis_5_etoiles + 1;
            WHEN 4 THEN
                SET avis_4_etoiles = avis_4_etoiles + 1;
            WHEN 3 THEN
                SET avis_3_etoiles = avis_3_etoiles + 1;
            WHEN 2 THEN
                SET avis_2_etoiles = avis_2_etoiles + 1;
            WHEN 1 THEN
                SET avis_1_etoiles = avis_1_etoiles + 1;
            ELSE
                BEGIN
                END;
        END CASE;

    end while;

    CLOSE cursorAvis;

    IF total_avis = 0 THEN
        SET total_avis = 1;
    END IF;

    SET total_5_etoiles = (avis_5_etoiles / total_avis) ;
    SET total_4_etoiles = (avis_4_etoiles / total_avis) ;
    SET total_3_etoiles = (avis_3_etoiles / total_avis) ;
    SET total_2_etoiles = (avis_2_etoiles / total_avis) ;
    SET total_1_etoiles = (avis_1_etoiles / total_avis) ;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `ModifierProduit` (IN `produit_id` INT, IN `nom` VARCHAR(40), IN `prix` INT, IN `description` TEXT, IN `image` VARCHAR(255), IN `quantite` INT)  BEGIN
    UPDATE Produit as p
    SET p.nom = nom,
        p.prix = prix,
        p.description = description,
        p.image = image,
        p.stock = quantite
    WHERE p.id = produit_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `RechercherProduit` (IN `nomProduit` VARCHAR(255))  BEGIN
	SELECT * FROM Produit as p WHERE
    	LOWER(p.nom) LIKE concat('%', LOWER(nomProduit), '%');
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `RembourserClient` (IN `ligne_commande_id` INT, IN `prestataire_id` INT)  BEGIN
    DECLARE montant_remboursement INT;
    DECLARE id_client INT;
    DECLARE id_coupon INT;
    DECLARE montant_reduction FLOAT;
    DECLARE reduction_pourcentage FLOAT;

    # Calcul du montant à rembourser et récupération de l'id du client
SELECT (l.quantite * p.prix), CP.reduction, PY.client_id
INTO montant_remboursement, reduction_pourcentage, id_client
FROM LigneCommande as l
         JOIN Produit as p
              ON l.produit_id = p.id
         JOIN Commande CMD
              ON l.commande_id = CMD.id
         JOIN CodePromo CP
              ON CP.id = CMD.codepromo_id
         JOIN Paiement PY
              ON CMD.id = PY.commande_id
WHERE l.id = ligne_commande_id;

#  calculer le montant de la réduction
    SET montant_reduction = montant_remboursement * (reduction_pourcentage / 100);

    #  retirer le montant de la réduction
    SET montant_remboursement = montant_remboursement - montant_reduction;

    # Ajouter les taxes
    SET montant_remboursement = montant_remboursement + (montant_remboursement * 0.2);


    # Créer un coupon pour le client
    SET id_coupon = CreerCoupon(
            concat('Remboursement ligne de commande n°', ligne_commande_id),
            DATE_ADD(CURDATE(), INTERVAL 30 DAY),
            montant_remboursement,
            id_client
        );

    # Insérer le remboursement dans la table Remboursement
    INSERT INTO Remboursement(date, montant, coupon_id, ligne_commande_id, prestataire_id)
    VALUES (CURDATE(), montant_remboursement, NULL, ligne_commande_id, prestataire_id);

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `TransfererCoupon` (IN `coupon_id` INT, IN `client_id` INT)  BEGIN
    DECLARE coupon_utilise BOOLEAN DEFAULT FALSE;

SELECT utilise INTO coupon_utilise FROM Coupon as cp WHERE cp.id = coupon_id;

IF coupon_utilise THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Coupon déjà utilisé, il ne peut plus être transféré';
ELSE
UPDATE Coupon as cp
SET cp.client_id = client_id
WHERE cp.id = coupon_id;
END IF;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `UtiliserCoupon` (IN `coupon_id` INT)  BEGIN
    DECLARE portefeuille_id INT;
    DECLARE somme_coupon INT;
    DECLARE date_expiration_coupon INT;

    # Récupérer l'id du portefeuille ainsi que la somme du coupon
    SELECT pf.id, cp.somme, cp.dateExpiration
        INTO portefeuille_id, somme_coupon, date_expiration_coupon
        FROM Portefeuille AS pf
            JOIN Client cl on cl.id = pf.client_id
            JOIN Coupon cp on cp.id = coupon_id
        WHERE cp.id = coupon_id;

    # Vérifier si le coupon est valide
    IF date_expiration_coupon < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Le coupon est expiré';
    END IF;

    # mettre à jour le portefeuille
    UPDATE Portefeuille as pf
        SET pf.solde = pf.solde + somme_coupon
        WHERE pf.id = portefeuille_id;

    # Indiquer que le coupon a été utilisé
    UPDATE Coupon as cp
        SET cp.utilise = 1
        WHERE cp.id = coupon_id;
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`%` FUNCTION `CalculerSommeCommandeTTC` (`commande_id` INT) RETURNS FLOAT BEGIN
    DECLARE sommeCommande FLOAT;
    DECLARE reductionCodePromo FLOAT DEFAULT NULL;

    # Calculer la somme des lignes de commande
    SET sommeCommande = CalculerSommeLignesCommande(commande_id);

    # Récupérer le code promo s'il y en a un
SELECT reduction
INTO reductionCodePromo
FROM CodePromo as cp
         JOIN Commande cmd on cp.id = cmd.codepromo_id
WHERE cmd.id = commande_id;

# Si le code promo est valide, appliquer la réduction du code promo
    IF reductionCodePromo IS NOT NULL THEN
        SET sommeCommande = sommeCommande - (sommeCommande * (reductionCodePromo / 100)); -- 20%
END IF;


    # Ajouter les taxes (20%)
    SET sommeCommande = sommeCommande + (sommeCommande * 0.2);

RETURN sommeCommande;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `CalculerSommeLignesCommande` (`commande_id` INT) RETURNS FLOAT BEGIN
    DECLARE sommeTotale FLOAT;

    # Calculer la somme des lignes de commandes * prix de chaque produit
SELECT SUM(line.quantite * prod.prix)
INTO sommeTotale
FROM LigneCommande as line
         JOIN Produit as prod
              ON line.produit_id = prod.id
WHERE line.commande_id = commande_id;

# Retourner la somme
    RETURN sommeTotale;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `CreerCoupon` (`code` VARCHAR(255), `dateExpiration` DATE, `somme` FLOAT, `client_id` INT) RETURNS INT(11) BEGIN
    INSERT INTO Coupon (code, dateExpiration, somme, client_id, utilise)
    VALUES (code, dateExpiration, somme, client_id, 0);

RETURN LAST_INSERT_ID();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `Adresse`
--

CREATE TABLE `Adresse` (
                           `id` int(11) NOT NULL,
                           `rue` varchar(255) NOT NULL,
                           `codePostal` int(5) UNSIGNED ZEROFILL NOT NULL,
                           `ville` varchar(40) NOT NULL,
                           `pays` varchar(40) NOT NULL,
                           `prestataire_id` int(11) DEFAULT NULL,
                           `client_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Adresse`
--

INSERT INTO `Adresse` (`id`, `rue`, `codePostal`, `ville`, `pays`, `prestataire_id`, `client_id`) VALUES
                                                                                                      (2, '1 rue de poitiers', 35042, 'RENNES', 'France', 8, NULL),
                                                                                                      (3, '1 rue de poitiers', 35042, 'RENNES', 'France', 9, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `Avis`
--

CREATE TABLE `Avis` (
                        `id` int(11) NOT NULL,
                        `date` date NOT NULL,
                        `note` int(1) NOT NULL DEFAULT 5,
                        `commentaire` text NOT NULL,
                        `client_id` int(11) NOT NULL,
                        `produit_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Avis`
--

INSERT INTO `Avis` (`id`, `date`, `note`, `commentaire`, `client_id`, `produit_id`) VALUES
    (1, '2021-11-16', 5, 'Hello world', 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `Client`
--

CREATE TABLE `Client` (
                          `id` int(11) NOT NULL,
                          `nom` varchar(40) NOT NULL,
                          `prenom` varchar(40) NOT NULL,
                          `email` varchar(255) NOT NULL,
                          `mdp` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Client`
--

INSERT INTO `Client` (`id`, `nom`, `prenom`, `email`, `mdp`) VALUES
                                                                 (1, 'John', 'Doe', 'john@doe.Fr', 'password'),
                                                                 (2, 'Aspirateur', 'Doe', 'fredkiss2018@gmail.com', 'password'),
                                                                 (3, 'Booba', 'B20', 'b20@booba.fr', 'mdp'),
                                                                 (4, 'Jason', 'Statam', 'jason@statam.com', 'jason le boss'),
                                                                 (6, 'Jason', 'Statam', 'jason@statam2.com', '$2b$12$vcki/wjSOChdvh6KhWAlwO5pQGePA2wvVMjK7LSldAb1lnHCF8d.m');

-- --------------------------------------------------------

--
-- Structure de la table `CodePromo`
--

CREATE TABLE `CodePromo` (
                             `id` int(11) NOT NULL,
                             `code` varchar(255) NOT NULL,
                             `sommeMinimum` float NOT NULL,
                             `reduction` int(11) NOT NULL,
                             `dateDebut` date NOT NULL,
                             `dateExpiration` date NOT NULL,
                             `nombreUtilisationMax` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `Commande`
--

CREATE TABLE `Commande` (
                            `id` int(11) NOT NULL,
                            `date` date NOT NULL,
                            `statut` enum('EXPEDIE','LIVRAISON','LIVREE','REMBOURSEE','PREPARATION') NOT NULL DEFAULT 'PREPARATION',
                            `codepromo_id` int(11) DEFAULT NULL,
                            `adresse_livraison_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `Coupon`
--

CREATE TABLE `Coupon` (
                          `id` int(11) NOT NULL,
                          `code` varchar(255) NOT NULL,
                          `dateExpiration` date NOT NULL,
                          `somme` float NOT NULL,
                          `utilise` tinyint(1) NOT NULL DEFAULT 0,
                          `client_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `LigneCommande`
--

CREATE TABLE `LigneCommande` (
                                 `id` int(11) NOT NULL,
                                 `quantite` int(11) NOT NULL,
                                 `commande_id` int(11) NOT NULL,
                                 `produit_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `Paiement`
--

CREATE TABLE `Paiement` (
                            `id` int(11) NOT NULL,
                            `mode` enum('BTC','PAYPAL','CB','PORTEFEUILLE') NOT NULL,
                            `somme` float NOT NULL,
                            `date` datetime NOT NULL,
                            `commande_id` int(11) NOT NULL,
                            `adresse_facturation_id` int(11) NOT NULL,
                            `client_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `Portefeuille`
--

CREATE TABLE `Portefeuille` (
                                `id` int(11) NOT NULL,
                                `solde` int(11) NOT NULL DEFAULT 0,
                                `client_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Portefeuille`
--

INSERT INTO `Portefeuille` (`id`, `solde`, `client_id`) VALUES
                                                            (1, 0, 1),
                                                            (2, 0, 2),
                                                            (3, 0, 3),
                                                            (4, 0, 4),
                                                            (5, 0, 6);

-- --------------------------------------------------------

--
-- Structure de la table `Prestataire`
--

CREATE TABLE `Prestataire` (
                               `id` int(11) NOT NULL,
                               `nom` varchar(40) NOT NULL,
                               `prenom` varchar(40) NOT NULL,
                               `email` varchar(255) NOT NULL,
                               `telephone` varchar(15) NOT NULL,
                               `mdp` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Prestataire`
--

INSERT INTO `Prestataire` (`id`, `nom`, `prenom`, `email`, `telephone`, `mdp`) VALUES
                                                                                   (8, 'John', 'Doe', 'john@doe.fr', '+33752424305', 'password'),
                                                                                   (9, 'John', 'Doe', 'istic-contact@univ-rennes1.fr', '+33223233535', 'password');

-- --------------------------------------------------------

--
-- Structure de la table `Produit`
--

CREATE TABLE `Produit` (
                           `id` int(11) NOT NULL,
                           `nom` varchar(255) NOT NULL,
                           `prix` float UNSIGNED NOT NULL,
                           `stock` int(11) UNSIGNED NOT NULL DEFAULT 1,
                           `image` varchar(255) NOT NULL,
                           `description` text NOT NULL,
                           `prestataire_id` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `Produit`
--

INSERT INTO `Produit` (`id`, `nom`, `prix`, `stock`, `image`, `description`, `prestataire_id`) VALUES
                                                                                                   (1, 'Aspirateur', 2, 1, 'https://picsum.photos/seed/aspi/200/300', 'Généralement, on utilise un texte en faux latin (le texte ne veut rien dire, il a été modifié), le Lorem ipsum ou Lipsum, qui permet donc de faire office de texte d\'attente. L\'avantage de le mettre en latin est que l\'opérateur sait au premier coup d\'oeil que la page contenant ces lignes n\'est pas valide, et surtout l\'attention du client n\'est pas dérangée par le contenu, il demeure concentré seulement sur l\'aspect graphique.  Ce texte a pour autre avantage d\'utiliser des mots de longueur variable, essayant de simuler une occupation normale. La méthode simpliste consistant à copier-coller un court texte plusieurs fois (« ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ») a l\'inconvénient de ne pas permettre une juste appréciation typographique du résultat final.  Il circule des centaines de versions différentes du Lorem ipsum, mais ce texte aurait originellement été tiré de l\'ouvrage de Cicéron, De Finibus Bonorum et Malorum (Liber Primus, 32), texte populaire à cette époque, dont l\'une des premières phrases est : « Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit... » (« Il n\'existe personne qui aime la souffrance pour elle-même, ni qui la recherche ni qui la veuille pour ce qu\'elle est... »).', 8),
                                                                                                   (2, 'Ananas', 5, 10, 'https://picsum.photos/seed/ananas/200/300', 'Généralement, on utilise un texte en faux latin (le texte ne veut rien dire, il a été modifié), le Lorem ipsum ou Lipsum, qui permet donc de faire office de texte d\'attente. L\'avantage de le mettre en latin est que l\'opérateur sait au premier coup d\'oeil que la page contenant ces lignes n\'est pas valide, et surtout l\'attention du client n\'est pas dérangée par le contenu, il demeure concentré seulement sur l\'aspect graphique.  Ce texte a pour autre avantage d\'utiliser des mots de longueur variable, essayant de simuler une occupation normale. La méthode simpliste consistant à copier-coller un court texte plusieurs fois (« ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ») a l\'inconvénient de ne pas permettre une juste appréciation typographique du résultat final.  Il circule des centaines de versions différentes du Lorem ipsum, mais ce texte aurait originellement été tiré de l\'ouvrage de Cicéron, De Finibus Bonorum et Malorum (Liber Primus, 32),', 8),
(3, 'Bouteille Cristalline', 0.15, 100, 'https://picsum.photos/seed/crista/200/300', 'Généralement, on utilise un texte en faux latin (le texte ne veut rien dire, il a été modifié), le Lorem ipsum ou Lipsum, qui permet donc de faire office de texte d\'attente. L\'avantage de le mettre en latin est que l\'opérateur sait au premier coup d\'oeil que la page contenant ces lignes n\'est pas valide, et surtout l\'attention du client n\'est pas dérangée par le contenu, il demeure concentré seulement sur l\'aspect graphique.  Ce texte a pour autre avantage d\'utiliser des mots de longueur variable, essayant de simuler une occupation normale. La méthode simpliste consistant à copier-coller un court texte plusieurs fois (« ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ceci est un faux-texte ») a l\'inconvénient de ne pas permettre une juste appréciation typographique du résultat final.  Il circule des centaines de versions différentes du Lorem ipsum, mais ce texte aurait originellement été tiré de l\'ouvrage de Cicéron, De Finibus Bonorum et Malorum (Liber Primus, 32),', 8),
                                                                                                   (4, 'Brosse à dents', 120, 10, 'https://picsum.photos/seed/dents/200/300', 'Avec cette brosse à dents, vous souriez à la vie !', 8),
                                                                                                   (5, 'Montre GUCCI', 50, 0, 'https://picsum.photos/seed/gucci/200/300', 'Montre collector pour frimer devant vos amis', 8);

-- --------------------------------------------------------

--
-- Structure de la table `Remboursement`
--

CREATE TABLE `Remboursement` (
                                 `id` int(11) NOT NULL,
                                 `date` date NOT NULL,
                                 `montant` float NOT NULL,
                                 `coupon_id` int(11) DEFAULT NULL,
                                 `ligne_commande_id` int(11) NOT NULL,
                                 `prestataire_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `Adresse`
--
ALTER TABLE `Adresse`
    ADD PRIMARY KEY (`id`),
  ADD KEY `fk_prestataire_id` (`prestataire_id`),
  ADD KEY `fk_client_id` (`client_id`);

--
-- Index pour la table `Avis`
--
ALTER TABLE `Avis`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `client_id` (`client_id`),
  ADD KEY `fk_produit_avis_id` (`produit_id`);

--
-- Index pour la table `Client`
--
ALTER TABLE `Client`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `CodePromo`
--
ALTER TABLE `CodePromo`
    ADD PRIMARY KEY (`id`);

--
-- Index pour la table `Commande`
--
ALTER TABLE `Commande`
    ADD PRIMARY KEY (`id`),
  ADD KEY `fk_codepromo_commande_id` (`codepromo_id`),
  ADD KEY `fk_adresse_livraison_commande_id` (`adresse_livraison_id`);

--
-- Index pour la table `Coupon`
--
ALTER TABLE `Coupon`
    ADD PRIMARY KEY (`id`),
  ADD KEY `fk_client_coupon_id` (`client_id`);

--
-- Index pour la table `LigneCommande`
--
ALTER TABLE `LigneCommande`
    ADD PRIMARY KEY (`id`),
  ADD KEY `fk_command_ligne_id` (`commande_id`),
  ADD KEY `fk_produit_ligne_id` (`produit_id`);

--
-- Index pour la table `Paiement`
--
ALTER TABLE `Paiement`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `commande_id` (`commande_id`),
  ADD KEY `fk_adresse_facturation_paiement_id` (`adresse_facturation_id`),
  ADD KEY `fk_client_paiement_id` (`client_id`);

--
-- Index pour la table `Portefeuille`
--
ALTER TABLE `Portefeuille`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `client_id` (`client_id`);

--
-- Index pour la table `Prestataire`
--
ALTER TABLE `Prestataire`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `Produit`
--
ALTER TABLE `Produit`
    ADD PRIMARY KEY (`id`),
  ADD KEY `fk_product_prestataire_id` (`prestataire_id`);

--
-- Index pour la table `Remboursement`
--
ALTER TABLE `Remboursement`
    ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ligne_commande_id` (`ligne_commande_id`),
  ADD UNIQUE KEY `coupon_id` (`coupon_id`),
  ADD KEY `fk_prestataire_remboursement_id` (`prestataire_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `Adresse`
--
ALTER TABLE `Adresse`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `Avis`
--
ALTER TABLE `Avis`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `Client`
--
ALTER TABLE `Client`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `CodePromo`
--
ALTER TABLE `CodePromo`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `Commande`
--
ALTER TABLE `Commande`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `Coupon`
--
ALTER TABLE `Coupon`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `LigneCommande`
--
ALTER TABLE `LigneCommande`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `Paiement`
--
ALTER TABLE `Paiement`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `Portefeuille`
--
ALTER TABLE `Portefeuille`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `Prestataire`
--
ALTER TABLE `Prestataire`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `Produit`
--
ALTER TABLE `Produit`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `Remboursement`
--
ALTER TABLE `Remboursement`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `Adresse`
--
ALTER TABLE `Adresse`
    ADD CONSTRAINT `fk_client_id` FOREIGN KEY (`client_id`) REFERENCES `Client` (`id`),
  ADD CONSTRAINT `fk_prestataire_id` FOREIGN KEY (`prestataire_id`) REFERENCES `Prestataire` (`id`);

--
-- Contraintes pour la table `Avis`
--
ALTER TABLE `Avis`
    ADD CONSTRAINT `fk_client_avis_id` FOREIGN KEY (`client_id`) REFERENCES `Client` (`id`),
  ADD CONSTRAINT `fk_produit_avis_id` FOREIGN KEY (`produit_id`) REFERENCES `Produit` (`id`);

--
-- Contraintes pour la table `Commande`
--
ALTER TABLE `Commande`
    ADD CONSTRAINT `fk_adresse_livraison_commande_id` FOREIGN KEY (`adresse_livraison_id`) REFERENCES `Adresse` (`id`),
  ADD CONSTRAINT `fk_codepromo_commande_id` FOREIGN KEY (`codepromo_id`) REFERENCES `CodePromo` (`id`);

--
-- Contraintes pour la table `Coupon`
--
ALTER TABLE `Coupon`
    ADD CONSTRAINT `fk_client_coupon_id` FOREIGN KEY (`client_id`) REFERENCES `Client` (`id`);

--
-- Contraintes pour la table `LigneCommande`
--
ALTER TABLE `LigneCommande`
    ADD CONSTRAINT `fk_command_ligne_id` FOREIGN KEY (`commande_id`) REFERENCES `Commande` (`id`),
  ADD CONSTRAINT `fk_produit_ligne_id` FOREIGN KEY (`produit_id`) REFERENCES `Produit` (`id`);

--
-- Contraintes pour la table `Paiement`
--
ALTER TABLE `Paiement`
    ADD CONSTRAINT `fk_adresse_facturation_paiement_id` FOREIGN KEY (`adresse_facturation_id`) REFERENCES `Adresse` (`id`),
  ADD CONSTRAINT `fk_client_paiement_id` FOREIGN KEY (`client_id`) REFERENCES `Client` (`id`),
  ADD CONSTRAINT `fk_commande_paiement_id` FOREIGN KEY (`commande_id`) REFERENCES `Commande` (`id`);

--
-- Contraintes pour la table `Portefeuille`
--
ALTER TABLE `Portefeuille`
    ADD CONSTRAINT `fk_client_portefeuille_id` FOREIGN KEY (`client_id`) REFERENCES `Client` (`id`);

--
-- Contraintes pour la table `Produit`
--
ALTER TABLE `Produit`
    ADD CONSTRAINT `fk_product_prestataire_id` FOREIGN KEY (`prestataire_id`) REFERENCES `Prestataire` (`id`);

--
-- Contraintes pour la table `Remboursement`
--
ALTER TABLE `Remboursement`
    ADD CONSTRAINT `fk_commande_remboursement_id` FOREIGN KEY (`ligne_commande_id`) REFERENCES `Commande` (`id`),
  ADD CONSTRAINT `fk_coupon_remboursement_id` FOREIGN KEY (`coupon_id`) REFERENCES `Coupon` (`id`),
  ADD CONSTRAINT `fk_ligne_commande_remboursement_id` FOREIGN KEY (`ligne_commande_id`) REFERENCES `LigneCommande` (`id`),
  ADD CONSTRAINT `fk_prestataire_remboursement_id` FOREIGN KEY (`prestataire_id`) REFERENCES `Prestataire` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
