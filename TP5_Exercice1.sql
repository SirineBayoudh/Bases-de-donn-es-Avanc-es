-- =========================================
-- TP5 - Transactions
-- Exercice 1
-- Script Oracle / SQL*Plus / APEX
-- =========================================

-- -----------------------------------------
-- 0) Création de la table
-- -----------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE transaction_tp PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE transaction_tp (
    idTransaction VARCHAR2(44),
    valTransaction NUMBER(10)
);

-- =========================================
-- PARTIE A - A exécuter dans la session S2
-- =========================================
-- SET AUTOCOMMIT OFF;

INSERT INTO transaction_tp VALUES ('T1', 100);
INSERT INTO transaction_tp VALUES ('T2', 200);
INSERT INTO transaction_tp VALUES ('T3', 300);

UPDATE transaction_tp
SET valTransaction = 250
WHERE idTransaction = 'T2';

DELETE FROM transaction_tp
WHERE idTransaction = 'T3';

SELECT * FROM transaction_tp;

ROLLBACK;

SELECT * FROM transaction_tp;

-- =========================================
-- PARTIE B - A exécuter dans la session S2
-- Puis quitter sans COMMIT
-- =========================================

INSERT INTO transaction_tp VALUES ('T10', 1000);
INSERT INTO transaction_tp VALUES ('T11', 1100);

SELECT * FROM transaction_tp;

-- quitter la session ici sans COMMIT
-- quit;

-- =========================================
-- PARTIE C - A vérifier dans la session S1
-- =========================================

SELECT * FROM transaction_tp;

-- =========================================
-- PARTIE D - A exécuter dans S1
-- Puis fermer brutalement la session
-- =========================================

INSERT INTO transaction_tp VALUES ('T20', 2000);
INSERT INTO transaction_tp VALUES ('T21', 2100);

SELECT * FROM transaction_tp;

-- Fermer brutalement ici sans COMMIT
-- Reconnecter ensuite et vérifier :
SELECT * FROM transaction_tp;

-- =========================================
-- PARTIE E - DDL + ROLLBACK
-- =========================================

INSERT INTO transaction_tp VALUES ('T30', 3000);

ALTER TABLE transaction_tp
ADD val2Transaction NUMBER(10);

ROLLBACK;

SELECT * FROM transaction_tp;

-- Pour afficher la structure :
SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'TRANSACTION_TP'
ORDER BY column_id;
