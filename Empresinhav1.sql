CREATE DATABASE empresa;
USE empresa;

-- =========================
-- TABELAS
-- =========================

CREATE TABLE Departamento (
    dnum INT PRIMARY KEY,
    dnome VARCHAR(50),
    gerRG INT,
    dt_inicio DATE
);

CREATE TABLE Empregado (
    RG INT PRIMARY KEY,
    sexo CHAR(1),
    dt_nasc DATE,
    pnome VARCHAR(50),
    unome VARCHAR(50),
    rua VARCHAR(100),
    cidade VARCHAR(50),
    estado VARCHAR(50),
    salario DECIMAL(10,2),
    dnum INT,
    supRG INT,
    FOREIGN KEY (dnum) REFERENCES Departamento(dnum),
    FOREIGN KEY (supRG) REFERENCES Empregado(RG)
);

ALTER TABLE Departamento
ADD CONSTRAINT fk_gerente FOREIGN KEY (gerRG) REFERENCES Empregado(RG);

CREATE TABLE Projeto (
    pnum INT PRIMARY KEY,
    pnome VARCHAR(50),
    localizacao VARCHAR(50),
    dnum INT,
    FOREIGN KEY (dnum) REFERENCES Departamento(dnum)
);

CREATE TABLE Dependente (
    dep_nome VARCHAR(50),
    dep_sexo CHAR(1),
    dep_dt_nasc DATE,
    empRG INT,
    PRIMARY KEY (dep_nome, empRG),
    FOREIGN KEY (empRG) REFERENCES Empregado(RG)
);

CREATE TABLE Trabalha_em (
    RG INT,
    pnum INT,
    horas DECIMAL(5,2),
    PRIMARY KEY (RG, pnum),
    FOREIGN KEY (RG) REFERENCES Empregado(RG),
    FOREIGN KEY (pnum) REFERENCES Projeto(pnum)
);

CREATE TABLE Localizacao (
    localizacao VARCHAR(50),
    dnum INT,
    PRIMARY KEY (localizacao, dnum),
    FOREIGN KEY (dnum) REFERENCES Departamento(dnum)
);

-- =========================
-- DADOS
-- =========================

INSERT INTO Departamento VALUES
(1, 'Administração', NULL, '2020-01-10'),
(4, 'Financeiro', NULL, '2021-03-15'),
(5, 'Pesquisa', NULL, '2019-07-01');

INSERT INTO Empregado VALUES
(101, 'M', '1990-05-10', 'Romarinho', 'Silva', 'Rua A', 'Brasília', 'DF', 4000, 5, NULL),
(102, 'M', '1985-09-18', 'Ronaldo', 'Fenômeno', 'Rua B', 'Brasília', 'DF', 5200, 1, NULL),
(103, 'F', '1992-08-21', 'Ana', 'Souza', 'Rua C', 'Brasília', 'DF', 2500, 4, 101),
(104, 'M', '1988-11-30', 'João', 'Oliveira', 'Rua D', 'Brasília', 'DF', 3200, 5, 101),
(105, 'F', '1995-02-14', 'Mariana', 'Costa', 'Rua E', 'Brasília', 'DF', 1800, 4, 103);

-- definir gerentes depois
UPDATE Departamento SET gerRG = 102 WHERE dnum = 1;
UPDATE Departamento SET gerRG = 103 WHERE dnum = 4;
UPDATE Departamento SET gerRG = 101 WHERE dnum = 5;

INSERT INTO Projeto VALUES
(201, 'Sistema X', 'Brasília', 5),
(202, 'Sistema Y', 'Londrina', 5),
(203, 'Auditoria Z', 'Brasília', 4),
(204, 'Controle W', 'Londrina', 1);

INSERT INTO Dependente VALUES
('Romarinho', 'M', '2015-01-01', 101),
('Ana', 'F', '2010-03-12', 103),
('Lucas', 'M', '2012-07-07', 104),
('Mariana', 'F', '2018-09-09', 105);

INSERT INTO Trabalha_em VALUES
(101, 201, 20),
(101, 202, 10),
(103, 203, 30),
(104, 201, 25),
(105, 203, 15),
(102, 204, 40);

INSERT INTO Localizacao VALUES
('Brasília', 1),
('São Paulo', 1),
('Brasília', 4),
('Rio de Janeiro', 5),
('Londrina', 5);

-- =========================
-- CONSULTAS
-- =========================

-- 1
SELECT * FROM Empregado WHERE dnum = 5;

-- 2
SELECT * FROM Empregado WHERE salario > 3000;

-- 3
SELECT * FROM Empregado WHERE dnum = 5 AND salario > 3000;

-- 4
SELECT * FROM Empregado
WHERE (dnum = 5 AND salario > 3000)
   OR (dnum = 4 AND salario > 2000);

-- 5
SELECT pnome, salario FROM Empregado;

-- 6
SELECT pnome, salario FROM Empregado WHERE dnum = 5;

-- 7
SELECT RG FROM Empregado WHERE dnum = 5
UNION
SELECT supRG FROM Empregado WHERE dnum = 5 AND supRG IS NOT NULL;

-- 8
SELECT DISTINCT e.pnome
FROM Empregado e
JOIN Dependente d ON e.pnome = d.dep_nome;

-- 9
SELECT e.pnome, d.dep_nome
FROM Empregado e CROSS JOIN Dependente d;

-- 10
SELECT e.pnome, d.dep_nome
FROM Empregado e
JOIN Dependente d ON e.RG = d.empRG;

-- 11
SELECT d.dnome, e.pnome, e.unome
FROM Departamento d
JOIN Empregado e ON d.gerRG = e.RG;

-- 12
SELECT d.dnum, l.localizacao
FROM Departamento d
JOIN Localizacao l ON d.dnum = l.dnum;

-- 13
SELECT e.pnome AS empregado, p.pnome AS projeto
FROM Empregado e
JOIN Trabalha_em t ON e.RG = t.RG
JOIN Projeto p ON t.pnum = p.pnum;

-- 14
SELECT DISTINCT e.pnome
FROM Empregado e
JOIN Trabalha_em t ON e.RG = t.RG
JOIN Projeto p ON t.pnum = p.pnum
WHERE p.dnum = 5;

-- 15
SELECT COUNT(*) FROM Empregado;

-- 16
SELECT dnum, COUNT(*) 
FROM Empregado
GROUP BY dnum;

-- 17
SELECT dnum, AVG(salario)
FROM Empregado
GROUP BY dnum;

-- 18
SELECT e.pnome, e.rua, e.cidade, e.estado
FROM Empregado e
JOIN Departamento d ON e.dnum = d.dnum
WHERE d.dnome = 'Pesquisa';

-- 19
SELECT p.pnum, p.dnum, e.pnome, e.sexo
FROM Projeto p
JOIN Departamento d ON p.dnum = d.dnum
JOIN Empregado e ON d.gerRG = e.RG
WHERE p.localizacao = 'Londrina';