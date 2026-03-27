-- =====================================================
-- 1) SUPPRESSION DES TABLES (si elles existent déja)
-- =====================================================
BEGIN EXECUTE IMMEDIATE 'DROP TABLE takes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE teaches CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE advisor CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE prereq CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE section CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE student CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE instructor CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE course CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE department CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE classroom CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE time_slot CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =====================================================
-- 2) CREATION DES TABLES
-- =====================================================
CREATE TABLE department (
    dept_name   VARCHAR2(20) PRIMARY KEY,
    building    VARCHAR2(15),
    budget      NUMBER(12,2) CHECK (budget > 0)
);

CREATE TABLE course (
    course_id   VARCHAR2(12) PRIMARY KEY,
    title       VARCHAR2(50) NOT NULL,
    dept_name   VARCHAR2(20),
    credits     NUMBER(2) CHECK (credits > 0),
    CONSTRAINT fk_course_dept
        FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE instructor (
    id          VARCHAR2(5) PRIMARY KEY,
    name        VARCHAR2(20) NOT NULL,
    dept_name   VARCHAR2(20),
    salary      NUMBER(8,2) CHECK (salary > 0),
    CONSTRAINT fk_instructor_dept
        FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE student (
    id          VARCHAR2(5) PRIMARY KEY,
    name        VARCHAR2(20) NOT NULL,
    dept_name   VARCHAR2(20),
    tot_cred    NUMBER(3) DEFAULT 0 CHECK (tot_cred >= 0),
    CONSTRAINT fk_student_dept
        FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE classroom (
    building    VARCHAR2(15),
    room_number VARCHAR2(7),
    capacity    NUMBER(4) CHECK (capacity > 0),
    CONSTRAINT pk_classroom PRIMARY KEY (building, room_number)
);

CREATE TABLE time_slot (
    time_slot_id VARCHAR2(4),
    day          VARCHAR2(1),
    start_time   VARCHAR2(8),
    end_time     VARCHAR2(8),
    CONSTRAINT pk_time_slot PRIMARY KEY (time_slot_id, day, start_time)
);

CREATE TABLE section (
    course_id     VARCHAR2(12),
    sec_id        VARCHAR2(8),
    semester      VARCHAR2(10),
    year          NUMBER(4),
    building      VARCHAR2(15),
    room_number   VARCHAR2(7),
    time_slot_id  VARCHAR2(4),
    CONSTRAINT pk_section PRIMARY KEY (course_id, sec_id, semester, year),
    CONSTRAINT ck_section_semester
        CHECK (semester IN ('Fall', 'Winter', 'Spring', 'Summer')),
    CONSTRAINT fk_section_course
        FOREIGN KEY (course_id) REFERENCES course(course_id),
    CONSTRAINT fk_section_classroom
        FOREIGN KEY (building, room_number) REFERENCES classroom(building, room_number)
);

CREATE TABLE teaches (
    id          VARCHAR2(5),
    course_id   VARCHAR2(12),
    sec_id      VARCHAR2(8),
    semester    VARCHAR2(10),
    year        NUMBER(4),
    CONSTRAINT pk_teaches PRIMARY KEY (id, course_id, sec_id, semester, year),
    CONSTRAINT fk_teaches_instructor
        FOREIGN KEY (id) REFERENCES instructor(id),
    CONSTRAINT fk_teaches_section
        FOREIGN KEY (course_id, sec_id, semester, year)
        REFERENCES section(course_id, sec_id, semester, year)
);

CREATE TABLE takes (
    id          VARCHAR2(5),
    course_id   VARCHAR2(12),
    sec_id      VARCHAR2(8),
    semester    VARCHAR2(10),
    year        NUMBER(4),
    grade       VARCHAR2(2),
    CONSTRAINT pk_takes PRIMARY KEY (id, course_id, sec_id, semester, year),
    CONSTRAINT fk_takes_student
        FOREIGN KEY (id) REFERENCES student(id),
    CONSTRAINT fk_takes_section
        FOREIGN KEY (course_id, sec_id, semester, year)
        REFERENCES section(course_id, sec_id, semester, year)
);

CREATE TABLE advisor (
    s_id        VARCHAR2(5) PRIMARY KEY,
    i_id        VARCHAR2(5),
    CONSTRAINT fk_advisor_student
        FOREIGN KEY (s_id) REFERENCES student(id),
    CONSTRAINT fk_advisor_instructor
        FOREIGN KEY (i_id) REFERENCES instructor(id)
);

CREATE TABLE prereq (
    course_id   VARCHAR2(12),
    prereq_id   VARCHAR2(12),
    CONSTRAINT pk_prereq PRIMARY KEY (course_id, prereq_id),
    CONSTRAINT fk_prereq_course
        FOREIGN KEY (course_id) REFERENCES course(course_id),
    CONSTRAINT fk_prereq_prereq
        FOREIGN KEY (prereq_id) REFERENCES course(course_id)
);

-- =====================================================
-- 3) INSERTION DES DONNEES
-- =====================================================
INSERT INTO department VALUES ('Biology',   'Watson',  90000);
INSERT INTO department VALUES ('Comp. Sci.','Taylor', 100000);
INSERT INTO department VALUES ('Elec. Eng.','Taylor',  85000);
INSERT INTO department VALUES ('Finance',   'Painter',120000);
INSERT INTO department VALUES ('History',   'Painter', 50000);
INSERT INTO department VALUES ('Music',     'Packard', 80000);
INSERT INTO department VALUES ('Physics',   'Watson',  70000);

INSERT INTO course VALUES ('BIO-101', 'Intro. to Biology', 'Biology', 4);
INSERT INTO course VALUES ('BIO-301', 'Genetics', 'Biology', 4);
INSERT INTO course VALUES ('BIO-399', 'Computational Biology', 'Biology', 3);
INSERT INTO course VALUES ('CS-101', 'Intro. to Computer Science', 'Comp. Sci.', 4);
INSERT INTO course VALUES ('CS-190', 'Game Design', 'Comp. Sci.', 4);
INSERT INTO course VALUES ('CS-315', 'Robotics', 'Comp. Sci.', 3);
INSERT INTO course VALUES ('CS-319', 'Image Processing', 'Comp. Sci.', 3);
INSERT INTO course VALUES ('CS-347', 'Database System Concepts', 'Comp. Sci.', 3);
INSERT INTO course VALUES ('EE-181', 'Intro. to Digital Systems', 'Elec. Eng.', 3);
INSERT INTO course VALUES ('FIN-201', 'Investment Banking', 'Finance', 3);
INSERT INTO course VALUES ('HIS-351', 'World History', 'History', 3);
INSERT INTO course VALUES ('MU-199', 'Music Video Production', 'Music', 3);
INSERT INTO course VALUES ('PHY-101', 'Physical Principles', 'Physics', 4);

INSERT INTO instructor VALUES ('10101', 'Srinivasan', 'Comp. Sci.', 65000);
INSERT INTO instructor VALUES ('12121', 'Wu',         'Finance',    90000);
INSERT INTO instructor VALUES ('15151', 'Mozart',     'Music',      40000);
INSERT INTO instructor VALUES ('22222', 'Einstein',   'Physics',    95000);
INSERT INTO instructor VALUES ('32343', 'El Said',    'History',    60000);
INSERT INTO instructor VALUES ('33456', 'Gold',       'Physics',    87000);
INSERT INTO instructor VALUES ('45565', 'Katz',       'Comp. Sci.', 75000);
INSERT INTO instructor VALUES ('58583', 'Califieri',  'History',    62000);
INSERT INTO instructor VALUES ('76543', 'Singh',      'Finance',    80000);
INSERT INTO instructor VALUES ('76766', 'Crick',      'Biology',    72000);
INSERT INTO instructor VALUES ('83821', 'Brandt',     'Comp. Sci.', 92000);
INSERT INTO instructor VALUES ('98345', 'Kim',        'Elec. Eng.', 80000);

INSERT INTO student VALUES ('00128', 'Zhang',    'Comp. Sci.', 102);
INSERT INTO student VALUES ('12345', 'Shankar',  'Comp. Sci.', 32);
INSERT INTO student VALUES ('19991', 'Brandt',   'History',    80);
INSERT INTO student VALUES ('23121', 'Chavez',   'Finance',    110);
INSERT INTO student VALUES ('44553', 'Peltier',  'Physics',    56);
INSERT INTO student VALUES ('45678', 'Levy',     'Physics',    46);
INSERT INTO student VALUES ('54321', 'Williams', 'Comp. Sci.', 54);
INSERT INTO student VALUES ('55739', 'Sanchez',  'Music',      38);
INSERT INTO student VALUES ('70557', 'Snow',     'Physics',     0);
INSERT INTO student VALUES ('76543', 'Brown',    'Comp. Sci.', 58);
INSERT INTO student VALUES ('76653', 'Aoi',      'Elec. Eng.', 60);
INSERT INTO student VALUES ('98765', 'Bourikas', 'Elec. Eng.', 98);
INSERT INTO student VALUES ('98988', 'Tanaka',   'Biology',   120);

INSERT INTO classroom VALUES ('Packard', '101', 500);
INSERT INTO classroom VALUES ('Painter', '514', 10);
INSERT INTO classroom VALUES ('Taylor',  '3128', 70);
INSERT INTO classroom VALUES ('Watson',  '100', 30);
INSERT INTO classroom VALUES ('Watson',  '120', 50);

INSERT INTO time_slot VALUES ('A', 'M', '08:00:00', '08:50:00');
INSERT INTO time_slot VALUES ('A', 'W', '08:00:00', '08:50:00');
INSERT INTO time_slot VALUES ('A', 'F', '08:00:00', '08:50:00');
INSERT INTO time_slot VALUES ('B', 'M', '09:00:00', '09:50:00');
INSERT INTO time_slot VALUES ('B', 'W', '09:00:00', '09:50:00');
INSERT INTO time_slot VALUES ('B', 'F', '09:00:00', '09:50:00');
INSERT INTO time_slot VALUES ('C', 'T', '11:00:00', '12:15:00');
INSERT INTO time_slot VALUES ('C', 'R', '11:00:00', '12:15:00');
INSERT INTO time_slot VALUES ('D', 'M', '13:00:00', '13:50:00');
INSERT INTO time_slot VALUES ('D', 'W', '13:00:00', '13:50:00');
INSERT INTO time_slot VALUES ('D', 'F', '13:00:00', '13:50:00');
INSERT INTO time_slot VALUES ('E', 'T', '10:30:00', '11:45:00');
INSERT INTO time_slot VALUES ('E', 'R', '10:30:00', '11:45:00');
INSERT INTO time_slot VALUES ('F', 'T', '14:30:00', '15:45:00');
INSERT INTO time_slot VALUES ('F', 'R', '14:30:00', '15:45:00');
INSERT INTO time_slot VALUES ('G', 'M', '16:00:00', '16:50:00');
INSERT INTO time_slot VALUES ('G', 'W', '16:00:00', '16:50:00');
INSERT INTO time_slot VALUES ('G', 'F', '16:00:00', '16:50:00');

INSERT INTO section VALUES ('BIO-101', '1', 'Summer', 2009, 'Painter', '514', 'B');
INSERT INTO section VALUES ('BIO-301', '1', 'Summer', 2010, 'Painter', '514', 'A');
INSERT INTO section VALUES ('CS-101',  '1', 'Fall',   2009, 'Packard', '101', 'A');
INSERT INTO section VALUES ('CS-101',  '1', 'Spring', 2010, 'Packard', '101', 'F');
INSERT INTO section VALUES ('CS-190',  '1', 'Spring', 2009, 'Taylor',  '3128', 'E');
INSERT INTO section VALUES ('CS-190',  '2', 'Spring', 2009, 'Taylor',  '3128', 'A');
INSERT INTO section VALUES ('CS-315',  '1', 'Spring', 2010, 'Watson',  '120', 'D');
INSERT INTO section VALUES ('CS-319',  '1', 'Spring', 2010, 'Watson',  '100', 'B');
INSERT INTO section VALUES ('CS-319',  '2', 'Spring', 2010, 'Taylor',  '3128', 'C');
INSERT INTO section VALUES ('CS-347',  '1', 'Fall',   2009, 'Taylor',  '3128', 'A');
INSERT INTO section VALUES ('EE-181',  '1', 'Spring', 2009, 'Taylor',  '3128', 'C');
INSERT INTO section VALUES ('FIN-201', '1', 'Spring', 2010, 'Packard', '101', 'B');
INSERT INTO section VALUES ('HIS-351', '1', 'Spring', 2010, 'Painter', '514', 'C');
INSERT INTO section VALUES ('MU-199',  '1', 'Spring', 2010, 'Packard', '101', 'D');
INSERT INTO section VALUES ('PHY-101', '1', 'Fall',   2009, 'Watson',  '100', 'A');

INSERT INTO teaches VALUES ('76766', 'BIO-101', '1', 'Summer', 2009);
INSERT INTO teaches VALUES ('76766', 'BIO-301', '1', 'Summer', 2010);
INSERT INTO teaches VALUES ('10101', 'CS-101',  '1', 'Fall',   2009);
INSERT INTO teaches VALUES ('45565', 'CS-101',  '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('83821', 'CS-190',  '1', 'Spring', 2009);
INSERT INTO teaches VALUES ('83821', 'CS-190',  '2', 'Spring', 2009);
INSERT INTO teaches VALUES ('10101', 'CS-315',  '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('45565', 'CS-319',  '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('83821', 'CS-319',  '2', 'Spring', 2010);
INSERT INTO teaches VALUES ('10101', 'CS-347',  '1', 'Fall',   2009);
INSERT INTO teaches VALUES ('98345', 'EE-181',  '1', 'Spring', 2009);
INSERT INTO teaches VALUES ('12121', 'FIN-201', '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('32343', 'HIS-351', '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('15151', 'MU-199',  '1', 'Spring', 2010);
INSERT INTO teaches VALUES ('22222', 'PHY-101', '1', 'Fall',   2009);

INSERT INTO takes VALUES ('00128', 'CS-101',  '1', 'Fall',   2009, 'A');
INSERT INTO takes VALUES ('00128', 'CS-347',  '1', 'Fall',   2009, 'A-');
INSERT INTO takes VALUES ('12345', 'CS-101',  '1', 'Fall',   2009, 'C');
INSERT INTO takes VALUES ('12345', 'CS-190',  '2', 'Spring', 2009, 'A');
INSERT INTO takes VALUES ('12345', 'CS-315',  '1', 'Spring', 2010, 'A');
INSERT INTO takes VALUES ('12345', 'CS-347',  '1', 'Fall',   2009, 'A');
INSERT INTO takes VALUES ('19991', 'HIS-351', '1', 'Spring', 2010, 'B');
INSERT INTO takes VALUES ('23121', 'FIN-201', '1', 'Spring', 2010, 'C+');
INSERT INTO takes VALUES ('44553', 'PHY-101', '1', 'Fall',   2009, 'B-');
INSERT INTO takes VALUES ('45678', 'CS-101',  '1', 'Fall',   2009, 'F');
INSERT INTO takes VALUES ('45678', 'CS-101',  '1', 'Spring', 2010, 'B+');
INSERT INTO takes VALUES ('45678', 'CS-319',  '1', 'Spring', 2010, 'B');
INSERT INTO takes VALUES ('54321', 'CS-101',  '1', 'Fall',   2009, 'A-');
INSERT INTO takes VALUES ('54321', 'CS-190',  '2', 'Spring', 2009, 'B+');
INSERT INTO takes VALUES ('55739', 'MU-199',  '1', 'Spring', 2010, 'A-');
INSERT INTO takes VALUES ('76543', 'CS-101',  '1', 'Fall',   2009, 'A');
INSERT INTO takes VALUES ('76543', 'CS-319',  '2', 'Spring', 2010, 'A');
INSERT INTO takes VALUES ('76653', 'EE-181',  '1', 'Spring', 2009, 'C');
INSERT INTO takes VALUES ('98765', 'CS-101',  '1', 'Fall',   2009, 'C-');
INSERT INTO takes VALUES ('98765', 'CS-315',  '1', 'Spring', 2010, 'B');
INSERT INTO takes VALUES ('98988', 'BIO-101', '1', 'Summer', 2009, 'A');
INSERT INTO takes VALUES ('98988', 'BIO-301', '1', 'Summer', 2010, NULL);

INSERT INTO advisor VALUES ('00128', '45565');
INSERT INTO advisor VALUES ('12345', '10101');
INSERT INTO advisor VALUES ('23121', '76543');
INSERT INTO advisor VALUES ('44553', '22222');
INSERT INTO advisor VALUES ('45678', '22222');
INSERT INTO advisor VALUES ('76543', '45565');
INSERT INTO advisor VALUES ('76653', '98345');
INSERT INTO advisor VALUES ('98765', '98345');
INSERT INTO advisor VALUES ('98988', '76766');

INSERT INTO prereq VALUES ('BIO-301', 'BIO-101');
INSERT INTO prereq VALUES ('BIO-399', 'BIO-101');
INSERT INTO prereq VALUES ('CS-190',  'CS-101');
INSERT INTO prereq VALUES ('CS-315',  'CS-101');
INSERT INTO prereq VALUES ('CS-319',  'CS-101');
INSERT INTO prereq VALUES ('CS-347',  'CS-101');
INSERT INTO prereq VALUES ('EE-181',  'PHY-101');

COMMIT;

-- =====================================================
-- 4) REQUETES DU TP
-- =====================================================

-- 1 Afficher la structure de section et son contenu
SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'SECTION'
ORDER BY column_id;

SELECT * FROM section;

-- 2
SELECT * FROM course;

-- 3
SELECT title, dept_name
FROM course;

-- 4
SELECT dept_name, budget
FROM department;

-- 5
SELECT name, dept_name
FROM instructor;

-- 6
SELECT name
FROM instructor
WHERE salary > 65000;

-- 7
SELECT name
FROM instructor
WHERE salary BETWEEN 55000 AND 85000;

-- 8
SELECT DISTINCT dept_name
FROM instructor;

-- 9
SELECT name
FROM instructor
WHERE dept_name = 'Comp. Sci.'
  AND salary > 65000;

-- 10
SELECT *
FROM section
WHERE semester = 'Spring'
  AND year = 2010;

-- 11
SELECT title
FROM course
WHERE dept_name = 'Comp. Sci.'
  AND credits > 3;

-- 12
SELECT i.name, d.dept_name, d.building
FROM instructor i
JOIN department d ON i.dept_name = d.dept_name;

-- 13
SELECT DISTINCT s.name
FROM student s
JOIN takes t ON s.id = t.id
JOIN course c ON t.course_id = c.course_id
WHERE c.dept_name = 'Comp. Sci.';

-- 14
SELECT DISTINCT s.name
FROM student s
JOIN takes t
  ON s.id = t.id
JOIN teaches te
  ON t.course_id = te.course_id
 AND t.sec_id = te.sec_id
 AND t.semester = te.semester
 AND t.year = te.year
JOIN instructor i
  ON te.id = i.id
WHERE i.name = 'Einstein';

-- 15
SELECT te.course_id, i.name
FROM teaches te
JOIN instructor i ON te.id = i.id
ORDER BY te.course_id;

-- 16
SELECT t.course_id, t.sec_id, t.semester, t.year, COUNT(*) AS nb_inscrits
FROM takes t
WHERE t.semester = 'Spring'
  AND t.year = 2010
GROUP BY t.course_id, t.sec_id, t.semester, t.year
ORDER BY t.course_id, t.sec_id;

-- 17
SELECT dept_name, MAX(salary) AS salaire_max
FROM instructor
GROUP BY dept_name
ORDER BY dept_name;

-- 18
SELECT course_id, sec_id, semester, year, COUNT(*) AS nb_inscrits
FROM takes
GROUP BY course_id, sec_id, semester, year
ORDER BY course_id, year, semester;

-- 19
SELECT building, COUNT(*) AS nb_total_cours
FROM section
WHERE (semester = 'Fall' AND year = 2009)
   OR (semester = 'Spring' AND year = 2010)
GROUP BY building
ORDER BY building;

-- 20
SELECT d.dept_name, COUNT(*) AS nb_cours
FROM department d
JOIN course c ON d.dept_name = c.dept_name
JOIN section s ON c.course_id = s.course_id
WHERE s.building = d.building
GROUP BY d.dept_name
ORDER BY d.dept_name;

-- 21
SELECT c.title, i.name
FROM course c
JOIN section s
  ON c.course_id = s.course_id
JOIN teaches t
  ON s.course_id = t.course_id
 AND s.sec_id = t.sec_id
 AND s.semester = t.semester
 AND s.year = t.year
JOIN instructor i
  ON t.id = i.id
ORDER BY c.title;

-- 22
SELECT semester, COUNT(*) AS nb_total_cours
FROM section
WHERE semester IN ('Summer', 'Fall', 'Spring')
GROUP BY semester
ORDER BY semester;

-- 23
SELECT s.id, s.name, NVL(SUM(c.credits),0) AS credits_hors_dept
FROM student s
LEFT JOIN takes t
  ON s.id = t.id
LEFT JOIN course c
  ON t.course_id = c.course_id
 AND c.dept_name <> s.dept_name
GROUP BY s.id, s.name
ORDER BY s.id;

-- 24
SELECT d.dept_name, NVL(SUM(c.credits),0) AS total_credits
FROM department d
LEFT JOIN course c
  ON d.dept_name = c.dept_name
LEFT JOIN section s
  ON c.course_id = s.course_id
 AND s.building = d.building
GROUP BY d.dept_name
ORDER BY d.dept_name;
