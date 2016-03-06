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
                           p_emp_id          IN     NUMBER,
                           p_first_name      IN     VARCHAR2,
                           p_last_name       IN     VARCHAR2,
                           p_email           IN     VARCHAR2,
                           p_phone_number    IN     VARCHAR2,
                           p_hiredate        IN     VARCHAR2,
                           p_job_id          IN     VARCHAR2,
                           p_sal             IN     NUMBER,
                           p_comm_pct        IN     NUMBER,
                           p_mgr_id          IN     NUMBER,
                           p_department_id   IN     NUMBER,
                           p_details         IN OUT empl_details_refcur_t
                        )
   IS
   BEGIN
      --
      INSERT INTO employees
         (
            employee_id,
            first_name,
            last_name,
            email,
            phone_number,
            hire_date,
            job_id,
            salary,
            commission_pct,
            manager_id,
            department_id
          )
         VALUES
         (
            p_emp_id,
            p_first_name,
            p_last_name,
            p_email,
            p_phone_number,
            TO_TIMESTAMP_TZ( p_hiredate, 'YYYY-MM-DD"T"HH24:MI:SS.ff3"Z"' ),
            p_job_id,
            p_sal,
            p_comm_pct,
            p_mgr_id,
            p_department_id
         );
      --
     COMMIT WORK;
     --
     get_employee_details(
                            p_emp_id   => p_emp_id,
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
         FROM   employees;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain a specific employee's details
   --
   PROCEDURE get_employee_details(
                                      p_emp_id   IN      employees.employee_id%TYPE,
                                      p_details  IN OUT  empl_details_refcur_t
                                   )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     employees
         WHERE    employee_id = p_emp_id;
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific employee's salary
   --
   PROCEDURE update_emp_salary(
                                    p_emp_id  IN employees.employee_id%TYPE,
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
      UPDATE   employees
      SET      salary      = p_sal
      WHERE    employee_id = p_emp_id;
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
                                 p_emp_id          IN  employees.employee_id%TYPE,
                                 p_department_id   IN  employees.department_id%TYPE
                             )
   IS
   BEGIN
      --
      UPDATE   employees
      SET      department_id = p_department_id
      WHERE    employee_id   = p_emp_id;
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
                          p_emp_id  IN employees.employee_id%TYPE
                       )
   IS
   BEGIN
      --
      DELETE employees
      WHERE  employee_id = p_emp_id;
      --
      COMMIT WORK;
      --
   END;
   --
   --===========================================================
   --
   -- department_id
   --
   -----------------------------------------------------------------------------------
   --
   -- create a department
   --
   PROCEDURE add_dept(
                           p_department_id    IN      NUMBER,
                           p_dname            IN      VARCHAR2,
                           p_location_id      IN      NUMBER,
                           p_mgr_id           IN      NUMBER,
                           p_details          IN OUT  hr_child.dept_details_refcur_t
                     )
   IS
   BEGIN
      --
      INSERT INTO departments
         (
             department_id,
             department_name,
             manager_id,
             location_id
          )
         VALUES
         (
            p_department_id,
            p_dname,
            p_mgr_id,
            p_location_id
         );
      --
     COMMIT WORK;
     --
     get_dept_details(
                            p_department_id  => p_department_id,
                            p_details        => p_details
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
         FROM     departments;
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read details on a specified department_id
   --
   PROCEDURE get_dept_details(
                                p_department_id    IN      departments.department_id%TYPE,
                                p_details          IN OUT  hr_child.dept_details_refcur_t
                             )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     departments
         WHERE    department_id = p_department_id;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's name
   --
   PROCEDURE update_dept_name(
                                p_department_id  IN departments.department_id%TYPE,
                                p_name           IN VARCHAR2
                             )
   IS
   BEGIN
      --
      --
      UPDATE   departments
      SET      department_name = p_name
      WHERE    department_id   = p_department_id;
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
                                p_department_id    IN departments.department_id%TYPE,
                                p_location_id      IN NUMBER
                             )
   IS
   BEGIN
      --
      --
      UPDATE   departments
      SET      location_id    = p_location_id
      WHERE    department_id  = p_department_id;
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
                           p_department_id  IN departments.department_id%TYPE
                        )
   IS
   BEGIN
      --
      DELETE departments
      WHERE  department_id = p_department_id;
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
      DELETE departments;
      DELETE employees;
      COMMIT;
      --
      --=========================================================
      --
      --  create employees data
      --
      DECLARE
         v_cursor SYS_REFCURSOR;
      BEGIN
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 100         Steven	            King			      SKING		     515.123.4567	        17-JUN-87    AD_PRES	   24000			                         90
         create_emp(
                        p_emp_id          => 100,                          --     NUMBER,
                        p_first_name      => 'Steven',                     --     VARCHAR2,
                        p_last_name       => 'King',                       --     VARCHAR2,
                        p_email           => 'SKING',                      --     VARCHAR2,
                        p_phone_number    => '515.123.4567',               --     VARCHAR2,
                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'AD_PRES',                    --     VARCHAR2,
                        p_sal             => 24000,                        --     NUMBER,
                        p_comm_pct        => NULL,                         --     NUMBER,
                        p_mgr_id          => NULL,                         --     NUMBER,
                        p_department_id   =>  90,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 101         Neena		            Kochhar		      NKOCHHAR		  515.123.4568	        21-SEP-89    AD_VP	      17000			            100	       90
         create_emp(
                        p_emp_id          => 101,                          --     NUMBER,
                        p_first_name      => 'Neena',                      --     VARCHAR2,
                        p_last_name       => 'Kochhar',                    --     VARCHAR2,
                        p_email           => 'NKOCHHAR',                   --     VARCHAR2,
                        p_phone_number    => '515.123.4568',               --     VARCHAR2,
                        p_hiredate        => '1989-10-12T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'AD_VP',                      --     VARCHAR2,
                        p_sal             => 17000,                        --     NUMBER,
                        p_comm_pct        => NULL,                         --     NUMBER,
                        p_mgr_id          => 100,                          --     NUMBER,
                        p_department_id   =>  90,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 102         Lex 		            De Haan		      LDEHAAN		  515.123.4569	        13-JAN-93    AD_VP	      17000			            100	       90
         create_emp(
                        p_emp_id          => 102,                          --     NUMBER,
                        p_first_name      => 'Lex',                        --     VARCHAR2,
                        p_last_name       => 'De Haan',                    --     VARCHAR2,
                        p_email           => 'LDEHAAN',                    --     VARCHAR2,
                        p_phone_number    => '515.123.4569',               --     VARCHAR2,
                        p_hiredate        => '1993-01-13T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'AD_VP',                      --     VARCHAR2,
                        p_sal             => 17000,                        --     NUMBER,
                        p_comm_pct        => NULL,                         --     NUMBER,
                        p_mgr_id          => 100,                          --     NUMBER,
                        p_department_id   =>  90,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 103         Alexander            Hunold 		      AHUNOLD		  590.423.4567	        03-JAN-90    IT_PROG	    9000			            102	       60
         create_emp(
                        p_emp_id          => 103,                            --     NUMBER,
                        p_first_name      => 'Alexander',                    --     VARCHAR2,
                        p_last_name       => 'Hunold',                       --     VARCHAR2,
                        p_email           => 'AHUNOLD',                      --     VARCHAR2,
                        p_phone_number    => '590.423.4567',                 --     VARCHAR2,
                        p_hiredate        => '1990-01-03T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'IT_PROG',                      --     VARCHAR2,
                        p_sal             => 9000,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 102,                            --     NUMBER,
                        p_department_id   => 60,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 104         Bruce		            Ernst			      BERNST		  590.423.4568	        21-MAY-91    IT_PROG	    6000			            103	       60
         create_emp(
                        p_emp_id          => 104,                         --     NUMBER,
                        p_first_name      => 'Bruce',                     --     VARCHAR2,
                        p_last_name       => 'Ernst',                     --     VARCHAR2,
                        p_email           => 'BERNST',                    --     VARCHAR2,
                        p_phone_number    => '590.423.4568',              --     VARCHAR2,
                        p_hiredate        => '1991-05-21T00:00:00.000Z',  --     VARCHAR2,
                        p_job_id          => 'IT_PROG',                   --     VARCHAR2,
                        p_sal             => 6000,                        --     NUMBER,
                        p_comm_pct        => NULL,                        --     NUMBER,
                        p_mgr_id          => 103,                         --     NUMBER,
                        p_department_id   => 60,                          --     NUMBER,
                        p_details         => v_cursor
                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 105         David		            Austin 		      DAUSTIN		  590.423.4569	        25-JUN-97    IT_PROG	    4800			            103	       60
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 106         Valli		            Pataballa		   VPATABAL		  590.423.4560	        05-FEB-98    IT_PROG	    4800			            103	       60
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 107         Diana		            Lorentz		      DLORENTZ		  590.423.5567	        07-FEB-99    IT_PROG	    4200			            103	       60
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 108         Nancy		            Greenberg		   NGREENBE		  515.124.4569	        17-AUG-94    FI_MGR	   12000			            101	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 109         Daniel	            Faviet 		      DFAVIET		  515.124.4169	        16-AUG-94    FI_ACCOUNT   9000			            108	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 110         John		            Chen			      JCHEN		     515.124.4269	        28-SEP-97    FI_ACCOUNT   8200			            108	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 111         Ismael	            Sciarra		      ISCIARRA		  515.124.4369	        30-SEP-97    FI_ACCOUNT   7700			            108	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 112         Jose Manuel 	      Urman			      JMURMAN		  515.124.4469	        07-MAR-98    FI_ACCOUNT   7800			            108	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 113         Luis		            Popp			      LPOPP		     515.124.4567	        07-DEC-99    FI_ACCOUNT   6900			            108	      100
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 114         Den 		            Raphaely		      DRAPHEAL		  515.127.4561	        07-DEC-94    PU_MAN	   11000			            100	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 115         Alexander            Khoo			      AKHOO		     515.127.4562	        18-MAY-95    PU_CLERK	    3100			            114	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 116         Shelli	            Baida			      SBAIDA		  515.127.4563	        24-DEC-97    PU_CLERK	    2900			            114	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 117         Sigal		            Tobias 		      STOBIAS		  515.127.4564	        24-JUL-97    PU_CLERK	    2800			            114	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 118         Guy 		            Himuro 		      GHIMURO		  515.127.4565	        15-NOV-98    PU_CLERK	    2600			            114	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 119         Karen		            Colmenares		   KCOLMENA		  515.127.4566	        10-AUG-99    PU_CLERK	    2500			            114	       30
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 120         Matthew	            Weiss			      MWEISS		  650.123.1234	        18-JUL-96    ST_MAN	    8000			            100	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 121         Adam		            Fripp			      AFRIPP		  650.123.2234	        10-APR-97    ST_MAN	    8200			            100	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 122         Payam		            Kaufling		      PKAUFLIN		  650.123.3234	        01-MAY-95    ST_MAN	    7900			            100	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 123         Shanta	            Vollman		      SVOLLMAN		  650.123.4234	        10-OCT-97    ST_MAN	    6500			            100	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 124         Kevin		            Mourgos		      KMOURGOS		  650.123.5234	        16-NOV-99    ST_MAN	    5800			            100	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 125         Julia		            Nayer			      JNAYER		  650.124.1214	        16-JUL-97    ST_CLERK	    3200			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 126         Irene		            Mikkilineni		   IMIKKILI		  650.124.1224	        28-SEP-98    ST_CLERK	    2700			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 127         James		            Landry 		      JLANDRY		  650.124.1334	        14-JAN-99    ST_CLERK	    2400			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 128         Steven	            Markle 		      SMARKLE		  650.124.1434	        08-MAR-00    ST_CLERK	    2200			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 129         Laura		            Bissot 		      LBISSOT		  650.124.5234	        20-AUG-97    ST_CLERK	    3300			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 130         Mozhe		            Atkinson		      MATKINSO		  650.124.6234	        30-OCT-97    ST_CLERK	    2800			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 131         James		            Marlow 		      JAMRLOW		  650.124.7234	        16-FEB-97    ST_CLERK	    2500			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 132         TJ			            Olson			      TJOLSON		  650.124.8234	        10-APR-99    ST_CLERK	    2100			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 133         Jason		            Mallin 		      JMALLIN		  650.127.1934	        14-JUN-96    ST_CLERK	    3300			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 134         Michael	            Rogers 		      MROGERS		  650.127.1834	        26-AUG-98    ST_CLERK	    2900			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 135         Ki			            Gee			      KGEE 		     650.127.1734	        12-DEC-99    ST_CLERK	    2400			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 136         Hazel		            Philtanker		   HPHILTAN		  650.127.1634	        06-FEB-00    ST_CLERK	    2200			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 137         Renske	            Ladwig 		      RLADWIG		  650.121.1234	        14-JUL-95    ST_CLERK	    3600			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 138         Stephen	            Stiles 		      SSTILES		  650.121.2034	        26-OCT-97    ST_CLERK	    3200			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 139         John		            Seo			      JSEO 		     650.121.2019	        12-FEB-98    ST_CLERK	    2700			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 140         Joshua	            Patel			      JPATEL		  650.121.1834	        06-APR-98    ST_CLERK	    2500			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 141         Trenna	            Rajs			      TRAJS		     650.121.8009	        17-OCT-95    ST_CLERK	    3500			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 142         Curtis	            Davies 		      CDAVIES		  650.121.2994	        29-JAN-97    ST_CLERK	    3100			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 143         Randall	            Matos			      RMATOS		  650.121.2874	        15-MAR-98    ST_CLERK	    2600			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 144         Peter		            Vargas 		      PVARGAS		  650.121.2004	        09-JUL-98    ST_CLERK	    2500			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 145         John		            Russell		      JRUSSEL		  011.44.1344.429268   01-OCT-96    SA_MAN	   14000	      .4	         100	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 146         Karen		            Partners		      KPARTNER		  011.44.1344.467268   05-JAN-97    SA_MAN	   13500	      .3	         100	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 147         Alberto	            Errazuriz		   AERRAZUR		  011.44.1344.429278   10-MAR-97    SA_MAN	   12000	      .3	         100	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 148         Gerald	            Cambrault		   GCAMBRAU		  011.44.1344.619268   15-OCT-99    SA_MAN	   11000	      .3	         100	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 149         Eleni		            Zlotkey		      EZLOTKEY		  011.44.1344.429018   29-JAN-00    SA_MAN	   10500	      .2	         100	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 150         Peter		            Tucker 		      PTUCKER		  011.44.1344.129268   30-JAN-97    SA_REP	   10000	      .3	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 151         David		            Bernstein		   DBERNSTE		  011.44.1344.345268   24-MAR-97    SA_REP	    9500	     .25	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 152         Peter		            Hall			      PHALL		     011.44.1344.478968   20-AUG-97    SA_REP	    9000	     .25	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 153         Christopher          Olsen			      COLSEN		  011.44.1344.498718   30-MAR-98    SA_REP	    8000	      .2	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 154         Nanette		         Cambrault		   NCAMBRAU		  011.44.1344.987668   09-DEC-98    SA_REP	    7500	      .2	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 155         Oliver		         Tuvault		      OTUVAULT		  011.44.1344.486508   23-NOV-99    SA_REP	    7000	     .15	         145	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 156         Janette		         King			      JKING		     011.44.1345.429268   30-JAN-96    SA_REP	   10000	     .35	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 157         Patrick		         Sully			      PSULLY		  011.44.1345.929268   04-MAR-96    SA_REP	    9500	     .35	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 158         Allan		            McEwen 		      AMCEWEN		  011.44.1345.829268   01-AUG-96    SA_REP	    9000	     .35	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 159         Lindsey		         Smith			      LSMITH		  011.44.1345.729268   10-MAR-97    SA_REP	    8000	      .3	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 160         Louise		         Doran			      LDORAN		  011.44.1345.629268   15-DEC-97    SA_REP	    7500	      .3	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 161         Sarath		         Sewall 		      SSEWALL		  011.44.1345.529268   03-NOV-98    SA_REP	    7000	     .25	         146	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 162         Clara		            Vishney		      CVISHNEY		  011.44.1346.129268   11-NOV-97    SA_REP	   10500	     .25	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 163         Danielle		         Greene 		      DGREENE		  011.44.1346.229268   19-MAR-99    SA_REP	    9500	     .15	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 164         Mattea		         Marvins		      MMARVINS		  011.44.1346.329268   24-JAN-00    SA_REP	    7200	      .1	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 165         David		            Lee			      DLEE 		     011.44.1346.529268   23-FEB-00    SA_REP	    6800	      .1	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 166         Sundar		         Ande			      SANDE		     011.44.1346.629268   24-MAR-00    SA_REP	    6400	      .1	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 167         Amit		            Banda			      ABANDA		  011.44.1346.729268   21-APR-00    SA_REP	    6200	      .1	         147	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 168         Lisa		            Ozer			      LOZER		     011.44.1343.929268   11-MAR-97    SA_REP	   11500	     .25	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 169         Harrison		         Bloom			      HBLOOM		  011.44.1343.829268   23-MAR-98    SA_REP	   10000	      .2	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 170         Tayler		         Fox			      TFOX 		     011.44.1343.729268   24-JAN-98    SA_REP	    9600	      .2	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 171         William		         Smith			      WSMITH		  011.44.1343.629268   23-FEB-99    SA_REP	    7400	     .15	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 172         Elizabeth	         Bates			      EBATES		  011.44.1343.529268   24-MAR-99    SA_REP	    7300	     .15	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 173         Sundita		         Kumar			      SKUMAR		  011.44.1343.329268   21-APR-00    SA_REP	    6100	      .1	         148	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 174         Ellen		            Abel			      EABEL		     011.44.1644.429267   11-MAY-96    SA_REP	   11000	      .3	         149	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 175         Alyssa		         Hutton 		      AHUTTON		  011.44.1644.429266   19-MAR-97    SA_REP	    8800	     .25	         149	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 176         Jonathon		         Taylor 		      JTAYLOR		  011.44.1644.429265   24-MAR-98    SA_REP	    8600	      .2	         149	       80
         create_emp(
                        p_emp_id          => 176,                          --     NUMBER,
                        p_first_name      => 'Jonathon',                   --     VARCHAR2,
                        p_last_name       => 'Taylor',                     --     VARCHAR2,
                        p_email           => 'JTAYLOR',                    --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429265',         --     VARCHAR2,
                        p_hiredate        => '1998-03-24T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'SA_REP',                     --     VARCHAR2,
                        p_sal             => 8600,                         --     NUMBER,
                        p_comm_pct        => .2,                           --     NUMBER,
                        p_mgr_id          => 149,                          --     NUMBER,
                        p_department_id   => 80,                           --     NUMBER,
                        p_details         => v_cursor
                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 177         Jack		            Livingston		   JLIVINGS		  011.44.1644.429264   23-APR-98    SA_REP	    8400	      .2	         149	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 178         Kimberely	         Grant			      KGRANT		  011.44.1644.429263   24-MAY-99    SA_REP	    7000	     .15	         149
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 179         Charles		         Johnson		      CJOHNSON		  011.44.1644.429262   04-JAN-00    SA_REP	    6200	      .1	         149	       80
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 180         Winston		         Taylor 		      WTAYLOR		  650.507.9876	        24-JAN-98    SH_CLERK	    3200			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 181         Jean		            Fleaur 		      JFLEAUR		  650.507.9877	        23-FEB-98    SH_CLERK	    3100			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 182         Martha		         Sullivan		      MSULLIVA		  650.507.9878	        21-JUN-99    SH_CLERK	    2500			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 183         Girard		         Geoni			      GGEONI		  650.507.9879	        03-FEB-00    SH_CLERK	    2800			            120	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 184         Nandita		         Sarchand		      NSARCHAN		  650.509.1876	        27-JAN-96    SH_CLERK	    4200			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 185         Alexis		         Bull			      ABULL		     650.509.2876	        20-FEB-97    SH_CLERK	    4100			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 186         Julia		            Dellinger		   JDELLING		  650.509.3876	        24-JUN-98    SH_CLERK	    3400			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 187         Anthony		         Cabrio 		      ACABRIO		  650.509.4876	        07-FEB-99    SH_CLERK	    3000			            121	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 188         Kelly		            Chung			      KCHUNG		  650.505.1876	        14-JUN-97    SH_CLERK	    3800			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 189         Jennifer		         Dilly			      JDILLY		  650.505.2876	        13-AUG-97    SH_CLERK	    3600			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 190         Timothy		         Gates			      TGATES		  650.505.3876	        11-JUL-98    SH_CLERK	    2900			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 191         Randall		         Perkins		      RPERKINS		  650.505.4876	        19-DEC-99    SH_CLERK	    2500			            122	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 192         Sarah		            Bell			      SBELL		     650.501.1876	        04-FEB-96    SH_CLERK	    4000			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 193         Britney		         Everett		      BEVERETT		  650.501.2876	        03-MAR-97    SH_CLERK	    3900			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 194         Samuel		            McCain 		      SMCCAIN		  650.501.3876	        01-JUL-98    SH_CLERK	    3200			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 195         Vance		            Jones			      VJONES		  650.501.4876	        17-MAR-99    SH_CLERK	    2800			            123	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 196         Alana		            Walsh			      AWALSH		  650.507.9811	        24-APR-98    SH_CLERK	    3100			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 197         Kevin		            Feeney 		      KFEENEY		  650.507.9822	        23-MAY-98    SH_CLERK	    3000			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 198         Donald	            OConnell		      DOCONNEL		  650.507.9833	        21-JUN-99    SH_CLERK	    2600			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 199         Douglas	            Grant			      DGRANT		  650.507.9844	        13-JAN-00    SH_CLERK	    2600			            124	       50
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 200         Jennifer	            Whalen 		      JWHALEN		  515.123.4444	        17-SEP-87    AD_ASST	    4400			            101	       10
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 201         Michael	            Hartstein		   MHARTSTE		  515.123.5555	        17-FEB-96    MK_MAN	   13000			            100	       20
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 202         Pat 		            Fay			      PFAY 		     603.123.6666	        17-AUG-97    MK_REP	    6000			            201	       20
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 203         Susan		            Mavris 		      SMAVRIS		  515.123.7777	        07-JUN-94    HR_REP	    6500			            101	       40
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 204         Hermann	            Baer			      HBAER		     515.123.8888	        07-JUN-94    PR_REP	   10000			            101	       70
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 205         Shelley	            Higgins		      SHIGGINS		  515.123.8080	        07-JUN-94    AC_MGR	   12000			            101	      110
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 206         William	            Gietz			      WGIETZ		  515.123.8181	        07-JUN-94    AC_ACCOUNT   8300			            205	      110
--         create_emp(
--                        p_emp_id          => foo,                          --     NUMBER,
--                        p_first_name      => 'foo',                     --     VARCHAR2,
--                        p_last_name       => 'foo',                       --     VARCHAR2,
--                        p_email           => 'foo',                      --     VARCHAR2,
--                        p_phone_number    => 'foo',               --     VARCHAR2,
--                        p_hiredate        => '1987-06-17T00:00:00.000Z',   --     VARCHAR2,
--                        p_job_id          => 'foo',                    --     VARCHAR2,
--                        p_sal             => foo,                        --     NUMBER,
--                        p_comm_pct        => NULL,                         --     NUMBER,
--                        p_mgr_id          => NULL,                         --     NUMBER,
--                        p_department_id   => foo,                           --     NUMBER,
--                        p_details         => v_cursor
--                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- (7369, 'SMITH', 'CLERK', 7902,TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, NULL, 20);
--         create_emp(
--                        p_emp_id          => 7369,
--                        p_ename           => 'SMITH',
--                        p_job             => 'CLERK',
--                        p_mgr             => 7902,
--                        p_hiredate        => '1980-12-17T00:00:00.000Z',
--                        p_sal             => 800,
--                        p_comm            => NULL,
--                        p_department_id   => 20,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         --(7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30);
--         create_emp(
--                        p_emp_id          => 7499,
--                        p_ename           => 'ALLEN',
--                        p_job             => 'SALESMAN',
--                        p_mgr             => 7698,
--                        p_hiredate        => '1981-02-20T00:00:00.000Z',
--                        p_sal             => 1600,
--                        p_comm            => 300,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7521, 'WARD', 'SALESMAN', 7698, TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30);
--         create_emp(
--                        p_emp_id          => 7521,
--                        p_ename           => 'WARD',
--                        p_job             => 'SALESMAN',
--                        p_mgr             => 7698,
--                        p_hiredate        => '1981-02-22T00:00:00.000Z',
--                        p_sal             => 1250,
--                        p_comm            => 500,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7566, 'JONES', 'MANAGER', 7839,TO_DATE('2-APR-1981', 'DD-MON-YYYY'), 2975, NULL, 20);
--         create_emp(
--                        p_emp_id          => 7566,
--                        p_ename           => 'JONES',
--                        p_job             => 'MANAGER',
--                        p_mgr             => 7839,
--                        p_hiredate        => '1981-04-02T00:00:00.000Z',
--                        p_sal             => 2975,
--                        p_comm            => NULL,
--                        p_department_id   => 20,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7654, 'MARTIN', 'SALESMAN', 7698,TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
--         --
--         create_emp(
--                        p_emp_id          => 7654,
--                        p_ename           => 'MARTIN',
--                        p_job             => 'SALESMAN',
--                        p_mgr             => 7698,
--                        p_hiredate        => '1981-09-28T00:00:00.000Z',
--                        p_sal             => 1250,
--                        p_comm            => 1400,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7698, 'BLAKE', 'MANAGER', 7839,TO_DATE('1-MAY-1981', 'DD-MON-YYYY'), 2850, NULL, 30);
--         create_emp(
--                        p_emp_id          => 7698,
--                        p_ename           => 'BLAKE',
--                        p_job             => 'MANAGER',
--                        p_mgr             => 7839,
--                        p_hiredate        => '1981-05-01T00:00:00.000Z',
--                        p_sal             => 2850,
--                        p_comm            => NULL,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7782, 'CLARK', 'MANAGER', 7839,TO_DATE('9-JUN-1981', 'DD-MON-YYYY'), 2450, NULL, 10);
--         create_emp(
--                        p_emp_id          => 7782,
--                        p_ename           => 'CLARK',
--                        p_job             => 'MANAGER',
--                        p_mgr             => 7839,
--                        p_hiredate        => '1981-06-09T00:00:00.000Z',
--                        p_sal             => 2450,
--                        p_comm            => NULL,
--                        p_department_id   => 10,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7788, 'scott', 'ANALYST', 7566,TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
--         --
--         create_emp(
--                        p_emp_id          => 7788,
--                        p_ename           => 'SCOTT',
--                        p_job             => 'ANALYST',
--                        p_mgr             => 7566,
--                        p_hiredate        => '1982-12-09T00:00:00.000Z',
--                        p_sal             => 3000,
--                        p_comm            => NULL,
--                        p_department_id   => 20,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7839, 'KING', 'PRESIDENT', NULL,TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);
--         create_emp(
--                        p_emp_id          => 7839,
--                        p_ename           => 'KING',
--                        p_job             => 'PRESIDENT',
--                        p_mgr             => NULL,
--                        p_hiredate        => '1981-11-17T00:00:00.000Z',
--                        p_sal             => 5000,
--                        p_comm            => NULL,
--                        p_department_id   => 10,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7844, 'TURNER', 'SALESMAN', 7698,TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 1500, 0, 30);
--         create_emp(
--                        p_emp_id          => 7844,
--                        p_ename           => 'TURNER',
--                        p_job             => 'SALESMAN',
--                        p_mgr             => 7698,
--                        p_hiredate        => '1981-09-08T00:00:00.000Z',
--                        p_sal             => 1500,
--                        p_comm            => 0,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7876, 'ADAMS', 'CLERK', 7788,TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
--         create_emp(
--                        p_emp_id          => 7876,
--                        p_ename           => 'ADAMS',
--                        p_job             => 'CLERK',
--                        p_mgr             => 7788,
--                        p_hiredate        => '1983-01-12T00:00:00.000Z',
--                        p_sal             => 1100,
--                        p_comm            => NULL,
--                        p_department_id   => 20,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7900, 'JAMES', 'CLERK', 7698, TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 950, NULL, 30);
--         create_emp(
--                        p_emp_id          => 7900,
--                        p_ename           => 'JAMES',
--                        p_job             => 'CLERK',
--                        p_mgr             => 7698,
--                        p_hiredate        => '1981-12-03T00:00:00.000Z',
--                        p_sal             => 950,
--                        p_comm            => NULL,
--                        p_department_id   => 30,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7902, 'FORD', 'ANALYST', 7566,TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 3000, NULL, 20);
--         create_emp(
--                        p_emp_id          => 7902,
--                        p_ename           => 'FORD',
--                        p_job             => 'ANALYST',
--                        p_mgr             => 7566,
--                        p_hiredate        => '1981-12-03T00:00:00.000Z',
--                        p_sal             => 3000,
--                        p_comm            => NULL,
--                        p_department_id   => 20,
--                        p_details         => v_cursor
--                     );
--         --
--         -----------------------------------------------------------
--         --
--         -- (7934, 'MILLER', 'CLERK', 7782,TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);
--         create_emp(
--                        p_emp_id          => 7934,
--                        p_ename           => 'MILLER',
--                        p_job             => 'CLERK',
--                        p_mgr             => 7782,
--                        p_hiredate        => '1982-01-23T00:00:00.000Z',
--                        p_sal             => 1300,
--                        p_comm            => NULL,
--                        p_department_id   => 10,
--                        p_details         => v_cursor
--                     );
      END;
      --
      --=========================================================
      --
      --  create departments data
      --
      DECLARE
         v_cursor SYS_REFCURSOR;
      BEGIN
-- -------------  ------------------------------ ---------- -----------
-- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
-- -------------  ------------------------------ ---------- -----------
-- 	   10       Administration			             200        1700
         add_dept(
                     p_department_id   => 10,                 -- NUMBER,
                     p_dname           => 'Administration',   -- VARCHAR2,
                     p_location_id     => 200,                -- NUMBER,
                     p_mgr_id          => 1700,               -- NUMBER,
                     p_details         => v_cursor
                 );
-- 	   20       Marketing 			                201        1800
         add_dept(
                     p_department_id   => 20,           -- NUMBER,
                     p_dname           => 'Marketing',  -- VARCHAR2,
                     p_location_id     => 201,          -- NUMBER,
                     p_mgr_id          => 1800,         -- NUMBER,
                     p_details         => v_cursor
                 );
-- 	   30       Purchasing			                114        1700
         add_dept(
                     p_department_id   => 30,              -- NUMBER,
                     p_dname           => 'Purchasing',            -- VARCHAR2,
                     p_location_id     => 114,              -- NUMBER,
                     p_mgr_id          => 1700,              -- NUMBER,
                     p_details         => v_cursor
                 );
-- 	   40       Human Resources		             203        2400
         add_dept(
                     p_department_id   => 40,              -- NUMBER,
                     p_dname           => 'Human Resources',            -- VARCHAR2,
                     p_location_id     => 203,              -- NUMBER,
                     p_mgr_id          => 2400,              -- NUMBER,
                     p_details         => v_cursor
                 );
-- 	   50       Shipping				                121        1500
         add_dept(
                     p_department_id   => 50,                -- NUMBER,
                     p_dname           => 'Shipping',              -- VARCHAR2,
                     p_location_id     => 121,                -- NUMBER,
                     p_mgr_id          => 1500,                -- NUMBER,
                     p_details         => v_cursor
                 );
-- 	   60       IT				                      103        1400
         add_dept(
                     p_department_id   => 60,                -- NUMBER,
                     p_dname           => 'IT',              -- VARCHAR2,
                     p_location_id     => 103,                -- NUMBER,
                     p_mgr_id          => 1400,                -- NUMBER,
                     p_details         => v_cursor
                 );
---- 	   70       Public Relations		             204        2700
--         add_dept(
--                     p_department_id   => foo,                -- NUMBER,
--                     p_dname           => 'foo',              -- VARCHAR2,
--                     p_location_id     => foo,                -- NUMBER,
--                     p_mgr_id          => foo,                -- NUMBER,
--                     p_details         =>  v_cursor
--                 );
---- 	   80       Sales				                   145        2500
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                 );
---- 	   90       Executive 			                100        1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  100       Finance				                108        1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  110       Accounting			                205        1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  120       Treasury					            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  130       Corporate Tax			            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  140       Control And Credit	            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  150       Shareholder Services	            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  160       Benefits					            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  170       Manufacturing			            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  180       Construction			            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  190       Contracting				            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  200       Operations				            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  210       IT Support				            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  220       NOC					               1700
--         add_dept(
--                     p_department_id   => foo,                -- NUMBER,
--                     p_dname           => 'foo',              -- VARCHAR2,
--                     p_location_id     => foo,                -- NUMBER,
--                     p_mgr_id          => foo,                -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  230       IT Helpdesk				            1700
--         add_dept(
--                     p_department_id   => foo,              -- NUMBER,
--                     p_dname           => 'foo',            -- VARCHAR2,
--                     p_location_id     => foo,              -- NUMBER,
--                     p_mgr_id          => foo,              -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  240       Government Sales		            1700
--         add_dept(
--                     p_department_id   => foo,               -- NUMBER,
--                     p_dname           => 'foo',             -- VARCHAR2,
--                     p_location_id     => foo,               -- NUMBER,
--                     p_mgr_id          => foo,               -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  250       Retail Sales			            1700
--         add_dept(
--                     p_department_id   => foo,               -- NUMBER,
--                     p_dname           => 'foo',             -- VARCHAR2,
--                     p_location_id     => foo,               -- NUMBER,
--                     p_mgr_id          => foo,               -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  260       Recruiting				            1700
--         add_dept(
--                     p_department_id   => foo,               -- NUMBER,
--                     p_dname           => 'foo',             -- VARCHAR2,
--                     p_location_id     => foo,               -- NUMBER,
--                     p_mgr_id          => foo,               -- NUMBER,
--                     p_details         =>  v_cursor
--                  );
---- 	  270       Payroll					            1700
--         add_dept(
--                     p_department_id   => foo,                  -- NUMBER,
--                     p_dname           => 'foo',                -- VARCHAR2,
--                     p_location_id     => foo,                  -- NUMBER,
--                     p_mgr_id          => foo,                  -- NUMBER,
--                     p_details         =>  v_cursor
--         --
--         -- INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
--         --
--         add_dept(
--                     p_department_id    =>  10,
--                     p_dname     =>  'ACCOUNTING',
--                     p_location_id       =>  'NEW YORK',
--                     p_details   =>  v_cursor
--                 );
--         --
--         --  (20, 'RESEARCH', 'DALLAS');
--         --
--         add_dept(
--                     p_department_id    =>  20,
--                     p_dname     =>  'RESEARCH',
--                     p_location_id       =>  'DALLAS',
--                     p_details   =>  v_cursor
--                 );
--         --
--         -- (30, 'SALES', 'CHICAGO');
--         --
--         add_dept(
--                     p_department_id    =>  30,
--                     p_dname     =>  'SALES',
--                     p_location_id       =>  'CHICAGO',
--                     p_details   =>  v_cursor
--                 );
--         --
--         -- (40, 'OPERATIONS', 'BOSTON')
--         --
--         add_dept(
--                     p_department_id    =>  40,
--                     p_dname     =>  'OPERATIONS',
--                     p_location_id       =>  'BOSTON',
--                     p_details   =>  v_cursor
--                 );
--         --
      END;
   END;
   --
END;
/


