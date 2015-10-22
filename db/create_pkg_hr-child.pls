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
   ec_success                      CONSTANT NUMBER := 0;
   --
   ec_negative_salary              CONSTANT NUMBER          := 20010;
   negative_salary                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  negative_salary, -20010 );
   --
   ec_martians_landed              CONSTANT NUMBER          := 20011;
   martians_landed                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  martians_landed, -20011 );
   --
   ec_undefined_failure            CONSTANT NUMBER := 20012;
   --
   FUNCTION msg ( p_retcode   IN NUMBER) RETURN VARCHAR2;
   --
   --=======================================================
   --
   TYPE empl_details_refcur_t IS REF CURSOR RETURN emp%ROWTYPE;
   TYPE dept_details_refcur_t IS REF CURSOR RETURN dept%ROWTYPE;
   --===========================================================
   --
   -- emp
   --
    --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE create_emp(
                           p_empno        IN NUMBER,
                           p_ename        IN VARCHAR2,
                           p_job          IN VARCHAR2,
                           p_mgr          IN VARCHAR2,
                           p_hiredate     IN VARCHAR2,
                           p_sal          IN VARCHAR2,
                           p_comm         IN NUMBER,
                           p_deptno       IN NUMBER,
                           p_details      IN OUT empl_details_refcur_t
                        );
   -----------------------------------------------------------------------------------
   --
   -- Read all emp' details
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
                                      p_empno     IN      emp.empno%TYPE,
                                      p_details   IN OUT  empl_details_refcur_t
                                   );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's salary
   --
   PROCEDURE update_emp_salary(
                                 p_empno  IN emp.empno%TYPE,
                                 p_sal    IN NUMBER
                              );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE xver_employees(
                                 p_empno     IN       emp.empno%TYPE,
                                 p_deptno    IN       emp.deptno%TYPE
                           );
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE delete_emp(
                             p_empno      IN      emp.empno%TYPE
                       );
   --
   --===========================================================
   --
   -- departments
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all emp details
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
                             p_deptno    IN       NUMBER,
                             p_details          IN OUT  hr_child.dept_details_refcur_t
                          );
END;
/

