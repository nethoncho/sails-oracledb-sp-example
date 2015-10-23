--
-- hr.plb
--
CREATE OR REPLACE
PACKAGE BODY hr
IS
   --
   --==================================================================
   --
   -- return_codes_r()
   --
   --    obtains list of error messages for various user-defined Oracle Exceptions.
   --
   PROCEDURE return_codes_r( p_details     IN OUT   SYS_REFCURSOR )
   IS
      --
      retcode_details_tab   retcode_nt := retcode_nt();
      --
   BEGIN
      FOR v_retcode IN hr_child.ec_negative_salary .. hr_child.ec_undefined_failure
      LOOP
         BEGIN
            retcode_details_tab.EXTEND();
            retcode_details_tab(retcode_details_tab.LAST) := retcode_obj_t(
                                                                              v_retcode,
                                                                              hr_child.msg ( v_retcode )
                                                                          );
         END;
      END LOOP;
      --
      OPEN p_details FOR
         SELECT *
         FROM TABLE(cast(retcode_details_tab AS retcode_nt));
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE employees_c(
                           p_empno        IN NUMBER,
                           p_ename        IN VARCHAR2,
                           p_job          IN VARCHAR2,
                           p_mgr          IN VARCHAR2,
                           p_hiredate     IN VARCHAR2,
                           p_sal          IN NUMBER,
                           p_comm         IN NUMBER,
                           p_deptno       IN NUMBER,
                           p_details      IN OUT hr_child.empl_details_refcur_t
                        )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.create_emp(
                                 p_empno,
                                 p_ename,
                                 p_job,
                                 p_mgr,
                                 p_hiredate,
                                 p_sal,
                                 p_comm,
                                 p_deptno,
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
         FROM   emp;
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
                             p_empno      IN      emp.empno%TYPE,
                             p_details    IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     emp
         WHERE    empno = p_empno;
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
                             p_deptno    IN      dept.deptno%TYPE,
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     emp
         WHERE    deptno = p_deptno;
      --
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's salary
   --
   PROCEDURE employees_u(
                           p_empno  IN emp.empno%TYPE,
                           p_sal    IN NUMBER
                        )
   IS
   BEGIN
      hr_child.update_emp_salary(
                                    p_empno,
                                    p_sal
                                );
      --
   EXCEPTION
      WHEN hr_child.negative_salary
      THEN
         RAISE;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE employees_u(
                           p_empno    IN       emp.empno%TYPE,
                           p_deptno   IN       emp.deptno%TYPE
                        )
   IS
   BEGIN
      hr_child.xver_employees(
                                    p_empno,
                                    p_deptno
                                );
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE employees_d(
                            p_empno IN emp.empno%TYPE
                        )
   IS
   BEGIN
      --
      hr_child.delete_emp( p_empno );
      --
   END;
   --
   --===========================================================
   --
   -- dept
   --
   -----------------------------------------------------------------------------------
   --
   -- create a department
   --
   PROCEDURE departments_c(
                              p_deptno    IN NUMBER,
                              p_dname     IN VARCHAR2,
                              p_loc       IN VARCHAR2,
                              p_details IN OUT  hr_child.dept_details_refcur_t
                          )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.add_dept(
                              p_deptno,
                              p_dname,
                              p_loc,
                              v_cursor
                           );
         p_details := v_cursor;
      END;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all emp details
   --
   PROCEDURE departments_r(
                             p_details IN OUT  hr_child.dept_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     dept;
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read details on a specified dept
   --
   PROCEDURE departments_r(
                             p_deptno    IN      NUMBER,
                             p_details   IN OUT  hr_child.dept_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     dept
         WHERE    deptno = p_deptno;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's name
   --
   PROCEDURE departments_u(
                              p_deptno  IN dept.deptno%TYPE,
                              p_dname   IN VARCHAR2
                          )
   IS
   BEGIN
      hr_child.update_dept_name(
                                    p_deptno,
                                    p_dname
                                );
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's location
   --
   PROCEDURE departments_u(
                              p_deptno  IN dept.deptno%TYPE,
                              p_loc     IN VARCHAR2
                          )
   IS
   BEGIN
      hr_child.update_dept_loc(
                                 p_deptno,
                                 p_loc
                              );
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified department
   --
   PROCEDURE departments_d(
                              p_deptno  IN dept.deptno%TYPE
                           )
   IS
   BEGIN
      hr_child.delete_dept(
                              p_deptno
                          );
      --
   END;
   --
END;
/


