CREATE TABLE CONTA_CORRENTE (
  NUMERO_CC NUMBER(8),
  SALDO_CC NUMBER(10,2),
  DATA_ATUALIZACAO_CC TIMESTAMP DEFAULT SYSDATE
) TABLESPACE TBS_PF0807_DADOS;

INSERT INTO CONTA_CORRENTE (NUMERO_CC, SALDO_CC)
VALUES (1001, 1000.00);

INSERT INTO CONTA_CORRENTE (NUMERO_CC, SALDO_CC)
VALUES (1002, 2000.00);

INSERT INTO CONTA_CORRENTE (NUMERO_CC, SALDO_CC)
VALUES (1003, 3000.00);

INSERT INTO CONTA_CORRENTE (NUMERO_CC, SALDO_CC)
VALUES (1004, 4000.00);

INSERT INTO CONTA_CORRENTE (NUMERO_CC, SALDO_CC)
VALUES (1005, 5000.00);


SET SERVEROUTPUT ON SIZE 1000000

SELECT COUNT(*) FROM CONTA_CORRENTE;

-- Atomicidade
DECLARE
  v_contador number;
BEGIN
  v_contador := 1000;
  
  while (v_contador < 1050) loop
  
    insert into conta_corrente (numero_cc, saldo_cc) values (v_contador, v_contador*1.3);
	
	v_contador := v_contador + 1;
	
	dbms_lock.sleep(1);
	
  end loop;
  
  commit;
  
  dbms_output.put_line('Inseridas novas C/C: ' || v_contador);
END;
/

-- Control ^C para abortar a transação.

SELECT COUNT(*) FROM CONTA_CORRENTE;


-- Consistência
SET LINESIZE 300
COL DATA_ATUALIZACAO_CC FOR A30

SELECT * FROM CONTA_CORRENTE WHERE numero_cc IN (1000, 1001);

UPDATE conta_corrente SET saldo_cc = saldo_cc - 50 
 WHERE numero_cc = 1000;
 
UPDATE conta_corrente SET saldo_cc = saldo_cc + 50 
 WHERE numero_cc = 1001;
 
SELECT * FROM CONTA_CORRENTE WHERE numero_cc IN (1000, 1001);

COMMIT;


-- Isolamento

-- Transação 1

SELECT * FROM CONTA_CORRENTE WHERE numero_cc = 1001;

UPDATE conta_corrente SET saldo_cc = saldo_cc - 10.3 
 WHERE numero_cc = 1001;

--COMMIT;


-- Transação 2

SELECT * FROM CONTA_CORRENTE WHERE numero_cc = 1001;

UPDATE conta_corrente SET saldo_cc = saldo_cc - 20 
 WHERE numero_cc = 1001;
 
--COMMIT;




-- DEAD LOCK (Bloqueio da morte)

-- Transação 1
--- 1
UPDATE conta_corrente SET saldo_cc = saldo_cc - 10
 WHERE numero_cc = 1001;
 
--- 4
UPDATE conta_corrente SET saldo_cc = saldo_cc - 10
 WHERE numero_cc = 1002;
 
 
-- Transação 2
--- 2
UPDATE conta_corrente SET saldo_cc = saldo_cc - 10
 WHERE numero_cc = 1002;

--- 3
UPDATE conta_corrente SET saldo_cc = saldo_cc - 10
 WHERE numero_cc = 1001;
 
