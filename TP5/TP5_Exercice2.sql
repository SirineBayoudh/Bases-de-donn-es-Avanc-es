-- =========================================
-- TP5 - Exercice 2 : Transactions concurrentes
-- =========================================

-- Nettoyage
BEGIN EXECUTE IMMEDIATE 'DROP TABLE client PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE vol PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Création des tables
CREATE TABLE vol (
    idVol VARCHAR2(44),
    capaciteVol NUMBER(10),
    nbrPlacesReserveesVol NUMBER(10)
);

CREATE TABLE client (
    idClient VARCHAR2(44),
    prenomClient VARCHAR2(11),
    nbrPlacesReserveesCleint NUMBER(10)
);

-- Insertion initiale
INSERT INTO vol VALUES ('V1', 100, 0);
INSERT INTO client VALUES ('C1', 'Ali', 0);
INSERT INTO client VALUES ('C2', 'Sara', 0);
COMMIT;

-- =========================================
-- PARTIE A : Isolation (à faire en 2 sessions)
-- =========================================

-- --- S1 (Transaction T1)
-- UPDATE client SET nbrPlacesReserveesCleint = nbrPlacesReserveesCleint + 2 WHERE idClient = 'C1';
-- UPDATE vol SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2 WHERE idVol = 'V1';
-- SELECT * FROM client;
-- SELECT * FROM vol;

-- --- S2
-- SELECT * FROM client;
-- SELECT * FROM vol;

-- =========================================
-- PARTIE B : ROLLBACK
-- =========================================

-- --- S1
-- ROLLBACK;
-- SELECT * FROM client;
-- SELECT * FROM vol;

-- =========================================
-- PARTIE C : COMMIT
-- =========================================

-- --- S1
-- UPDATE client SET nbrPlacesReserveesCleint = nbrPlacesReserveesCleint + 2 WHERE idClient = 'C1';
-- UPDATE vol SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2 WHERE idVol = 'V1';
-- COMMIT;

-- --- S2
-- SELECT * FROM client;
-- SELECT * FROM vol;

-- =========================================
-- PARTIE D : Mise à jour perdue (READ COMMITTED)
-- =========================================

-- Reset
UPDATE vol SET nbrPlacesReserveesVol = 0 WHERE idVol = 'V1';
UPDATE client SET nbrPlacesReserveesCleint = 0 WHERE idClient IN ('C1','C2');
COMMIT;

-- --- S1 (lecture)
-- SELECT nbrPlacesReserveesVol FROM vol WHERE idVol = 'V1';
-- SELECT nbrPlacesReserveesCleint FROM client WHERE idClient = 'C1';

-- --- S2 (lecture)
-- SELECT nbrPlacesReserveesVol FROM vol WHERE idVol = 'V1';
-- SELECT nbrPlacesReserveesCleint FROM client WHERE idClient = 'C2';

-- --- S1 (update + commit)
-- UPDATE client SET nbrPlacesReserveesCleint = 2 WHERE idClient = 'C1';
-- UPDATE vol SET nbrPlacesReserveesVol = 2 WHERE idVol = 'V1';
-- COMMIT;

-- --- S2 (update + commit)
-- UPDATE client SET nbrPlacesReserveesCleint = 3 WHERE idClient = 'C2';
-- UPDATE vol SET nbrPlacesReserveesVol = 3 WHERE idVol = 'V1';
-- COMMIT;

-- Vérification
SELECT * FROM client;
SELECT * FROM vol;

-- =========================================
-- PARTIE E : SERIALIZABLE
-- =========================================

-- Reset
UPDATE vol SET nbrPlacesReserveesVol = 0 WHERE idVol = 'V1';
UPDATE client SET nbrPlacesReserveesCleint = 0 WHERE idClient IN ('C1','C2');
COMMIT;

-- --- Dans S1 et S2
-- ALTER SESSION SET ISOLATION_LEVEL = SERIALIZABLE;

-- Refaire le même scénario que PARTIE D
