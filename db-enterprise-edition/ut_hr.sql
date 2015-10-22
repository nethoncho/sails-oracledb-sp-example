--
-- unittest
--

DECLARE
   v_cursor sys_refcursor;
   v_rc     NUMBER := NULL;

   v_FIRST_NAME         VARCHAR2(100)  := 'John';
   v_LAST_NAME          VARCHAR2(100)  := 'Doe';
   v_EMAIL              VARCHAR2(200)  := 'someone@somewhere.com';
   v_PHONE_NUMBER       VARCHAR2(100)  := '011.44.1344.619268';
   --v_HIRE_DATE          VARCHAR2(100)  := '2013-01-22T00:00:00.0000000-05:00';
   v_HIRE_DATE          DATE           := SYSDATE;
   v_JOB_ID             VARCHAR2(100)  := 'SA_MAN';
   v_SALARY             NUMBER         := 11000;
   v_COMMISSION_PCT     NUMBER         := 0.3;
   v_MANAGER_ID         NUMBER         := 100;
   v_DEPARTMENT_ID      NUMBER         := 80;
BEGIN
   hr.employees_c(
                     v_FIRST_NAME,
                     v_LAST_NAME,
                     v_EMAIL,
                     v_PHONE_NUMBER,
                     v_HIRE_DATE,
                     v_JOB_ID,
                     v_SALARY,
                     v_COMMISSION_PCT,
                     v_MANAGER_ID,
                     v_DEPARTMENT_ID,
                     v_cursor,
                     v_rc
                 );
   --
   DECLARE
      v_employee_id        NUMBER         := NULL;
      v_FIRST_NAME         VARCHAR2(100)  := NULL;
      v_LAST_NAME          VARCHAR2(100)  := NULL;
      v_EMAIL              VARCHAR2(200)  := NULL;
      v_PHONE_NUMBER       VARCHAR2(100)  := NULL;
      v_hire_date          DATE           := NULL;
      v_JOB_ID             VARCHAR2(100)  := NULL;
      v_SALARY             NUMBER         := NULL;
      v_COMMISSION_PCT     NUMBER         := NULL;
      v_MANAGER_ID         NUMBER         := NULL;
      v_DEPARTMENT_ID      NUMBER         := NULL;
   BEGIN
      LOOP
         FETCH v_cursor
         INTO  v_employee_id,
               v_FIRST_NAME,
               v_LAST_NAME,
               v_EMAIL,
               v_PHONE_NUMBER,
               v_HIRE_DATE,
               v_JOB_ID,
               v_SALARY,
               v_COMMISSION_PCT,
               v_MANAGER_ID,
               v_DEPARTMENT_ID;
         --
         EXIT WHEN v_cursor%NOTFOUND;
         --
         DBMS_OUTPUT.PUT_LINE('v_employee_id,   '  || '(' || TO_CHAR( v_employee_id )    || ')' );
         DBMS_OUTPUT.PUT_LINE('v_FIRST_NAME,    '  || '(' ||          v_FIRST_NAME       || ')' );
         DBMS_OUTPUT.PUT_LINE('v_LAST_NAME,     '  || '(' ||          v_LAST_NAME        || ')' );
         DBMS_OUTPUT.PUT_LINE('v_EMAIL,         '  || '(' ||          v_EMAIL            || ')' );
         DBMS_OUTPUT.PUT_LINE('v_PHONE_NUMBER,  '  || '(' ||          v_PHONE_NUMBER     || ')' );
         DBMS_OUTPUT.PUT_LINE('v_HIRE_DATE,     '  || '(' || To_Char( v_HIRE_DATE )       || ')' );
         DBMS_OUTPUT.PUT_LINE('v_JOB_ID,        '  || '(' ||          v_JOB_ID           || ')' );
         DBMS_OUTPUT.PUT_LINE('v_SALARY,        '  || '(' || TO_CHAR( v_SALARY         ) || ')' );
         DBMS_OUTPUT.PUT_LINE('v_COMMISSION_PCT,'  || '(' || TO_CHAR( v_COMMISSION_PCT ) || ')' );
         DBMS_OUTPUT.PUT_LINE('v_MANAGER_ID,    '  || '(' || TO_CHAR( v_MANAGER_ID     ) || ')' );
         DBMS_OUTPUT.PUT_LINE('v_DEPARTMENT_ID; '  || '(' || TO_CHAR( v_DEPARTMENT_ID  ) || ')' );
      END LOOP;
   END;
   --
   CLOSE v_cursor;
   --

END;
/
