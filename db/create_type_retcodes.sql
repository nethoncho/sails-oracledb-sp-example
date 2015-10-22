--
-- create_type_retcodes.sql
--

CREATE TYPE retcode_obj_t IS OBJECT
(
      id       NUMBER,
      message  VARCHAR2(300)
);
/

CREATE TYPE retcode_nt IS TABLE OF retcode_obj_t;
/



EXIT



