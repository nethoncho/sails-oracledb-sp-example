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
                           p_empno     IN     NUMBER,
                           p_ename     IN     VARCHAR2,
                           p_job       IN     VARCHAR2,
                           p_mgr       IN     NUMBER,
                           p_hiredate  IN     VARCHAR2,
                           p_sal       IN     NUMBER,
                           p_comm      IN     NUMBER,
                           p_deptno    IN     NUMBER,
                           p_details   IN OUT empl_details_refcur_t
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
   -- obtain details for all employees
   --
   PROCEDURE get_all_emp_details(
                                      p_details  IN OUT  empl_details_refcur_t
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
   -- obtain a specific employee's details
   --
   PROCEDURE get_employee_details(
                                      p_empno    IN      emp.empno%TYPE,
                                      p_details  IN OUT  empl_details_refcur_t
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
   -- update a specific employee's salary
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
   EXCEPTION
      WHEN exceeded_specified_precision
      THEN
         RAISE value_too_large;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- transfer employee to another department
   --
   PROCEDURE xver_employees(
                                 p_empno    IN  emp.empno%TYPE,
                                 p_deptno   IN  emp.deptno%TYPE
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
   -- destroy a specific employee
   --
   PROCEDURE delete_emp(
                          p_empno  IN emp.empno%TYPE
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
                           p_deptno    IN      NUMBER,
                           p_dname     IN      VARCHAR2,
                           p_loc       IN      VARCHAR2,
                           p_details   IN OUT  hr_child.dept_details_refcur_t
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
                                p_name    IN VARCHAR2
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
   EXCEPTION
      WHEN val_too_long_for_col
      THEN
         RAISE text_too_long;
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
   EXCEPTION
      WHEN val_too_long_for_col
      THEN
         RAISE text_too_long;
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
         WHEN ec_negative_salary     THEN retval := 'salary cannot be negative';
         WHEN ec_value_too_large     THEN retval := 'value too large for this field';
         WHEN ec_text_too_long       THEN retval := 'text too long for this field';
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
   --=============================================================================
   --
   -- housekeeping.  Reset the employee and department tables back to default data
   --
   PROCEDURE housekeeping_d
   IS
   BEGIN
      --
      --=========================================================
      --
      --  wipe-out the existing data
      --
      DELETE dept;
      DELETE emp;
      COMMIT;
      --
      --=========================================================
      --
      --  create emp data
      --
      DECLARE
         v_cursor SYS_REFCURSOR;
      BEGIN
         -----------------------------------------------------------
         -- (7369, 'SMITH', 'CLERK', 7902,TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, NULL, 20);
         create_emp(
                        p_empno        => 7369,
                        p_ename        => 'SMITH',
                        p_job          => 'CLERK',
                        p_mgr          => 7902,
                        p_hiredate     => '1980-12-17T00:00:00.000Z',
                        p_sal          => 800,
                        p_comm         => NULL,
                        p_deptno       => 20,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         --(7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30);
         create_emp(
                        p_empno        => 7499,
                        p_ename        => 'ALLEN',
                        p_job          => 'SALESMAN',
                        p_mgr          => 7698,
                        p_hiredate     => '1981-02-20T00:00:00.000Z',
                        p_sal          => 1600,
                        p_comm         => 300,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7521, 'WARD', 'SALESMAN', 7698, TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30);
         create_emp(
                        p_empno        => 7521,
                        p_ename        => 'WARD',
                        p_job          => 'SALESMAN',
                        p_mgr          => 7698,
                        p_hiredate     => '1981-02-22T00:00:00.000Z',
                        p_sal          => 1250,
                        p_comm         => 500,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7566, 'JONES', 'MANAGER', 7839,TO_DATE('2-APR-1981', 'DD-MON-YYYY'), 2975, NULL, 20);
         create_emp(
                        p_empno        => 7566,
                        p_ename        => 'JONES',
                        p_job          => 'MANAGER',
                        p_mgr          => 7839,
                        p_hiredate     => '1981-04-02T00:00:00.000Z',
                        p_sal          => 2975,
                        p_comm         => NULL,
                        p_deptno       => 20,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7654, 'MARTIN', 'SALESMAN', 7698,TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
         --
         create_emp(
                        p_empno        => 7654,
                        p_ename        => 'MARTIN',
                        p_job          => 'SALESMAN',
                        p_mgr          => 7698,
                        p_hiredate     => '1981-09-28T00:00:00.000Z',
                        p_sal          => 1250,
                        p_comm         => 1400,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7698, 'BLAKE', 'MANAGER', 7839,TO_DATE('1-MAY-1981', 'DD-MON-YYYY'), 2850, NULL, 30);
         create_emp(
                        p_empno        => 7698,
                        p_ename        => 'BLAKE',
                        p_job          => 'MANAGER',
                        p_mgr          => 7839,
                        p_hiredate     => '1981-05-01T00:00:00.000Z',
                        p_sal          => 2850,
                        p_comm         => NULL,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7782, 'CLARK', 'MANAGER', 7839,TO_DATE('9-JUN-1981', 'DD-MON-YYYY'), 2450, NULL, 10);
         create_emp(
                        p_empno        => 7782,
                        p_ename        => 'CLARK',
                        p_job          => 'MANAGER',
                        p_mgr          => 7839,
                        p_hiredate     => '1981-06-09T00:00:00.000Z',
                        p_sal          => 2450,
                        p_comm         => NULL,
                        p_deptno       => 10,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7788, 'scott', 'ANALYST', 7566,TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
         --
         create_emp(
                        p_empno        => 7788,
                        p_ename        => 'SCOTT',
                        p_job          => 'ANALYST',
                        p_mgr          => 7566,
                        p_hiredate     => '1982-12-09T00:00:00.000Z',
                        p_sal          => 3000,
                        p_comm         => NULL,
                        p_deptno       => 20,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7839, 'KING', 'PRESIDENT', NULL,TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);
         create_emp(
                        p_empno        => 7839,
                        p_ename        => 'KING',
                        p_job          => 'PRESIDENT',
                        p_mgr          => NULL,
                        p_hiredate     => '1981-11-17T00:00:00.000Z',
                        p_sal          => 5000,
                        p_comm         => NULL,
                        p_deptno       => 10,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7844, 'TURNER', 'SALESMAN', 7698,TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 1500, 0, 30);
         create_emp(
                        p_empno        => 7844,
                        p_ename        => 'TURNER',
                        p_job          => 'SALESMAN',
                        p_mgr          => 7698,
                        p_hiredate     => '1981-09-08T00:00:00.000Z',
                        p_sal          => 1500,
                        p_comm         => 0,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7876, 'ADAMS', 'CLERK', 7788,TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
         create_emp(
                        p_empno        => 7876,
                        p_ename        => 'ADAMS',
                        p_job          => 'CLERK',
                        p_mgr          => 7788,
                        p_hiredate     => '1983-01-12T00:00:00.000Z',
                        p_sal          => 1100,
                        p_comm         => NULL,
                        p_deptno       => 20,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7900, 'JAMES', 'CLERK', 7698, TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 950, NULL, 30);
         create_emp(
                        p_empno        => 7900,
                        p_ename        => 'JAMES',
                        p_job          => 'CLERK',
                        p_mgr          => 7698,
                        p_hiredate     => '1981-12-03T00:00:00.000Z',
                        p_sal          => 950,
                        p_comm         => NULL,
                        p_deptno       => 30,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7902, 'FORD', 'ANALYST', 7566,TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 3000, NULL, 20);
         create_emp(
                        p_empno        => 7902,
                        p_ename        => 'FORD',
                        p_job          => 'ANALYST',
                        p_mgr          => 7566,
                        p_hiredate     => '1981-12-03T00:00:00.000Z',
                        p_sal          => 3000,
                        p_comm         => NULL,
                        p_deptno       => 20,
                        p_details      => v_cursor
                     );
         --
         -----------------------------------------------------------
         --
         -- (7934, 'MILLER', 'CLERK', 7782,TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);
         create_emp(
                        p_empno        => 7934,
                        p_ename        => 'MILLER',
                        p_job          => 'CLERK',
                        p_mgr          => 7782,
                        p_hiredate     => '1982-01-23T00:00:00.000Z',
                        p_sal          => 1300,
                        p_comm         => NULL,
                        p_deptno       => 10,
                        p_details      => v_cursor
                     );
      END;
      --
      --=========================================================
      --
      --  create dept data
      --
      DECLARE
         v_cursor SYS_REFCURSOR;
      BEGIN
         --
         -- INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
         --
         add_dept(
                     p_deptno    =>  10,
                     p_dname     =>  'ACCOUNTING',
                     p_loc       =>  'NEW YORK',
                     p_details   =>  v_cursor
                 );
         --
         --  (20, 'RESEARCH', 'DALLAS');
         --
         add_dept(
                     p_deptno    =>  20,
                     p_dname     =>  'RESEARCH',
                     p_loc       =>  'DALLAS',
                     p_details   =>  v_cursor
                 );
         --
         -- (30, 'SALES', 'CHICAGO');
         --
         add_dept(
                     p_deptno    =>  30,
                     p_dname     =>  'SALES',
                     p_loc       =>  'CHICAGO',
                     p_details   =>  v_cursor
                 );
         --
         -- (40, 'OPERATIONS', 'BOSTON')
         --
         add_dept(
                     p_deptno    =>  40,
                     p_dname     =>  'OPERATIONS',
                     p_loc       =>  'BOSTON',
                     p_details   =>  v_cursor
                 );
         --
      END;
   END;
   --
END;
/


