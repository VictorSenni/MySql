USE SalaDeAula;

-- 1)
/*
O arquivo sala-dml.sql foi construído utilizando diversos comandos INSERT 
para popular as tabelas com dados de teste. Essa abordagem funciona bem para gerar uma quantidade considerável de registros,
mas poderia ser melhorada utilizando inserções em lote, o que reduziria a quantidade de comandos executados e tornaria o processo mais eficiente.

Outra possibilidade seria utilizar ferramentas específicas para geração automática de dados ou até procedimentos armazenados,
facilitando futuras alterações e manutenções no script.

Em relação aos comandos TCL, seria interessante executar todas as inserções dentro de uma transação. Dessa forma,
caso ocorra algum erro durante o preenchimento do banco, seria possível desfazer todas as alterações com um ROLLBACK,
evitando inconsistências nos dados. Ao final da execução, um COMMIT confirmaria todas as inserções realizadas com sucesso.
*/


-- 2)
CREATE INDEX idx_pessoa_cpf
ON Pessoa(CPF);


-- 3a
CREATE FULLTEXT INDEX idx_ocorrencia
ON Avaliacao(ocorrencia);

-- 3b
SELECT *
FROM Avaliacao
WHERE tipo_prova = 'P3'
AND MATCH(ocorrencia)
AGAINST('cola' IN BOOLEAN MODE);


-- 4)
/*
A criação de índices traz como principal benefício a melhoria do desempenho das consultas, principalmente em tabelas com muitos registros.
 Operações de busca, filtragem e ordenação costumam ser executadas de forma mais rápida quando as colunas utilizadas possuem índices adequados.

Por outro lado, é importante ter cuidado ao criar muitos índices, pois eles também consomem espaço de armazenamento e aumentam o custo das operações de inserção,
 atualização e exclusão de dados. Isso acontece porque o banco precisa manter os índices atualizados sempre que os registros são modificados. Por esse motivo,
 os índices devem ser criados apenas em colunas que realmente são utilizadas com frequência nas consultas.
*/


-- 5)
CREATE VIEW vw_alunos_ocorrencias AS
SELECT
    a.matricula,
    p.nome,
    av.tipo_prova,
    av.ocorrencia
FROM Aluno a
INNER JOIN Pessoa p
    ON p.ID = a.pessoa_id
INNER JOIN Aluno_Turma atu
    ON atu.aluno_mat = a.matricula
INNER JOIN Avaliacao av
    ON av.aluno_turma_id = atu.ID
WHERE a.status = 'ativo'
  AND av.ocorrencia IS NOT NULL
  AND av.ocorrencia <> '';


-- 6)

CREATE VIEW vw_professores AS
SELECT
    pr.matricula,
    pr.ativo,
    p.nome,
    p.CPF,
    p.data_nascimento,
    p.end_cidade,
    p.end_uf_sigla
FROM Professor pr
INNER JOIN Pessoa p
    ON p.ID = pr.pessoa_id;


CREATE VIEW vw_alunos AS
SELECT
    a.matricula,
    a.status,
    a.dt_matricula,
    p.nome,
    p.CPF,
    p.data_nascimento,
    p.end_cidade,
    p.end_uf_sigla
FROM Aluno a
INNER JOIN Pessoa p
    ON p.ID = a.pessoa_id;


-- 7)
CREATE ROLE Secretaria;

GRANT SELECT, INSERT, UPDATE, CREATE, ALTER, INDEX,
      CREATE VIEW, SHOW VIEW, EXECUTE
ON SalaDeAula.*
TO Secretaria;


-- 8)
CREATE USER 'Maria'@'localhost'
IDENTIFIED BY 'Maria123';

GRANT Secretaria TO 'Maria'@'localhost';

SET DEFAULT ROLE Secretaria TO 'Maria'@'localhost';


-- 9)
DELIMITER $$

CREATE TRIGGER trg_zerar_nota_insert
BEFORE INSERT ON Avaliacao
FOR EACH ROW
BEGIN
    IF NEW.ocorrencia IS NOT NULL
       AND (
            LOWER(NEW.ocorrencia) LIKE '%cola%'
            OR LOWER(NEW.ocorrencia) LIKE '%fraude%'
            OR LOWER(NEW.ocorrencia) LIKE '%plágio%'
           )
    THEN
        SET NEW.nota = 0;
    END IF;
END$$

DELIMITER ;


-- 10)
DELIMITER $$

CREATE TRIGGER trg_zerar_nota_update
BEFORE UPDATE ON Avaliacao
FOR EACH ROW
BEGIN
    IF NEW.ocorrencia IS NOT NULL
       AND (
            LOWER(NEW.ocorrencia) LIKE '%cola%'
            OR LOWER(NEW.ocorrencia) LIKE '%fraude%'
            OR LOWER(NEW.ocorrencia) LIKE '%plágio%'
           )
    THEN
        SET NEW.nota = 0;
    END IF;
END$$

DELIMITER ;


-- 11)
DELIMITER $$

CREATE FUNCTION fn_nota_final(
    p_aluno VARCHAR(10),
    p_turma VARCHAR(12)
)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE v_media DECIMAL(4,2);

    SELECT AVG(av.nota)
    INTO v_media
    FROM Avaliacao av
    INNER JOIN Aluno_Turma atu
        ON atu.ID = av.aluno_turma_id
    WHERE atu.aluno_mat = p_aluno
      AND atu.turma_cod = p_turma;

    RETURN IFNULL(v_media,0);
END$$

DELIMITER ;


-- Exemplo de uso:
-- SELECT fn_nota_final('A0001','T0001');


-- 12)
DELIMITER $$

CREATE PROCEDURE pr_verificar_disciplina()
BEGIN

    UPDATE Aluno a
    SET status = 'suspenso'
    WHERE status = 'ativo'
      AND (
            SELECT COUNT(*)
            FROM Avaliacao av
            INNER JOIN Aluno_Turma atu
                ON atu.ID = av.aluno_turma_id
            WHERE atu.aluno_mat = a.matricula
              AND av.ocorrencia IS NOT NULL
              AND av.ocorrencia <> ''
          ) >= 3;

    UPDATE Aluno a
    SET status = 'expulso'
    WHERE status = 'suspenso'
      AND (
            SELECT COUNT(*)
            FROM Avaliacao av
            INNER JOIN Aluno_Turma atu
                ON atu.ID = av.aluno_turma_id
            WHERE atu.aluno_mat = a.matricula
              AND av.ocorrencia IS NOT NULL
              AND av.ocorrencia <> ''
          ) >= 9;

END$$

DELIMITER ;