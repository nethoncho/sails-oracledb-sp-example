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
   --===============================================================
   --
   -- create programer defined exceptions
   --
   ec_success                      CONSTANT NUMBER := 0;
   --
   ec_negative_salary              CONSTANT NUMBER          := 20010;
   negative_salary                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  negative_salary, -20010 );
   --
   ec_value_too_large              CONSTANT NUMBER          := 20011;
   value_too_large                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  value_too_large, -20011 );
   --
   ec_text_too_long              CONSTANT NUMBER          := 20012;
   text_too_long                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  text_too_long, -20012 );
   --
   ec_martians_landed              CONSTANT NUMBER          := 20013;
   martians_landed                 EXCEPTION;
   PRAGMA EXCEPTION_INIT(  martians_landed, -20013 );
   --
   ec_undefined_failure            CONSTANT NUMBER := 20014;
   --
   ---------------------------------------------------
   --
   -- name system exceptions
   --
   -- ORA-01438: value larger than specified precision allowed for this column
   --
   exceeded_specified_precision  EXCEPTION;
   PRAGMA EXCEPTION_INIT(  exceeded_specified_precision, -1438 );
   --
   -- ORA-12899: value too large for column
   --
   val_too_long_for_col  EXCEPTION;
   PRAGMA EXCEPTION_INIT(  val_too_long_for_col, -12899 );
   --
   --=======================================================
   --
   -- refcursors
   --
   TYPE empl_details_refcur_t IS REF CURSOR RETURN emp%ROWTYPE;
   TYPE dept_details_refcur_t IS REF CURSOR RETURN dept%ROWTYPE;
   --
   --===========================================================
   --
   -- emp
   --
   -- CRUD procedures for the emp table
   --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE create_emp(
                           p_empno      IN     NUMBER,
                           p_ename      IN     VARCHAR2,
                           p_job        IN     VARCHAR2,
                           p_mgr        IN     NUMBER,
                           p_hiredate   IN     VARCHAR2,
                           p_sal        IN     NUMBER,
                           p_comm       IN     NUMBER,
                           p_deptno     IN     NUMBER,
                           p_details    IN OUT empl_details_refcur_t
                        );
   -----------------------------------------------------------------------------------
   --
   -- obtain details for all employees
   --
   PROCEDURE get_all_emp_details(
                                   p_details IN OUT  empl_details_refcur_t
                                );
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain a specific employee's details
   --
   PROCEDURE get_employee_details(
                                      p_empno     IN      emp.empno%TYPE,
                                      p_details   IN OUT  empl_details_refcur_t
                                   );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific employee's salary
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
                                 p_empno   IN emp.empno%TYPE,
                                 p_deptno  IN emp.deptno%TYPE
                           );
   -----------------------------------------------------------------------------------
   --
   -- destroy a specific employee
   --
   PROCEDURE delete_emp(
                          p_empno  IN emp.empno%TYPE
                       );
   --
   --===========================================================
   --
   -- departments
   --
   -- CRUD procedures for the dept table
   --
   -----------------------------------------------------------------------------------
   --
   -- create a department
   --
   PROCEDURE add_dept(
                           p_deptno    IN      NUMBER,
                           p_dname     IN      VARCHAR2,
                           p_loc       IN      VARCHAR2,
                           p_details   IN OUT  hr_child.dept_details_refcur_t
                       );
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain details for all departments
   --
   PROCEDURE get_dept_details(
                                p_details IN OUT  hr_child.dept_details_refcur_t
                             );
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain details on a specific department
   --
   PROCEDURE get_dept_details(
                                p_deptno    IN      NUMBER,
                                p_details   IN OUT  hr_child.dept_details_refcur_t
                             );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific department's name
   --
   PROCEDURE update_dept_name(
                                p_deptno  IN dept.deptno%TYPE,
                                p_name    IN VARCHAR2
                             );
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific department's location
   --
   PROCEDURE update_dept_loc(
                                p_deptno  IN dept.deptno%TYPE,
                                p_loc     IN VARCHAR2
                             );
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specific department
   --
   PROCEDURE delete_dept(
                           p_deptno  IN dept.deptno%TYPE
                        );
   --
   --===============================================================
   --
   -- For obtaining the message pertaining to a programer-defined exception
   --
   FUNCTION msg ( p_retcode   IN NUMBER) RETURN VARCHAR2;
   --
   --=============================================================================
   --
   -- housekeeping.
   --
   -- Reset the employee and department tables back to default data
   --
   -- This procedure is not a member of a set of CRUD procedures because
   -- it conduct a blend of operations, some deletes and some inserts.
   -- The "_d" appended to this procedure's name is a dummy element that
   -- is only there because sails-oracle-sp can only invoke procedures with
   -- a CRUD-wart.
   --
   PROCEDURE housekeeping_d;
   --
END;
/

