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
-- Sails-oracle-sp commits the developer to writting custom
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
-- Sail's models names are conceptionally table names, but
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
-- Using named notation relieves Sails-oracle-sp placing parametes in
-- any particular order.
--

CREATE OR REPLACE
PACKAGE hr
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
                        );
   -----------------------------------------------------------------------------------
   --
   -- Read all employees' details
   --
   PROCEDURE employees_r(
                             p_details    IN OUT  hr_child.empl_details_refcur_t
                          );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specified employee's details
   --
   PROCEDURE employees_r(
                             p_employee_id      IN      employees.employee_id%TYPE,
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's email
   --
   PROCEDURE employees_u(
                           p_employee_id  IN       employees.employee_id%TYPE,
                           p_email        IN       VARCHAR2
                        );
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

