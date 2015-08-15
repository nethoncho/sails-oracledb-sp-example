--
-- hr.plb
--
CREATE OR REPLACE
PACKAGE BODY hr_child
IS
   --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE employees_c(
                           p_FIRST_NAME      IN VARCHAR2,
                           p_LAST_NAME       IN VARCHAR2,
                           p_EMAIL           IN VARCHAR2,
                           p_PHONE_NUMBER    IN VARCHAR2,
                           p_HIRE_DATE       IN VARCHAR2,
                           p_JOB_ID          IN VARCHAR2,
                           p_SALARY          IN NUMBER,
                           p_COMMISSION_PCT  IN NUMBER,
                           p_MANAGER_ID      IN NUMBER,
                           p_DEPARTMENT_ID   IN NUMBER,
                           p_details         IN OUT empl_details_refcur_t
                        )
   IS
      v_EMPLOYEE_ID NUMBER := EMPLOYEES_SEQ.nextval;
   BEGIN
      --
      INSERT INTO employees
         (
            EMPLOYEE_ID,
            FIRST_NAME,
            LAST_NAME,
            EMAIL,
            PHONE_NUMBER,
            HIRE_DATE,
            JOB_ID,
            SALARY,
            COMMISSION_PCT,
            MANAGER_ID,
            DEPARTMENT_ID
         )
         VALUES
         (
            v_EMPLOYEE_ID,
            p_FIRST_NAME,
            p_LAST_NAME,
            p_EMAIL,
            p_PHONE_NUMBER,
            TO_TIMESTAMP_TZ( p_HIRE_DATE, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"' ),
            p_JOB_ID,
            p_SALARY,
            p_COMMISSION_PCT,
            p_MANAGER_ID,
            p_DEPARTMENT_ID
         );
      --
     COMMIT WORK;
     --
     employees_r(
                  p_employee_id  => v_EMPLOYEE_ID,
                   p_details     => p_details
                );
     --
     --
   END;

   -----------------------------------------------------------------------------------
   --
   -- Read all employee details
   --
   PROCEDURE employees_r(
                             p_details    IN OUT  empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   EMPLOYEE_ID         AS EMPLOYEE_ID,
                  FIRST_NAME          AS FIRST_NAME,
                  LAST_NAME           AS LAST_NAME,
                  EMAIL               AS EMAIL,
                  PHONE_NUMBER        AS PHONE_NUMBER,
                  SYSDATE             AS HIRE_DATE,
                  JOB_ID              AS JOB_ID,
                  SALARY              AS SALARY,
                  COMMISSION_PCT      AS COMMISSION_PCT,
                  MANAGER_ID          AS MANAGER_ID,
                  DEPARTMENT_ID       AS DEPARTMENT_ID
         FROM   employees;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specified employee's details
   --
   PROCEDURE employees_r(
                             p_employee_id      IN      employees.employee_id%TYPE,
                             p_details          IN OUT  empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     employees
         WHERE    employee_id = p_employee_id;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's email
   --
   PROCEDURE employees_u(
                           p_employee_id  IN       employees.employee_id%TYPE,
                           p_email        IN       VARCHAR2
                        )
   IS
   BEGIN
      --
      UPDATE   employees
      SET      email = p_email
      WHERE    employee_id = p_employee_id;
      --
      COMMIT WORK;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE employees_d(
                             p_employee_id      IN      employees.employee_id%TYPE
                          )
   IS
   BEGIN
      --
      DELETE employees
      WHERE    employee_id = p_employee_id;
      --
      COMMIT WORK;
      --
   END;

END;
/


