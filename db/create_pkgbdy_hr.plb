--
-- hr.plb
--
CREATE OR REPLACE
PACKAGE BODY hr
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
                           p_details         IN OUT hr_child.empl_details_refcur_t
                        )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.create_emp(
                                 p_FIRST_NAME,
                                 p_LAST_NAME,
                                 p_EMAIL,
                                 p_PHONE_NUMBER,
                                 p_HIRE_DATE,
                                 p_JOB_ID,
                                 p_SALARY,
                                 p_COMMISSION_PCT,
                                 p_MANAGER_ID,
                                 p_DEPARTMENT_ID,
                                 v_cursor
                              );
         p_details := v_cursor;
      END;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all employee details
   --
   PROCEDURE employees_r(
                             p_details    IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT *
         FROM   employees;
      --
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
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     employees
         WHERE    employee_id = p_employee_id;
      --
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
      hr_child.update_email_addr(
                                    p_employee_id,
                                    p_email
                                );
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE employees_d(
                             p_employee_id IN employees.employee_id%TYPE
                          )
   IS
   BEGIN
      --
      hr_child.delete_emp( p_employee_id );
      --
      --
   END;
   --
   --===========================================================
   --
   -- departments
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all employees details
   --
   PROCEDURE departments_r(
                             p_details IN OUT  hr_child.dept_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     departments;
   END;
   --
END;
/


