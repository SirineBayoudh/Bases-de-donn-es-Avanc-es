SET SERVEROUTPUT ON;

----------------------------------------------------
-- NETTOYAGE (à lancer une seule fois si besoin)
----------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatFactoriel';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatsFactoriels';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE emp';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE client';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE gestion_client';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION puissance';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
----------------------------------------------------
-- EXERCICE 1
----------------------------------------------------

----------------------------------------------------
-- 1) Somme de deux entiers
----------------------------------------------------
DECLARE
    a NUMBER;
    b NUMBER;
    s NUMBER;
BEGIN
    a := &a;
    b := &b;
    s := a + b;

    DBMS_OUTPUT.PUT_LINE('La somme est : ' || s);
END;
/
----------------------------------------------------
-- 2) Table de multiplication
----------------------------------------------------
DECLARE
    n NUMBER;
    i NUMBER;
BEGIN
    n := &n;

    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(n || ' x ' || i || ' = ' || (n * i));
    END LOOP;
END;
/
----------------------------------------------------
-- 3) Fonction récursive puissance(x,n)
----------------------------------------------------
CREATE OR REPLACE FUNCTION puissance(x NUMBER, n NUMBER)
RETURN NUMBER
IS
BEGIN
    IF n = 0 THEN
        RETURN 1;
    ELSE
        RETURN x * puissance(x, n - 1);
    END IF;
END;
/
----------------------------------------------------
-- Test de la fonction puissance
----------------------------------------------------
BEGIN
    DBMS_OUTPUT.PUT_LINE('2 puissance 5 = ' || puissance(2, 5));
    DBMS_OUTPUT.PUT_LINE('3 puissance 4 = ' || puissance(3, 4));
END;
/
----------------------------------------------------
-- 4) Factorielle d’un nombre saisi
----------------------------------------------------
CREATE TABLE resultatFactoriel (
    nombre NUMBER,
    factorielle NUMBER
);
/
DECLARE
    n NUMBER;
    f NUMBER := 1;
    i NUMBER;
BEGIN
    n := &n;

    IF n <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : le nombre doit être strictement positif.');
    ELSE
        FOR i IN 1..n LOOP
            f := f * i;
        END LOOP;

        INSERT INTO resultatFactoriel VALUES (n, f);

        DBMS_OUTPUT.PUT_LINE('Factorielle de ' || n || ' = ' || f);
    END IF;
END;
/
----------------------------------------------------
-- 5) Stocker les factorielles des 20 premiers entiers
----------------------------------------------------
CREATE TABLE resultatsFactoriels (
    nombre NUMBER,
    factorielle NUMBER
);
/
DECLARE
    f NUMBER := 1;
    i NUMBER;
BEGIN
    FOR i IN 1..20 LOOP
        f := f * i;
        INSERT INTO resultatsFactoriels VALUES (i, f);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Les factorielles de 1 à 20 ont été stockées.');
END;
/
----------------------------------------------------
-- EXERCICE 2
----------------------------------------------------

----------------------------------------------------
-- Création de la table emp
----------------------------------------------------
CREATE TABLE emp (
    matr NUMBER(10) NOT NULL,
    nom VARCHAR2(50) NOT NULL,
    sal NUMBER(7,2),
    adresse VARCHAR2(96),
    dep NUMBER(10) NOT NULL,
    CONSTRAINT emp_pk PRIMARY KEY (matr)
);
/
----------------------------------------------------
-- Insertion de quelques données
----------------------------------------------------
INSERT INTO emp VALUES (1, 'Ali', 2000, 'Alger', 92000);
INSERT INTO emp VALUES (2, 'Sonia', 3000, 'Paris', 75000);
INSERT INTO emp VALUES (3, 'Karim', 2800, 'Lyon', 92000);
COMMIT;
/
----------------------------------------------------
-- 1) Insertion d’un nouvel employé avec %ROWTYPE
----------------------------------------------------
DECLARE
    v_employe emp%ROWTYPE;
BEGIN
    v_employe.matr := 4;
    v_employe.nom := 'Youcef';
    v_employe.sal := 2500;
    v_employe.adresse := 'avenue de la Republique';
    v_employe.dep := 92002;

    INSERT INTO emp VALUES v_employe;

    DBMS_OUTPUT.PUT_LINE('Employe insere avec succes.');
END;
/
----------------------------------------------------
-- 2) Suppression des employés d’un département
-- ici j’ai mis 92002 pour supprimer Youcef
----------------------------------------------------
DECLARE
    v_nb_lignes NUMBER;
BEGIN
    DELETE FROM emp
    WHERE dep = 92002;

    v_nb_lignes := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Nombre de lignes supprimees : ' || v_nb_lignes);
END;
/
----------------------------------------------------
-- 3) Somme des salaires avec curseur explicite + LOOP
----------------------------------------------------
DECLARE
    v_salaire emp.sal%TYPE;
    v_total emp.sal%TYPE := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;

    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;

        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
        END IF;
    END LOOP;

    CLOSE c_salaires;

    DBMS_OUTPUT.PUT_LINE('Somme des salaires : ' || v_total);
END;
/
----------------------------------------------------
-- 4) Salaire moyen avec curseur explicite + LOOP
----------------------------------------------------
DECLARE
    v_salaire emp.sal%TYPE;
    v_total NUMBER := 0;
    v_nb NUMBER := 0;
    v_moy NUMBER := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;

    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;

        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
            v_nb := v_nb + 1;
        END IF;
    END LOOP;

    CLOSE c_salaires;

    IF v_nb > 0 THEN
        v_moy := v_total / v_nb;
        DBMS_OUTPUT.PUT_LINE('Salaire moyen : ' || v_moy);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Aucun salaire trouve.');
    END IF;
END;
/
----------------------------------------------------
-- 5) Somme des salaires avec FOR IN
----------------------------------------------------
DECLARE
    v_total NUMBER := 0;
BEGIN
    FOR r IN (SELECT sal FROM emp) LOOP
        IF r.sal IS NOT NULL THEN
            v_total := v_total + r.sal;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Somme des salaires (FOR IN) : ' || v_total);
END;
/
----------------------------------------------------
-- 5) Salaire moyen avec FOR IN
----------------------------------------------------
DECLARE
    v_total NUMBER := 0;
    v_nb NUMBER := 0;
    v_moy NUMBER := 0;
BEGIN
    FOR r IN (SELECT sal FROM emp) LOOP
        IF r.sal IS NOT NULL THEN
            v_total := v_total + r.sal;
            v_nb := v_nb + 1;
        END IF;
    END LOOP;

    IF v_nb > 0 THEN
        v_moy := v_total / v_nb;
        DBMS_OUTPUT.PUT_LINE('Salaire moyen (FOR IN) : ' || v_moy);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Aucun salaire trouve.');
    END IF;
END;
/
----------------------------------------------------
-- 6) Curseur paramétré : employés des départements 92000 et 75000
----------------------------------------------------
DECLARE
    CURSOR c(p_dep emp.dep%TYPE) IS
        SELECT dep, nom
        FROM emp
        WHERE dep = p_dep;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Employes du departement 92000 :');
    FOR v_employe IN c(92000) LOOP
        DBMS_OUTPUT.PUT_LINE(v_employe.nom);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Employes du departement 75000 :');
    FOR v_employe IN c(75000) LOOP
        DBMS_OUTPUT.PUT_LINE(v_employe.nom);
    END LOOP;
END;
/
----------------------------------------------------
-- EXERCICE 3
-- Package de gestion des clients avec surcharge
----------------------------------------------------

----------------------------------------------------
-- Table client
----------------------------------------------------
CREATE TABLE client (
    id_client NUMBER PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    adresse VARCHAR2(100),
    telephone VARCHAR2(20)
);
/
----------------------------------------------------
-- Specification du package
----------------------------------------------------
CREATE OR REPLACE PACKAGE gestion_client AS
    PROCEDURE ajouter_client(
        p_id_client NUMBER,
        p_nom VARCHAR2
    );

    PROCEDURE ajouter_client(
        p_id_client NUMBER,
        p_nom VARCHAR2,
        p_adresse VARCHAR2,
        p_telephone VARCHAR2
    );
END gestion_client;
/
----------------------------------------------------
-- Corps du package
----------------------------------------------------
CREATE OR REPLACE PACKAGE BODY gestion_client AS

    PROCEDURE ajouter_client(
        p_id_client NUMBER,
        p_nom VARCHAR2
    )
    IS
    BEGIN
        INSERT INTO client(id_client, nom)
        VALUES (p_id_client, p_nom);

        DBMS_OUTPUT.PUT_LINE('Client ajoute (version simple).');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : id client deja existant.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
    END ajouter_client;

    PROCEDURE ajouter_client(
        p_id_client NUMBER,
        p_nom VARCHAR2,
        p_adresse VARCHAR2,
        p_telephone VARCHAR2
    )
    IS
    BEGIN
        INSERT INTO client(id_client, nom, adresse, telephone)
        VALUES (p_id_client, p_nom, p_adresse, p_telephone);

        DBMS_OUTPUT.PUT_LINE('Client ajoute (version complete).');

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : id client deja existant.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
    END ajouter_client;

END gestion_client;
/
----------------------------------------------------
-- Test du package
----------------------------------------------------
BEGIN
    gestion_client.ajouter_client(1, 'Ahmed');
    gestion_client.ajouter_client(2, 'Salma', 'Oran', '0550123456');
END;
/
----------------------------------------------------
-- VALIDATION FINALE : affichage des tables
----------------------------------------------------
SELECT * FROM resultatFactoriel;
SELECT * FROM resultatsFactoriels;
SELECT * FROM emp;
SELECT * FROM client;
/