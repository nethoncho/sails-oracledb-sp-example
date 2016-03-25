--
-- hr.pls
--
-- This package is called by the Sails-oracle-sp adapter.
--
-- This package is an example of the facade design pattern,
-- which wraps a complicated subsystem with a simpler interface.
-- This package provides Sails-oracle-sp with stored procedures that
-- have predictable names.  These stored procedures provide
-- Sails-oracle-sp with an interface to legacy stored procedures with
-- arbitrary names and arbitrary parameters.  This enables
-- such legacy stored procedures to be used by Sails-oracle-sp without
-- modification.
--
-- Interfacing such legacy stored procedures to Sails without
-- Sails-oracle-sp commits the developer to writing custom
-- Sail's adapter code for each stored procedure to be called.
-- In contrast, Sails-oracle-sp programmatically generates the
-- Sail's adapter code for each stored procedure to be called.
--
-- This "glue" package enables legacy stored procedures to be
-- used by Sails-oracle-sp without modification
-- Sails-oracle-sp depends on the procedures in this package to follow a
-- particular naming pattern: "model-name"_"CRUD indicator".
--
-- The "CRUD indicator" is a letter following the last underscore in
-- the procedure's name.  In this package the various procedures
-- that affect the employee table are:
--
--    employees_c()  -- create an employee
--    employees_r()  -- read employee details
--    employees_u()  -- update  employee details
--    employees_d()  -- destroy an employee
--
-- The "model-name" part of the procedure's name is specified in
-- one of Sail's MVC models, which are located in the
-- .../sails-oracledb-sp-example/api/models directory.
--
-- Sail's models names are conceptually table names, but
-- Sails-oracle-sp has repurposed model names as stored procedure names.
--
-- This example can only modify the employee table.  Adding the means
-- to modify, say, the department table requires a "department" model and
-- adding procedures named department_c(), department_r(),
-- department_u() and department_d().
--
-- This naming pattern enables Sails-oracle-sp to automatically generate
-- the stored procedure calling syntax for all of these stored procedures.
--
-- Sails-oracle-sp uses "named notation" when invoking stored procedures.
-- Using named notation relieves Sails-oracle-sp placing parameters in
-- any particular order.
--

CREATE OR REPLACE
PACKAGE hr
IS
   --
   --===========================================================
   --
   -- employees
   --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE employees_c(
                            p_employee_id    IN       NUMBER,
                            p_first_name     IN       VARCHAR2,
                            p_last_name      IN       VARCHAR2,
                            p_email          IN       VARCHAR2,
                            p_phone_number   IN       VARCHAR2,
                            p_hire_date      IN       VARCHAR2,
                            p_job_id         IN       VARCHAR2,
                            p_salary         IN       NUMBER,
                            p_commission_pct IN       NUMBER,
                            p_manager_id     IN       NUMBER,
                            p_department_id  IN       NUMBER,
                            p_details        IN OUT   hr_child.empl_details_refcur_t
                        );
   -----------------------------------------------------------------------------------
   --
   -- obtain details for all employees
   --
   PROCEDURE employees_r(
                             p_details    IN OUT  hr_child.empl_details_refcur_t
                          );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specific employee's details
   --
   PROCEDURE employees_r(
                             p_employee_id      IN      employees.employee_id%TYPE,
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read the details for all of the employees in a specified department
   --
   PROCEDURE employees_r(
                             p_department_id    IN      departments.department_id%TYPE,
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific employee's salary
   --
   PROCEDURE employees_u(
                           p_employee_id  IN employees.employee_id%TYPE,
                           p_salary       IN NUMBER
                        );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE employees_u(
                           p_employee_id     IN employees.employee_id%TYPE,
                           p_department_id   IN employees.department_id%TYPE
                        );
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE employees_d(
                            p_employee_id IN employees.employee_id%TYPE
                        );
   --
   --===========================================================
   --
   -- departments
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- create a department
   --
   PROCEDURE departments_c(
                              p_department_id    IN      NUMBER,
                              p_dname            IN      VARCHAR2,
                              p_location_id      IN      NUMBER,
                              p_mgr_id           IN      NUMBER,
                              p_details          IN OUT  hr_child.dept_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- Read details on all departments
   --
   PROCEDURE departments_r(
                             p_details  IN OUT  hr_child.dept_details_refcur_t
                          );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read details on a specified departments
   --
   PROCEDURE departments_r(
                             p_department_id    IN      NUMBER,
                             p_details          IN OUT  hr_child.dept_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's name
   --
   PROCEDURE departments_u(
                             p_department_id    IN departments.department_id%TYPE,
                             p_department_name  IN VARCHAR2
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's location
   --
   PROCEDURE departments_u(
                             p_department_id  IN departments.department_id%TYPE,
                             p_loc     IN VARCHAR2
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified department
   --
   PROCEDURE departments_d(
                              p_department_id  IN departments.department_id%TYPE
                          );
   --
   --===========================================================
   --
   -- return_codes_r()
   --
   -- return resultset comprised of all exception error messages
   --
   PROCEDURE return_codes_r( p_details  IN OUT SYS_REFCURSOR );
   --
   --==========================================================
   --
   -- reset database back to devault data (housekeeping)
   --
   PROCEDURE housekeeping_d;
   --
END;
/

