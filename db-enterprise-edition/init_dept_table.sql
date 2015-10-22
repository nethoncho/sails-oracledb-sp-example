--
-- init_dept_table.sql
--
-- initialize dept table with data
--
-- credits to https://apexplained.wordpress.com/2013/04/20/the-emp-and-dept-tables-in-oracle/
--
BEGIN
   INSERT INTO dept VALUES(10, 'ACCOUNTING', 'NEW YORK');
   INSERT INTO dept VALUES(20, 'RESEARCH',   'DALLAS');
   INSERT INTO dept VALUES(30, 'SALES',      'CHICAGO');
   INSERT INTO dept VALUES(40, 'OPERATIONS', 'BOSTON');
END;
/

