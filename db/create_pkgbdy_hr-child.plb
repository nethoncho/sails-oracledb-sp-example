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
                        )
   IS
   BEGIN
      --
      INSERT INTO emp
         (
            empno,
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            deptno
         )
         VALUES
         (
            p_empno,
            p_ename,
            p_job,
            p_mgr,
            TO_TIMESTAMP_TZ( p_hiredate, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"' ),
            p_sal,
            p_comm,
            p_deptno
         );
      --
     COMMIT WORK;
     --
     get_employee_details(
                            p_empno    => p_empno,
                            p_details  => p_details
                         );
     --
     --
   END;

   -----------------------------------------------------------------------------------
   --
   -- Read all employee details
   --
   PROCEDURE get_all_emp_details(
                                      p_details    IN OUT  empl_details_refcur_t
                                   )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM   emp;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specified employee's details
   --
   PROCEDURE get_employee_details(
                                      p_empno      IN      emp.empno%TYPE,
                                      p_details    IN OUT  empl_details_refcur_t
                                   )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     emp
         WHERE    empno = p_empno;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified employee's salary
   --
   PROCEDURE update_emp_salary(
                                    p_empno  IN emp.empno%TYPE,
                                    p_sal    IN NUMBER
                               )
   IS
   BEGIN
      --
      UPDATE   emp
      SET      sal = p_sal
      WHERE    empno = p_empno;
      --
      COMMIT WORK;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE xver_employees(
                                 p_empno    IN       emp.empno%TYPE,
                                 p_deptno   IN       emp.deptno%TYPE
                             )
   IS
   BEGIN
      --
      UPDATE   emp
      SET      deptno  = p_deptno
      WHERE    empno   = p_empno;
      --
      COMMIT WORK;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified employee
   --
   PROCEDURE delete_emp(
                             p_empno      IN      emp.empno%TYPE
                          )
   IS
   BEGIN
      --
      DELETE emp
      WHERE    empno = p_empno;
      --
      COMMIT WORK;
      --
   END;
   --
   --===========================================================
   --
   -- deptno
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
   -- Read details on a specified deptno
   --
   PROCEDURE departments_r(
                             p_deptno    IN      NUMBER,
                             p_details          IN OUT  hr_child.dept_details_refcur_t
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

END;
/


