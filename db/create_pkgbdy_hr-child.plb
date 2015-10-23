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
      PROCEDURE validate_sal(
                               p_sal    IN NUMBER
                             )
      IS
      BEGIN
         IF p_sal < 0
         THEN
            RAISE negative_salary;
         END IF;
      EXCEPTION
         WHEN negative_salary
         THEN
            RAISE;
         WHEN exceeded_specified_precision
         THEN
            RAISE value_too_large;
      END;
   BEGIN
      --
      validate_sal( p_sal );
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
      WHERE  empno = p_empno;
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
   -- create a department
   --
   PROCEDURE add_dept(
                           p_deptno    IN NUMBER,
                           p_dname     IN VARCHAR2,
                           p_loc       IN VARCHAR2,
                           p_details IN OUT  hr_child.dept_details_refcur_t
                     )
   IS
   BEGIN
      --
      INSERT INTO dept
         (
            deptno,
            dname,
            loc
         )
         VALUES
         (
            p_deptno,
            p_dname,
            p_loc
         );
      --
     COMMIT WORK;
     --
     get_dept_details(
                            p_deptno   => p_deptno,
                            p_details  => p_details
                         );
     --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all details for all departments
   --
   PROCEDURE get_dept_details(
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
   PROCEDURE get_dept_details(
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
   PROCEDURE update_dept_name(
                                    p_deptno  IN dept.deptno%TYPE,
                                    p_name   IN VARCHAR2
                             )
   IS
   BEGIN
      --
      --
      UPDATE   dept
      SET      dname = p_name
      WHERE    deptno  = p_deptno;
      --
      COMMIT WORK;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's location
   --
   PROCEDURE update_dept_loc(
                                    p_deptno  IN dept.deptno%TYPE,
                                    p_loc   IN VARCHAR2
                             )
   IS
   BEGIN
      --
      --
      UPDATE   dept
      SET      loc = p_loc
      WHERE    deptno  = p_deptno;
      --
      COMMIT WORK;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified department
   --
   PROCEDURE delete_dept(
                           p_deptno  IN dept.deptno%TYPE
                        )
   IS
   BEGIN
      --
      DELETE dept
      WHERE  deptno = p_deptno;
      --
      COMMIT WORK;
      --
   END;
   --
   --
   --============================================================
   --
   -- exception messages
   --
   PROCEDURE msg (
                        p_retcode   IN  NUMBER,
                        p_msg       OUT VARCHAR2
                  )
   IS
      retval VARCHAR2(300) := 'undefined error';
   BEGIN
      --
      p_msg :=  retval;
      --
      CASE  p_retcode
         WHEN ec_success             THEN retval := 'operation succeeded';
         WHEN ec_negative_salary     THEN retval := 'negative salary';
         WHEN ec_value_too_large     THEN retval := 'value too large for this field or text too long for this field';
         WHEN ec_martians_landed     THEN retval := 'Martians Landed!  THIS IS NOT A DRILL!';
      ELSE
         retval := 'internal error: routine likely encountered unexpected exception(' || TO_CHAR( p_retcode ) || ')';
      END CASE;
      p_msg := retval;
   END;
   --
      FUNCTION msg ( p_retcode   IN NUMBER) RETURN VARCHAR2
      IS
         v_buf VARCHAR2(200);
      BEGIN
         msg( p_retcode, v_buf );
         RETURN v_buf;
      END;
   --
END;
/


