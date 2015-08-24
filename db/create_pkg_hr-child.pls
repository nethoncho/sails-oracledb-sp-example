--
-- hr.pls
--
-- In this example this package represents "legacy" stored procedures.
-- Conceptually these stored procedures are pretending to be
-- existing code that is in production and is otherwise working
-- fine, except they weren't designed to support being called via
-- REST APIs.
--
--

CREATE OR REPLACE
PACKAGE hr_child
IS
   --
   TYPE empl_details_refcur_t IS REF CURSOR RETURN employees%ROWTYPE;
   TYPE dept_details_refcur_t IS REF CURSOR RETURN departments%ROWTYPE;
   --===========================================================
   --
   -- employees
   --
    --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE create_emp(
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
   PROCEDURE get_all_emp_details(
                                   p_details    IN OUT  empl_details_refcur_t
                                );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specified employee's details
   --
   PROCEDURE get_employee_details(
                                      p_employee_id      IN      employees.employee_id%TYPE,
                                      p_details          IN OUT  empl_details_refcur_t
                                   );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's email
   --
   PROCEDURE update_email_addr(
                                 p_employee_id  IN       employees.employee_id%TYPE,
                                 p_email        IN       VARCHAR2
                              );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE xver_employees(
                                 p_employee_id     IN       employees.employee_id%TYPE,
                                 p_department_id   IN       employees.department_id%TYPE
                             );
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE delete_emp(
                             p_employee_id      IN      employees.employee_id%TYPE
                          );
   --
   --===========================================================
   --
   -- departments
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all employees details
   --
   PROCEDURE departments_r(
                             p_details IN OUT  hr_child.dept_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- Read details on a specified departments
   --
   PROCEDURE departments_r(
                             p_department_id    IN       NUMBER,
                             p_details          IN OUT  hr_child.dept_details_refcur_t
                          );
END;
/

