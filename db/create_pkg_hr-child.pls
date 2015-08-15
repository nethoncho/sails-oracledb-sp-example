--
-- hr.pls
--

CREATE OR REPLACE
PACKAGE hr_child
IS
   TYPE empl_details_refcur_t IS REF CURSOR RETURN employees%ROWTYPE;
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
                        );
   -----------------------------------------------------------------------------------
   --
   -- Read all employees' details
   --
   PROCEDURE employees_r(
                             p_details    IN OUT  empl_details_refcur_t
                          );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specified employee's details
   --
   PROCEDURE employees_r(
                             p_employee_id      IN      employees.employee_id%TYPE,
                             p_details          IN OUT  empl_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE employees_d(
                             p_employee_id      IN      employees.employee_id%TYPE
                          );
END;
/

