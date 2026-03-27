-- ============================================================
-- NOM : BAYOUDH Sirine
-- TP2 - Bases de Données
-- Exercice 1 : Requêtes SQL
-- ============================================================

/* 1) Département disposant du budget maximal */
SELECT d.dept_name
FROM department d
WHERE d.budget = (
    SELECT MAX(d2.budget)
    FROM department d2
);

/* 2) Enseignants dont le salaire dépasse la moyenne générale */
SELECT i.name,
       i.salary
FROM instructor i
WHERE i.salary > (
    SELECT AVG(i2.salary)
    FROM instructor i2
)
ORDER BY i.salary DESC, i.name;

/* 3) Étudiants ayant suivi plus de deux cours avec un même enseignant (avec HAVING) */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       s.id   AS stud_id,
       s.name AS stud_name,
       COUNT(*) AS nb_cours
FROM instructor i
INNER JOIN teaches te
        ON te.id = i.id
INNER JOIN takes tk
        ON tk.course_id = te.course_id
       AND tk.sec_id    = te.sec_id
       AND tk.semester  = te.semester
       AND tk.year      = te.year
INNER JOIN student s
        ON s.id = tk.id
GROUP BY i.id, i.name, s.id, s.name
HAVING COUNT(*) > 2
ORDER BY instr_name, stud_name;

/* 4) Même résultat sans HAVING */
SELECT q.instr_id,
       q.instr_name,
       q.stud_id,
       q.stud_name,
       q.nb_cours
FROM (
    SELECT i.id   AS instr_id,
           i.name AS instr_name,
           s.id   AS stud_id,
           s.name AS stud_name,
           COUNT(*) AS nb_cours
    FROM instructor i
    JOIN teaches te
      ON te.id = i.id
    JOIN takes tk
      ON tk.course_id = te.course_id
     AND tk.sec_id    = te.sec_id
     AND tk.semester  = te.semester
     AND tk.year      = te.year
    JOIN student s
      ON s.id = tk.id
    GROUP BY i.id, i.name, s.id, s.name
) q
WHERE q.nb_cours > 2
ORDER BY q.instr_name, q.stud_name;

/* 5) Étudiants n’ayant suivi aucun cours avant 2010 */
SELECT s.id,
       s.name
FROM student s
WHERE NOT EXISTS (
    SELECT 1
    FROM takes t
    WHERE t.id = s.id
      AND t.year < 2010
)
ORDER BY s.id;

/* 6) Enseignants dont le nom commence par E */
SELECT i.id,
       i.name,
       i.dept_name,
       i.salary
FROM instructor i
WHERE i.name LIKE 'E%'
ORDER BY i.name;

/* 7) Enseignants ayant le 4e salaire le plus élevé */
SELECT x.name,
       x.salary
FROM (
    SELECT i.name,
           i.salary,
           DENSE_RANK() OVER (ORDER BY i.salary DESC) AS rang_salaire
    FROM instructor i
) x
WHERE x.rang_salaire = 4
ORDER BY x.name;

/* 8) Trois enseignants les moins payés, affichés ensuite par ordre décroissant */
SELECT y.name,
       y.salary
FROM (
    SELECT i.name,
           i.salary,
           ROW_NUMBER() OVER (ORDER BY i.salary ASC, i.name ASC) AS rn
    FROM instructor i
) y
WHERE y.rn <= 3
ORDER BY y.salary DESC, y.name DESC;

/* 9) Étudiants ayant suivi un cours en Fall 2009 (IN) */
SELECT s.name
FROM student s
WHERE s.id IN (
    SELECT t.id
    FROM takes t
    WHERE t.semester = 'Fall'
      AND t.year = 2009
)
ORDER BY s.name;

/* 10) Même question avec SOME */
SELECT s.name
FROM student s
WHERE s.id = SOME (
    SELECT t.id
    FROM takes t
    WHERE t.semester = 'Fall'
      AND t.year = 2009
)
ORDER BY s.name;

/* 11) Même question avec NATURAL INNER JOIN */
SELECT DISTINCT s.name
FROM student s
NATURAL INNER JOIN (
    SELECT t.id
    FROM takes t
    WHERE t.semester = 'Fall'
      AND t.year = 2009
)
ORDER BY s.name;

/* 12) Même question avec EXISTS */
SELECT s.name
FROM student s
WHERE EXISTS (
    SELECT 1
    FROM takes t
    WHERE t.id = s.id
      AND t.semester = 'Fall'
      AND t.year = 2009
)
ORDER BY s.name;

/* 13) Paires d’étudiants ayant déjà partagé au moins un cours */
SELECT DISTINCT
       a.id   AS student1_id,
       a.name AS student1_name,
       b.id   AS student2_id,
       b.name AS student2_name
FROM takes t1
JOIN takes t2
  ON t1.course_id = t2.course_id
 AND t1.sec_id    = t2.sec_id
 AND t1.semester  = t2.semester
 AND t1.year      = t2.year
 AND t1.id < t2.id
JOIN student a
  ON a.id = t1.id
JOIN student b
  ON b.id = t2.id
ORDER BY student1_id, student2_id;

/* 14) Nombre total d’inscriptions pour chaque enseignant ayant enseigné */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       COUNT(*) AS total_inscriptions
FROM instructor i
JOIN teaches te
  ON te.id = i.id
JOIN takes tk
  ON tk.course_id = te.course_id
 AND tk.sec_id    = te.sec_id
 AND tk.semester  = te.semester
 AND tk.year      = te.year
GROUP BY i.id, i.name
ORDER BY total_inscriptions DESC, instr_name;

/* 15) Même question en incluant aussi les enseignants sans cours */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       COUNT(tk.id) AS total_inscriptions
FROM instructor i
LEFT JOIN teaches te
       ON te.id = i.id
LEFT JOIN takes tk
       ON tk.course_id = te.course_id
      AND tk.sec_id    = te.sec_id
      AND tk.semester  = te.semester
      AND tk.year      = te.year
GROUP BY i.id, i.name
ORDER BY total_inscriptions DESC, instr_name;

/* 16) Nombre total de notes A attribuées par enseignant */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       COUNT(*) AS nb_A
FROM instructor i
JOIN teaches te
  ON te.id = i.id
JOIN takes tk
  ON tk.course_id = te.course_id
 AND tk.sec_id    = te.sec_id
 AND tk.semester  = te.semester
 AND tk.year      = te.year
WHERE tk.grade = 'A'
GROUP BY i.id, i.name
ORDER BY nb_A DESC, instr_name;

/* 17) Couples enseignant-étudiant et nombre de cours suivis ensemble */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       s.id   AS stud_id,
       s.name AS stud_name,
       COUNT(*) AS nb_occurrences
FROM instructor i
JOIN teaches te
  ON te.id = i.id
JOIN takes tk
  ON tk.course_id = te.course_id
 AND tk.sec_id    = te.sec_id
 AND tk.semester  = te.semester
 AND tk.year      = te.year
JOIN student s
  ON s.id = tk.id
GROUP BY i.id, i.name, s.id, s.name
ORDER BY instr_name, stud_name;

/* 18) Couples enseignant-étudiant avec au moins deux cours suivis */
SELECT i.id   AS instr_id,
       i.name AS instr_name,
       s.id   AS stud_id,
       s.name AS stud_name,
       COUNT(*) AS nb_occurrences
FROM instructor i
JOIN teaches te
  ON te.id = i.id
JOIN takes tk
  ON tk.course_id = te.course_id
 AND tk.sec_id    = te.sec_id
 AND tk.semester  = te.semester
 AND tk.year      = te.year
JOIN student s
  ON s.id = tk.id
GROUP BY i.id, i.name, s.id, s.name
HAVING COUNT(*) >= 2
ORDER BY instr_name, nb_occurrences DESC, stud_name;
