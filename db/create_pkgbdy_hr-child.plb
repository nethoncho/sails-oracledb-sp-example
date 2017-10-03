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
         IF p_sal <= 0
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
      SET      department_id = p_department_id,
               hire_date     = SYSDATE
      WHERE    employee_id   = p_emp_id;
      --
      COMMIT WORK;
      --
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         --
         -- The HR.JHIST_EMP_ID_ST_DATE_PK unique constraint requires an
         -- employee to always have a unique start date. This exception will
         -- be raised whenever you change an employee's department more
         -- than once in a given day.
         --
         RAISE daily_dept_change;
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
   --===========================================================
   --
   -- locations
   --
   -- CRUD procedures for the locations table
   --
   -----------------------------------------------------------------------------------
   --
   -- create a location
   --
   PROCEDURE create_loc(
                           p_loc_id             IN     NUMBER,
                           p_street_address     IN     VARCHAR2,
                           p_postal_code        IN     VARCHAR2,
                           p_city               IN     VARCHAR2,
                           p_state_province     IN     VARCHAR2,
                           p_country_id         IN     NUMBER,
                           p_details            IN OUT loc_details_refcur_t
                        )
   IS
   BEGIN
      NULL;
   END;
   -----------------------------------------------------------------------------------
   --
   -- obtain details for all locations
   --
   PROCEDURE get_all_loc_details(
                                   p_details IN OUT  loc_details_refcur_t
                                )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     locations;
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain a specific locations's details
   --
   PROCEDURE get_location_details(
                                      p_loc_id    IN      locations.location_id%TYPE,
                                      p_details   IN OUT  loc_details_refcur_t
                                   )
   IS
   BEGIN
      NULL;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific locations's city
   --
   PROCEDURE update_loc_city(
                                 p_loc_id  IN locations.location_id%TYPE,
                                 p_sal     IN NUMBER
                              )
   IS
   BEGIN
      NULL;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specific location
   --
   PROCEDURE delete_loc(
                          p_loc_id  IN locations.location_id%TYPE
                       )
   IS
   BEGIN
      NULL;
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
         WHEN ec_negative_salary     THEN retval := 'salary cannot be zero or negative';
         WHEN ec_value_too_large     THEN retval := 'value too large for this field';
         WHEN ec_text_too_long       THEN retval := 'text too long for this field';
         WHEN ec_daily_dept_change   THEN retval := 'Employees are limited to one department change per day';
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
   -- housekeeping.
   --
   -- housekeeping.  Reset the employee and department tables back to default data
   -- after playing around with the UI has made a mess of things.
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
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   20       Marketing 			                201        1800
         add_dept(
                     p_department_id   => 20,                 -- NUMBER,
                     p_dname           => 'Marketing',        -- VARCHAR2,
                     p_location_id     => 201,                -- NUMBER,
                     p_mgr_id          => 1800,               -- NUMBER,
                     p_details         => v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   30       Purchasing			                114        1700
         add_dept(
                     p_department_id   => 30,                  -- NUMBER,
                     p_dname           => 'Purchasing',        -- VARCHAR2,
                     p_location_id     => 114,                 -- NUMBER,
                     p_mgr_id          => 1700,                -- NUMBER,
                     p_details         => v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   40       Human Resources		             203        2400
         add_dept(
                     p_department_id   => 40,                  -- NUMBER,
                     p_dname           => 'Human Resources',   -- VARCHAR2,
                     p_location_id     => 203,                 -- NUMBER,
                     p_mgr_id          => 2400,                -- NUMBER,
                     p_details         => v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   50       Shipping				                121        1500
         add_dept(
                     p_department_id   => 50,                  -- NUMBER,
                     p_dname           => 'Shipping',          -- VARCHAR2,
                     p_location_id     => 121,                 -- NUMBER,
                     p_mgr_id          => 1500,                -- NUMBER,
                     p_details         => v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   60       IT				                      103        1400
         add_dept(
                     p_department_id   => 60,                  -- NUMBER,
                     p_dname           => 'IT',                -- VARCHAR2,
                     p_location_id     => 103,                 -- NUMBER,
                     p_mgr_id          => 1400,                -- NUMBER,
                     p_details         => v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         -- 	   70       Public Relations		             204        2700
         add_dept(
                     p_department_id   => 70,                  -- NUMBER,
                     p_dname           => 'Public Relations',  -- VARCHAR2,
                     p_mgr_id          => 204,                 -- NUMBER,
                     p_location_id     => 2700,                -- NUMBER,
                     p_details         =>  v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	   80       Sales				                   145        2500
         add_dept(
                     p_department_id   => 80,                  -- NUMBER,
                     p_dname           => 'Sales',             -- VARCHAR2,
                     p_mgr_id          => 145,                 -- NUMBER,
                     p_location_id     => 2500,                -- NUMBER,
                     p_details         =>  v_cursor
                 );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	   90       Executive 			                100        1700
         add_dept(
                     p_department_id   => 90,                  -- NUMBER,
                     p_dname           => 'Executive',         -- VARCHAR2,
                     p_mgr_id          => 100,                 -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  100       Finance				                108        1700
         add_dept(
                     p_department_id   => 100,                 -- NUMBER,
                     p_dname           => 'Finance',           -- VARCHAR2,
                     p_mgr_id          => 108,                 -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  110       Accounting			                205        1700
         add_dept(
                     p_department_id   => 110,                 -- NUMBER,
                     p_dname           => 'Accounting',        -- VARCHAR2,
                     p_mgr_id          => 205,                 -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  120       Treasury					            1700
         add_dept(
                     p_department_id   => 120,                 -- NUMBER,
                     p_dname           => 'Treasury',          -- VARCHAR2,
                     p_mgr_id          => NULL,                -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  130       Corporate Tax			            1700
         add_dept(
                     p_department_id   => 130,                 -- NUMBER,
                     p_dname           => 'Corporate Tax',     -- VARCHAR2,
                     p_mgr_id          => NULL,                -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  140       Control And Credit	            1700
         add_dept(
                     p_department_id   => 140,                 -- NUMBER,
                     p_dname           => 'Control And Credit',-- VARCHAR2,
                     p_mgr_id          => NULL,                -- NUMBER,
                     p_location_id     => 1700,                -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  150       Shareholder Services	            1700
         add_dept(
                     p_department_id   => 150,                       -- NUMBER,
                     p_dname           => 'Shareholder Services',    -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  160       Benefits					            1700
         add_dept(
                     p_department_id   => 160,                       -- NUMBER,
                     p_dname           => 'Benefits',                -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  170       Manufacturing			            1700
         add_dept(
                     p_department_id   => 170,                       -- NUMBER,
                     p_dname           => 'Manufacturing',           -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  180       Construction			            1700
         add_dept(
                     p_department_id   => 180,                       -- NUMBER,
                     p_dname           => 'Construction',            -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  190       Contracting				            1700
         add_dept(
                     p_department_id   => 190,                       -- NUMBER,
                     p_dname           => 'Contracting',             -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  200       Operations				            1700
         add_dept(
                     p_department_id   => 200,                       -- NUMBER,
                     p_dname           => 'Operations',              -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  210       IT Support				            1700
         add_dept(
                     p_department_id   => 210,                       -- NUMBER,
                     p_dname           => 'IT Support',              -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  220       NOC					               1700
         add_dept(
                     p_department_id   => 220,                       -- NUMBER,
                     p_dname           => 'NOC',                     -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  230       IT Helpdesk				            1700
         add_dept(
                     p_department_id   => 230,                       -- NUMBER,
                     p_dname           => 'IT Helpdesk',             -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  240       Government Sales		            1700
         add_dept(
                     p_department_id   => 240,                       -- NUMBER,
                     p_dname           => 'Government Sales',        -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  250       Retail Sales			            1700
         add_dept(
                     p_department_id   => 250,                       -- NUMBER,
                     p_dname           => 'Retail Sales',            -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  260       Recruiting				            1700
         add_dept(
                     p_department_id   => 260,                       -- NUMBER,
                     p_dname           => 'Recruiting',              -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         -- DEPARTMENT_ID  DEPARTMENT_NAME		            MANAGER_ID LOCATION_ID
         ---- 	  270       Payroll					            1700
         add_dept(
                     p_department_id   => 270,                       -- NUMBER,
                     p_dname           => 'Payroll',                 -- VARCHAR2,
                     p_mgr_id          => NULL,                      -- NUMBER,
                     p_location_id     => 1700,                      -- NUMBER,
                     p_details         =>  v_cursor
                  );
         --
      END; --  create departments data
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
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 105         David		            Austin 		      DAUSTIN		  590.423.4569	        25-JUN-97    IT_PROG	    4800			            103	       60
         create_emp(
                        p_emp_id          => 105,                         --     NUMBER,
                        p_first_name      => 'David',                     --     VARCHAR2,
                        p_last_name       => 'Austin',                    --     VARCHAR2,
                        p_email           => 'DAUSTIN',                   --     VARCHAR2,
                        p_phone_number    => '590.423.4569',              --     VARCHAR2,
                        p_hiredate        => '1997-06-25T00:00:00.000Z',  --     VARCHAR2,
                        p_job_id          => 'IT_PROG',                   --     VARCHAR2,
                        p_sal             => 4800,                        --     NUMBER,
                        p_comm_pct        => NULL,                        --     NUMBER,
                        p_mgr_id          => 103,                         --     NUMBER,
                        p_department_id   => 60,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 106         Valli		            Pataballa		   VPATABAL		  590.423.4560	        05-FEB-98    IT_PROG	    4800			            103	       60
         create_emp(
                        p_emp_id          => 106,                         --     NUMBER,
                        p_first_name      => 'Valli',                     --     VARCHAR2,
                        p_last_name       => 'Pataballa',                 --     VARCHAR2,
                        p_email           => 'VPATABAL',                  --     VARCHAR2,
                        p_phone_number    => '590.423.4560',              --     VARCHAR2,
                        p_hiredate        => '1998-02-05T00:00:00.000Z',  --     VARCHAR2,
                        p_job_id          => 'IT_PROG',                   --     VARCHAR2,
                        p_sal             => 4800,                        --     NUMBER,
                        p_comm_pct        => NULL,                        --     NUMBER,
                        p_mgr_id          => 103,                         --     NUMBER,
                        p_department_id   => 60,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 107         Diana		            Lorentz		      DLORENTZ		  590.423.5567	        07-FEB-99    IT_PROG	    4200			            103	       60
         create_emp(
                        p_emp_id          => 107,                               --     NUMBER,
                        p_first_name      => 'Diana',                           --     VARCHAR2,
                        p_last_name       => 'Lorentz',                         --     VARCHAR2,
                        p_email           => 'DLORENTZ',                        --     VARCHAR2,
                        p_phone_number    => '590.423.5567',                    --     VARCHAR2,
                        p_hiredate        => '1999-02-07T00:00:00.000Z',        --     VARCHAR2,
                        p_job_id          => 'IT_PROG',                         --     VARCHAR2,
                        p_sal             => 4200,                              --     NUMBER,
                        p_comm_pct        => NULL,                              --     NUMBER,
                        p_mgr_id          => 103,                               --     NUMBER,
                        p_department_id   => 60,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 108         Nancy		            Greenberg		   NGREENBE		  515.124.4569	        17-AUG-94    FI_MGR	   12000			            101	      100
         create_emp(
                        p_emp_id          => 108,                            --     NUMBER,
                        p_first_name      => 'Nancy',                        --     VARCHAR2,
                        p_last_name       => 'Greenberg',                    --     VARCHAR2,
                        p_email           => 'NGREENBE',                     --     VARCHAR2,
                        p_phone_number    => '515.124.4569',                 --     VARCHAR2,
                        p_hiredate        => '1994-08-17T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'FI_MGR',                       --     VARCHAR2,
                        p_sal             => 12000,                          --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 101,                            --     NUMBER,
                        p_department_id   => 100,                            --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 109         Daniel	            Faviet 		      DFAVIET		  515.124.4169	        16-AUG-94    FI_ACCOUNT   9000			            108	      100
         create_emp(
                        p_emp_id          => 109,                          --     NUMBER,
                        p_first_name      => 'Daniel',                     --     VARCHAR2,
                        p_last_name       => 'Faviet',                     --     VARCHAR2,
                        p_email           => 'DFAVIET',                    --     VARCHAR2,
                        p_phone_number    => '515.124.4169',               --     VARCHAR2,
                        p_hiredate        => '1994-08-16T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'FI_ACCOUNT',                 --     VARCHAR2,
                        p_sal             => 9000,                         --     NUMBER,
                        p_comm_pct        => NULL,                         --     NUMBER,
                        p_mgr_id          => 108,                          --     NUMBER,
                        p_department_id   => 100,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 110         John		            Chen			      JCHEN		     515.124.4269	        28-SEP-97    FI_ACCOUNT   8200			            108	      100
         create_emp(
                        p_emp_id          => 110,                            --     NUMBER,
                        p_first_name      => 'John',                         --     VARCHAR2,
                        p_last_name       => 'Chen',                         --     VARCHAR2,
                        p_email           => 'JCHEN',                        --     VARCHAR2,
                        p_phone_number    => '515.124.4269',                 --     VARCHAR2,
                        p_hiredate        => '1997-09-28T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'FI_ACCOUNT',                   --     VARCHAR2,
                        p_sal             => 8200,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 108,                            --     NUMBER,
                        p_department_id   => 100,                            --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 111         Ismael	            Sciarra		      ISCIARRA		  515.124.4369	        30-SEP-97    FI_ACCOUNT   7700			            108	      100
         create_emp(
                        p_emp_id          => 111,                            --     NUMBER,
                        p_first_name      => 'Ismael',                       --     VARCHAR2,
                        p_last_name       => 'Sciarra',                      --     VARCHAR2,
                        p_email           => 'ISCIARRA',                     --     VARCHAR2,
                        p_phone_number    => '515.124.4369',                 --     VARCHAR2,
                        p_hiredate        => '1997-09-30T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'FI_ACCOUNT',                   --     VARCHAR2,
                        p_sal             => 7700,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 108,                            --     NUMBER,
                        p_department_id   => 100,                            --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 112         Jose Manuel 	      Urman			      JMURMAN		  515.124.4469	        07-MAR-98    FI_ACCOUNT   7800			            108	      100
         create_emp(
                        p_emp_id          => 112,                                --     NUMBER,
                        p_first_name      => 'Jose Manuel',                      --     VARCHAR2,
                        p_last_name       => 'Urman',                            --     VARCHAR2,
                        p_email           => 'JMURMAN',                          --     VARCHAR2,
                        p_phone_number    => '515.124.4469',                     --     VARCHAR2,
                        p_hiredate        => '1998-03-07T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'FI_ACCOUNT',                       --     VARCHAR2,
                        p_sal             => 7800,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 108,                                --     NUMBER,
                        p_department_id   => 100,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 113         Luis		            Popp			      LPOPP		     515.124.4567	        07-DEC-99    FI_ACCOUNT   6900			            108	      100
         create_emp(
                        p_emp_id          => 113,                              --     NUMBER,
                        p_first_name      => 'Luis',                           --     VARCHAR2,
                        p_last_name       => 'Popp',                           --     VARCHAR2,
                        p_email           => 'LPOPP',                          --     VARCHAR2,
                        p_phone_number    => '515.124.4567',                   --     VARCHAR2,
                        p_hiredate        => '1999-12-07T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'FI_ACCOUNT',                     --     VARCHAR2,
                        p_sal             => 6900,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 108,                              --     NUMBER,
                        p_department_id   => 100,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 114         Den 		            Raphaely		      DRAPHEAL		  515.127.4561	        07-DEC-94    PU_MAN	   11000			            100	       30
         create_emp(
                        p_emp_id          => 114,                             --     NUMBER,
                        p_first_name      => 'Den',                           --     VARCHAR2,
                        p_last_name       => 'Raphaely',                      --     VARCHAR2,
                        p_email           => 'DRAPHEAL',                      --     VARCHAR2,
                        p_phone_number    => '515.127.4561',                  --     VARCHAR2,
                        p_hiredate        => '1994-12-07T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'PU_MAN',                        --     VARCHAR2,
                        p_sal             => 11000,                           --     NUMBER,
                        p_comm_pct        => NULL,                            --     NUMBER,
                        p_mgr_id          => 100,                             --     NUMBER,
                        p_department_id   => 30,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 115         Alexander            Khoo			      AKHOO		     515.127.4562	        18-MAY-95    PU_CLERK	    3100			            114	       30
         create_emp(
                        p_emp_id          => 115,                             --     NUMBER,
                        p_first_name      => 'Alexander',                     --     VARCHAR2,
                        p_last_name       => 'Khoo',                          --     VARCHAR2,
                        p_email           => 'AKHOO',                         --     VARCHAR2,
                        p_phone_number    => '515.127.4562',                  --     VARCHAR2,
                        p_hiredate        => '1995-05-18T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'PU_CLERK',                      --     VARCHAR2,
                        p_sal             => 3100,                            --     NUMBER,
                        p_comm_pct        => NULL,                            --     NUMBER,
                        p_mgr_id          => 114,                             --     NUMBER,
                        p_department_id   => 30,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 116         Shelli	            Baida			      SBAIDA		  515.127.4563	        24-DEC-97    PU_CLERK	    2900			            114	       30
         create_emp(
                        p_emp_id          => 116,                               --     NUMBER,
                        p_first_name      => 'Shelli',                          --     VARCHAR2,
                        p_last_name       => 'Baida',                           --     VARCHAR2,
                        p_email           => 'SBAIDA',                          --     VARCHAR2,
                        p_phone_number    => '515.127.4563',                    --     VARCHAR2,
                        p_hiredate        => '1997-12-24T00:00:00.000Z',        --     VARCHAR2,
                        p_job_id          => 'PU_CLERK',                        --     VARCHAR2,
                        p_sal             => 2900,                              --     NUMBER,
                        p_comm_pct        => NULL,                              --     NUMBER,
                        p_mgr_id          => 114,                               --     NUMBER,
                        p_department_id   => 30,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 117         Sigal		            Tobias 		      STOBIAS		  515.127.4564	        24-JUL-97    PU_CLERK	    2800			            114	       30
         create_emp(
                        p_emp_id          => 117,                           --     NUMBER,
                        p_first_name      => 'Sigal',                       --     VARCHAR2,
                        p_last_name       => 'Tobias',                      --     VARCHAR2,
                        p_email           => 'STOBIAS',                     --     VARCHAR2,
                        p_phone_number    => '515.127.4564',                --     VARCHAR2,
                        p_hiredate        => '1997-07-24T00:00:00.000Z',    --     VARCHAR2,
                        p_job_id          => 'PU_CLERK',                    --     VARCHAR2,
                        p_sal             => 2800,                          --     NUMBER,
                        p_comm_pct        => NULL,                          --     NUMBER,
                        p_mgr_id          => 114,                           --     NUMBER,
                        p_department_id   => 30,                            --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 118         Guy 		            Himuro 		      GHIMURO		  515.127.4565	        15-NOV-98    PU_CLERK	    2600			            114	       30
         create_emp(
                        p_emp_id          => 118,                                --     NUMBER,
                        p_first_name      => 'Guy',                              --     VARCHAR2,
                        p_last_name       => 'Himuro',                           --     VARCHAR2,
                        p_email           => 'GHIMURO',                          --     VARCHAR2,
                        p_phone_number    => '515.127.4565',                     --     VARCHAR2,
                        p_hiredate        => '1998-11-15T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'PU_CLERK',                         --     VARCHAR2,
                        p_sal             => 2600,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 114,                                --     NUMBER,
                        p_department_id   => 30,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 119         Karen		            Colmenares		   KCOLMENA		  515.127.4566	        10-AUG-99    PU_CLERK	    2500			            114	       30
         create_emp(
                        p_emp_id          => 119,                              --     NUMBER,
                        p_first_name      => 'Karen',                          --     VARCHAR2,
                        p_last_name       => 'Colmenares',                     --     VARCHAR2,
                        p_email           => 'KCOLMENA',                       --     VARCHAR2,
                        p_phone_number    => '515.127.4566',                   --     VARCHAR2,
                        p_hiredate        => '1999-08-10T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'PU_CLERK',                       --     VARCHAR2,
                        p_sal             => 2500,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 114,                              --     NUMBER,
                        p_department_id   => 30,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 120         Matthew	            Weiss			      MWEISS		  650.123.1234	        18-JUL-96    ST_MAN	    8000			            100	       50
         create_emp(
                        p_emp_id          => 120,                               --     NUMBER,
                        p_first_name      => 'Matthew',                         --     VARCHAR2,
                        p_last_name       => 'Weiss',                           --     VARCHAR2,
                        p_email           => 'MWEISS',                          --     VARCHAR2,
                        p_phone_number    => '650.123.1234',                    --     VARCHAR2,
                        p_hiredate        => '1996-07-18T00:00:00.000Z',        --     VARCHAR2,
                        p_job_id          => 'ST_MAN',                          --     VARCHAR2,
                        p_sal             => 8000,                              --     NUMBER,
                        p_comm_pct        => NULL,                              --     NUMBER,
                        p_mgr_id          => 100,                               --     NUMBER,
                        p_department_id   => 50,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 121         Adam		            Fripp			      AFRIPP		  650.123.2234	        10-APR-97    ST_MAN	    8200			            100	       50
         create_emp(
                        p_emp_id          => 121,                                --     NUMBER,
                        p_first_name      => 'Adam',                             --     VARCHAR2,
                        p_last_name       => 'Fripp',                            --     VARCHAR2,
                        p_email           => 'AFRIPP',                           --     VARCHAR2,
                        p_phone_number    => '650.123.2234',                     --     VARCHAR2,
                        p_hiredate        => '1997-04-10T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_MAN',                           --     VARCHAR2,
                        p_sal             => 8200,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 100,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 122         Payam		            Kaufling		      PKAUFLIN		  650.123.3234	        01-MAY-95    ST_MAN	    7900			            100	       50
         create_emp(
                        p_emp_id          => 122,                              --     NUMBER,
                        p_first_name      => 'Payam',                          --     VARCHAR2,
                        p_last_name       => 'Kaufling',                       --     VARCHAR2,
                        p_email           => 'PKAUFLIN',                       --     VARCHAR2,
                        p_phone_number    => '650.123.3234',                   --     VARCHAR2,
                        p_hiredate        => '1995-04-01T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_MAN',                         --     VARCHAR2,
                        p_sal             => 7900,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 100,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 123         Shanta	            Vollman		      SVOLLMAN		  650.123.4234	        10-OCT-97    ST_MAN	    6500			            100	       50
         create_emp(
                        p_emp_id          => 123,                              --     NUMBER,
                        p_first_name      => 'Shanta',                         --     VARCHAR2,
                        p_last_name       => 'Vollman',                        --     VARCHAR2,
                        p_email           => 'SVOLLMAN',                       --     VARCHAR2,
                        p_phone_number    => '650.123.4234',                   --     VARCHAR2,
                        p_hiredate        => '1997-10-10T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_MAN',                         --     VARCHAR2,
                        p_sal             => 6500,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 100,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 124         Kevin		            Mourgos		      KMOURGOS		  650.123.5234	        16-NOV-99    ST_MAN	    5800			            100	       50
         create_emp(
                        p_emp_id          => 124,                              --     NUMBER,
                        p_first_name      => 'Kevin',                          --     VARCHAR2,
                        p_last_name       => 'Mourgos',                        --     VARCHAR2,
                        p_email           => 'KMOURGOS',                       --     VARCHAR2,
                        p_phone_number    => '650.123.5234',                   --     VARCHAR2,
                        p_hiredate        => '1999-11-16T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_MAN',                         --     VARCHAR2,
                        p_sal             => 5800,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 100,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 125         Julia		            Nayer			      JNAYER		  650.124.1214	        16-JUL-97    ST_CLERK	    3200			            120	       50
         create_emp(
                        p_emp_id          => 125,                              --     NUMBER,
                        p_first_name      => 'Julia',                          --     VARCHAR2,
                        p_last_name       => 'Nayer',                          --     VARCHAR2,
                        p_email           => 'JNAYER',                         --     VARCHAR2,
                        p_phone_number    => '650.124.1214',                   --     VARCHAR2,
                        p_hiredate        => '1997-07-16T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 3200,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 120,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 126         Irene		            Mikkilineni		   IMIKKILI		  650.124.1224	        28-SEP-98    ST_CLERK	    2700			            120	       50
         create_emp(
                        p_emp_id          => 126,                                  --     NUMBER,
                        p_first_name      => 'Irene',                              --     VARCHAR2,
                        p_last_name       => 'Mikkilineni',                        --     VARCHAR2,
                        p_email           => 'IMIKKILI',                           --     VARCHAR2,
                        p_phone_number    => '650.124.1224',                       --     VARCHAR2,
                        p_hiredate        => '1998-09-28T00:00:00.000Z',           --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                           --     VARCHAR2,
                        p_sal             => 2700,                                 --     NUMBER,
                        p_comm_pct        => NULL,                                 --     NUMBER,
                        p_mgr_id          => 120,                                  --     NUMBER,
                        p_department_id   => 50,                                   --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 127         James		            Landry 		      JLANDRY		  650.124.1334	        14-JAN-99    ST_CLERK	    2400			            120	       50
         create_emp(
                        p_emp_id          => 127,                              --     NUMBER,
                        p_first_name      => 'James',                          --     VARCHAR2,
                        p_last_name       => 'Landry',                         --     VARCHAR2,
                        p_email           => 'JLANDRY',                        --     VARCHAR2,
                        p_phone_number    => '650.124.1334',                   --     VARCHAR2,
                        p_hiredate        => '1999-01-14T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 2400,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 120,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 128         Steven	            Markle 		      SMARKLE		  650.124.1434	        08-MAR-00    ST_CLERK	    2200			            120	       50
         create_emp(
                        p_emp_id          => 128,                                --     NUMBER,
                        p_first_name      => 'Steven',                           --     VARCHAR2,
                        p_last_name       => 'Markle',                           --     VARCHAR2,
                        p_email           => 'SMARKLE',                          --     VARCHAR2,
                        p_phone_number    => '650.124.1434',                     --     VARCHAR2,
                        p_hiredate        => '2000-03-08T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2200,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 120,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 129         Laura		            Bissot 		      LBISSOT		  650.124.5234	        20-AUG-97    ST_CLERK	    3300			            121	       50
         create_emp(
                        p_emp_id          => 129,                              --     NUMBER,
                        p_first_name      => 'Laura',                          --     VARCHAR2,
                        p_last_name       => 'Bissot',                         --     VARCHAR2,
                        p_email           => 'LBISSOT',                        --     VARCHAR2,
                        p_phone_number    => '650.124.5234',                   --     VARCHAR2,
                        p_hiredate        => '2000-08-20T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 3300,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 121,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 130         Mozhe		            Atkinson		      MATKINSO		  650.124.6234	        30-OCT-97    ST_CLERK	    2800			            121	       50
         create_emp(
                        p_emp_id          => 130,                                --     NUMBER,
                        p_first_name      => 'Mozhe',                            --     VARCHAR2,
                        p_last_name       => 'Atkinson',                         --     VARCHAR2,
                        p_email           => 'MATKINSO',                         --     VARCHAR2,
                        p_phone_number    => '650.124.6234',                     --     VARCHAR2,
                        p_hiredate        => '1997-10-30T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2800,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 131         James		            Marlow 		      JAMRLOW		  650.124.7234	        16-FEB-97    ST_CLERK	    2500			            121	       50
         create_emp(
                        p_emp_id          => 131,                                --     NUMBER,
                        p_first_name      => 'James',                            --     VARCHAR2,
                        p_last_name       => 'Marlow',                           --     VARCHAR2,
                        p_email           => 'JAMRLOW',                          --     VARCHAR2,
                        p_phone_number    => '650.124.7234',                     --     VARCHAR2,
                        p_hiredate        => '1997-02-16T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2500,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 132         TJ			            Olson			      TJOLSON		  650.124.8234	        10-APR-99    ST_CLERK	    2100			            121	       50
         create_emp(
                        p_emp_id          => 132,                                --     NUMBER,
                        p_first_name      => 'TJ',                               --     VARCHAR2,
                        p_last_name       => 'Olson',                            --     VARCHAR2,
                        p_email           => 'TJOLSON',                          --     VARCHAR2,
                        p_phone_number    => '650.124.8234',                     --     VARCHAR2,
                        p_hiredate        => '1999-04-10T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2100,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 133         Jason		            Mallin 		      JMALLIN		  650.127.1934	        14-JUN-96    ST_CLERK	    3300			            122	       50
         create_emp(
                        p_emp_id          => 133,                             --     NUMBER,
                        p_first_name      => 'Jason',                         --     VARCHAR2,
                        p_last_name       => 'Mallin',                        --     VARCHAR2,
                        p_email           => 'JMALLIN',                       --     VARCHAR2,
                        p_phone_number    => '650.127.1934',                  --     VARCHAR2,
                        p_hiredate        => '1996-06-14T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                      --     VARCHAR2,
                        p_sal             => 3300,                            --     NUMBER,
                        p_comm_pct        => NULL,                            --     NUMBER,
                        p_mgr_id          => 122,                             --     NUMBER,
                        p_department_id   => 50,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 134         Michael	            Rogers 		      MROGERS		  650.127.1834	        26-AUG-98    ST_CLERK	    2900			            122	       50
         create_emp(
                        p_emp_id          => 134,                              --     NUMBER,
                        p_first_name      => 'Michael',                        --     VARCHAR2,
                        p_last_name       => 'Rogers',                         --     VARCHAR2,
                        p_email           => 'MROGERS',                        --     VARCHAR2,
                        p_phone_number    => '650.127.1834',                   --     VARCHAR2,
                        p_hiredate        => '1998-08-26T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 2900,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 122,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 135         Ki			            Gee			      KGEE 		     650.127.1734	        12-DEC-99    ST_CLERK	    2400			            122	       50
         create_emp(
                        p_emp_id          => 135,                            --     NUMBER,
                        p_first_name      => 'Ki',                           --     VARCHAR2,
                        p_last_name       => 'Gee',                          --     VARCHAR2,
                        p_email           => 'KGEE',                         --     VARCHAR2,
                        p_phone_number    => '650.127.1734',                 --     VARCHAR2,
                        p_hiredate        => '1999-12-12T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                     --     VARCHAR2,
                        p_sal             => 2400,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 122,                            --     NUMBER,
                        p_department_id   => 50,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 136         Hazel		            Philtanker		   HPHILTAN		  650.127.1634	        06-FEB-00    ST_CLERK	    2200			            122	       50
         create_emp(
                        p_emp_id          => 136,                              --     NUMBER,
                        p_first_name      => 'Hazel',                          --     VARCHAR2,
                        p_last_name       => 'Philtanker',                     --     VARCHAR2,
                        p_email           => 'HPHILTAN',                       --     VARCHAR2,
                        p_phone_number    => '650.127.1634',                   --     VARCHAR2,
                        p_hiredate        => '2000-02-06T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 2200,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 122,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 137         Renske	            Ladwig 		      RLADWIG		  650.121.1234	        14-JUL-95    ST_CLERK	    3600			            123	       50
         create_emp(
                        p_emp_id          => 137,                              --     NUMBER,
                        p_first_name      => 'Renske',                         --     VARCHAR2,
                        p_last_name       => 'Ladwig',                         --     VARCHAR2,
                        p_email           => 'RLADWIG',                        --     VARCHAR2,
                        p_phone_number    => '650.121.1234',                   --     VARCHAR2,
                        p_hiredate        => '1995-07-14T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 3600,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 123,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 138         Stephen	            Stiles 		      SSTILES		  650.121.2034	        26-OCT-97    ST_CLERK	    3200			            123	       50
         create_emp(
                        p_emp_id          => 138,                              --     NUMBER,
                        p_first_name      => 'Stephen',                        --     VARCHAR2,
                        p_last_name       => 'Stiles',                         --     VARCHAR2,
                        p_email           => 'SSTILES',                        --     VARCHAR2,
                        p_phone_number    => '650.121.2034',                   --     VARCHAR2,
                        p_hiredate        => '1997-10-26T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                       --     VARCHAR2,
                        p_sal             => 3200,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 123,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 139         John		            Seo			      JSEO 		     650.121.2019	        12-FEB-98    ST_CLERK	    2700			            123	       50
         create_emp(
                        p_emp_id          => 139,                                --     NUMBER,
                        p_first_name      => 'John',                             --     VARCHAR2,
                        p_last_name       => 'Seo',                              --     VARCHAR2,
                        p_email           => 'JSEO',                             --     VARCHAR2,
                        p_phone_number    => '650.121.2019',                     --     VARCHAR2,
                        p_hiredate        => '1998-02-12T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2700,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 140         Joshua	            Patel			      JPATEL		  650.121.1834	        06-APR-98    ST_CLERK	    2500			            123	       50
         create_emp(
                        p_emp_id          => 140,                                --     NUMBER,
                        p_first_name      => 'Joshua',                           --     VARCHAR2,
                        p_last_name       => 'Patel',                            --     VARCHAR2,
                        p_email           => 'JPATEL',                           --     VARCHAR2,
                        p_phone_number    => '650.121.1834',                     --     VARCHAR2,
                        p_hiredate        => '1998-04-06T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                         --     VARCHAR2,
                        p_sal             => 2500,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 141         Trenna	            Rajs			      TRAJS		     650.121.8009	        17-OCT-95    ST_CLERK	    3500			            124	       50
         create_emp(
                        p_emp_id          => 141,                        --     NUMBER,
                        p_first_name      => 'Trenna',                   --     VARCHAR2,
                        p_last_name       => 'Rajs',                     --     VARCHAR2,
                        p_email           => 'TRAJS',                    --     VARCHAR2,
                        p_phone_number    => '650.121.8009',             --     VARCHAR2,
                        p_hiredate        => '1995-06-17T00:00:00.000Z', --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                 --     VARCHAR2,
                        p_sal             => 3500,                       --     NUMBER,
                        p_comm_pct        => NULL,                       --     NUMBER,
                        p_mgr_id          => 124,                        --     NUMBER,
                        p_department_id   => 50,                         --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 142         Curtis	            Davies 		      CDAVIES		  650.121.2994	        29-JAN-97    ST_CLERK	    3100			            124	       50
         create_emp(
                        p_emp_id          => 142,                             --     NUMBER,
                        p_first_name      => 'Curtis',                        --     VARCHAR2,
                        p_last_name       => 'Davies',                        --     VARCHAR2,
                        p_email           => 'CDAVIES',                       --     VARCHAR2,
                        p_phone_number    => '650.121.2994',                  --     VARCHAR2,
                        p_hiredate        => '1997-10-29T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                      --     VARCHAR2,
                        p_sal             => 3100,                            --     NUMBER,
                        p_comm_pct        => NULL,                            --     NUMBER,
                        p_mgr_id          => 124,                             --     NUMBER,
                        p_department_id   => 50,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 143         Randall	            Matos			      RMATOS		  650.121.2874	        15-MAR-98    ST_CLERK	    2600			            124	       50
         create_emp(
                        p_emp_id          => 143,                            --     NUMBER,
                        p_first_name      => 'Randall',                      --     VARCHAR2,
                        p_last_name       => 'Matos',                        --     VARCHAR2,
                        p_email           => 'RMATOS',                       --     VARCHAR2,
                        p_phone_number    => '650.121.2874',                 --     VARCHAR2,
                        p_hiredate        => '1998-03-15T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                     --     VARCHAR2,
                        p_sal             => 2600,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 124,                            --     NUMBER,
                        p_department_id   => 50,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 144         Peter		            Vargas 		      PVARGAS		  650.121.2004	        09-JUL-98    ST_CLERK	    2500			            124	       50
         create_emp(
                        p_emp_id          => 144,                            --     NUMBER,
                        p_first_name      => 'Peter',                        --     VARCHAR2,
                        p_last_name       => 'Vargas',                       --     VARCHAR2,
                        p_email           => 'PVARGAS',                      --     VARCHAR2,
                        p_phone_number    => '650.121.2004',                 --     VARCHAR2,
                        p_hiredate        => '1998-07-09T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'ST_CLERK',                     --     VARCHAR2,
                        p_sal             => 2500,                           --     NUMBER,
                        p_comm_pct        => NULL,                           --     NUMBER,
                        p_mgr_id          => 124,                            --     NUMBER,
                        p_department_id   => 50,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 145         John		            Russell		      JRUSSEL		  011.44.1344.429268   01-OCT-96    SA_MAN	   14000	      .4	         100	       80
         create_emp(
                        p_emp_id          => 145,                                --     NUMBER,
                        p_first_name      => 'John',                             --     VARCHAR2,
                        p_last_name       => 'Russell',                          --     VARCHAR2,
                        p_email           => 'JRUSSEL',                          --     VARCHAR2,
                        p_phone_number    => '011.44.1344.429268',               --     VARCHAR2,
                        p_hiredate        => '1996-10-01T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_MAN',                           --     VARCHAR2,
                        p_sal             => 14000,                              --     NUMBER,
                        p_comm_pct        => .4,                                 --     NUMBER,
                        p_mgr_id          => 100,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 146         Karen		            Partners		      KPARTNER		  011.44.1344.467268   05-JAN-97    SA_MAN	   13500	      .3	         100	       80
         create_emp(
                        p_emp_id          => 146,                            --     NUMBER,
                        p_first_name      => 'Karen',                        --     VARCHAR2,
                        p_last_name       => 'Partners',                     --     VARCHAR2,
                        p_email           => 'KPARTNER',                     --     VARCHAR2,
                        p_phone_number    => '011.44.1344.467268',           --     VARCHAR2,
                        p_hiredate        => '1997-01-05T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'SA_MAN',                       --     VARCHAR2,
                        p_sal             => 13500,                          --     NUMBER,
                        p_comm_pct        => .3,                             --     NUMBER,
                        p_mgr_id          => 100,                            --     NUMBER,
                        p_department_id   => 80,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 147         Alberto	            Errazuriz		   AERRAZUR		  011.44.1344.429278   10-MAR-97    SA_MAN	   12000	      .3	         100	       80
         create_emp(
                        p_emp_id          => 147,                            --     NUMBER,
                        p_first_name      => 'Alberto',                      --     VARCHAR2,
                        p_last_name       => 'Errazuriz',                    --     VARCHAR2,
                        p_email           => 'AERRAZUR',                     --     VARCHAR2,
                        p_phone_number    => '011.44.1344.429278',           --     VARCHAR2,
                        p_hiredate        => '1997-03-10T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'SA_MAN',                       --     VARCHAR2,
                        p_sal             => 12000,                          --     NUMBER,
                        p_comm_pct        => .3,                             --     NUMBER,
                        p_mgr_id          => 100,                            --     NUMBER,
                        p_department_id   => 80,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 148         Gerald	            Cambrault		   GCAMBRAU		  011.44.1344.619268   15-OCT-99    SA_MAN	   11000	      .3	         100	       80
         create_emp(
                        p_emp_id          => 148,                                --     NUMBER,
                        p_first_name      => 'Gerald',                           --     VARCHAR2,
                        p_last_name       => 'Cambrault',                        --     VARCHAR2,
                        p_email           => 'GCAMBRAU',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1344.619268',               --     VARCHAR2,
                        p_hiredate        => '1999-10-15T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_MAN',                           --     VARCHAR2,
                        p_sal             => 11000,                              --     NUMBER,
                        p_comm_pct        => .3,                                 --     NUMBER,
                        p_mgr_id          => 100,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 149         Eleni		            Zlotkey		      EZLOTKEY		  011.44.1344.429018   29-JAN-00    SA_MAN	   10500	      .2	         100	       80
         create_emp(
                        p_emp_id          => 149,                                --     NUMBER,
                        p_first_name      => 'Eleni',                            --     VARCHAR2,
                        p_last_name       => 'Zlotkey',                          --     VARCHAR2,
                        p_email           => 'EZLOTKEY',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1344.429018',               --     VARCHAR2,
                        p_hiredate        => '2000-01-29T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_MAN',                           --     VARCHAR2,
                        p_sal             => 10500,                              --     NUMBER,
                        p_comm_pct        => .2,                                 --     NUMBER,
                        p_mgr_id          => NULL,                               --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 150         Peter		            Tucker 		      PTUCKER		  011.44.1344.129268   30-JAN-97    SA_REP	   10000	      .3	         145	       80
         create_emp(
                        p_emp_id          => 150,                              --     NUMBER,
                        p_first_name      => 'Peter',                          --     VARCHAR2,
                        p_last_name       => 'Tucker',                         --     VARCHAR2,
                        p_email           => 'PTUCKER',                        --     VARCHAR2,
                        p_phone_number    => '011.44.1344.129268',             --     VARCHAR2,
                        p_hiredate        => '1997-01-30T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'SA_REP',                         --     VARCHAR2,
                        p_sal             => 10000,                            --     NUMBER,
                        p_comm_pct        => .3,                               --     NUMBER,
                        p_mgr_id          => 145,                              --     NUMBER,
                        p_department_id   => 80,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 151         David		            Bernstein		   DBERNSTE		  011.44.1344.345268   24-MAR-97    SA_REP	    9500	     .25	         145	       80
         create_emp(
                        p_emp_id          => 151,                               --     NUMBER,
                        p_first_name      => 'David',                           --     VARCHAR2,
                        p_last_name       => 'Bernstein',                       --     VARCHAR2,
                        p_email           => 'DBERNSTE',                        --     VARCHAR2,
                        p_phone_number    => '011.44.1344.345268',              --     VARCHAR2,
                        p_hiredate        => '1997-03-24T00:00:00.000Z',        --     VARCHAR2,
                        p_job_id          => 'SA_REP',                          --     VARCHAR2,
                        p_sal             => 9500,                              --     NUMBER,
                        p_comm_pct        => .25,                               --     NUMBER,
                        p_mgr_id          => 145,                               --     NUMBER,
                        p_department_id   => 80,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 152         Peter		            Hall			      PHALL		     011.44.1344.478968   20-AUG-97    SA_REP	    9000	     .25	         145	       80
         create_emp(
                        p_emp_id          => 152,                               --     NUMBER,
                        p_first_name      => 'Peter',                           --     VARCHAR2,
                        p_last_name       => 'Hall',                            --     VARCHAR2,
                        p_email           => 'PHALL',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1344.478968',              --     VARCHAR2,
                        p_hiredate        => '1997-08-20T00:00:00.000Z',        --     VARCHAR2,
                        p_job_id          => 'SA_REP',                          --     VARCHAR2,
                        p_sal             => 9000,                              --     NUMBER,
                        p_comm_pct        => .25,                               --     NUMBER,
                        p_mgr_id          => 145,                               --     NUMBER,
                        p_department_id   => 80,                                --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 153         Christopher          Olsen			      COLSEN		  011.44.1344.498718   30-MAR-98    SA_REP	    8000	      .2	         145	       80
         create_emp(
                        p_emp_id          => 153,                                --     NUMBER,
                        p_first_name      => 'Christopher',                      --     VARCHAR2,
                        p_last_name       => 'Olsen',                            --     VARCHAR2,
                        p_email           => 'COLSEN',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1344.498718',               --     VARCHAR2,
                        p_hiredate        => '1998-03-30T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 8000,                               --     NUMBER,
                        p_comm_pct        => .2,                                 --     NUMBER,
                        p_mgr_id          => 145,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 154         Nanette		         Cambrault		   NCAMBRAU		  011.44.1344.987668   09-DEC-98    SA_REP	    7500	      .2	         145	       80
         create_emp(
                        p_emp_id          => 154,                                --     NUMBER,
                        p_first_name      => 'Nanette',                          --     VARCHAR2,
                        p_last_name       => 'Cambrault',                        --     VARCHAR2,
                        p_email           => 'NCAMBRAU',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1344.987668',               --     VARCHAR2,
                        p_hiredate        => '1998-12-19T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 7500,                               --     NUMBER,
                        p_comm_pct        => .2,                                 --     NUMBER,
                        p_mgr_id          => 145,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 155         Oliver		         Tuvault		      OTUVAULT		  011.44.1344.486508   23-NOV-99    SA_REP	    7000	     .15	         145	       80
         create_emp(
                        p_emp_id          => 155,                              --     NUMBER,
                        p_first_name      => 'Oliver',                         --     VARCHAR2,
                        p_last_name       => 'Tuvault',                        --     VARCHAR2,
                        p_email           => 'OTUVAULT',                       --     VARCHAR2,
                        p_phone_number    => '011.44.1344.486508',             --     VARCHAR2,
                        p_hiredate        => '1999-11-23T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'SA_REP',                         --     VARCHAR2,
                        p_sal             => 7000,                             --     NUMBER,
                        p_comm_pct        => .15,                              --     NUMBER,
                        p_mgr_id          => 145,                              --     NUMBER,
                        p_department_id   => 80,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 156         Janette		         King			      JKING		     011.44.1345.429268   30-JAN-96    SA_REP	   10000	     .35	         146	       80
         create_emp(
                        p_emp_id          => 156,                             --     NUMBER,
                        p_first_name      => 'Janette',                       --     VARCHAR2,
                        p_last_name       => 'King',                          --     VARCHAR2,
                        p_email           => 'JKING',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1345.429268',            --     VARCHAR2,
                        p_hiredate        => '1996-01-30T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'SA_REP',                        --     VARCHAR2,
                        p_sal             => 10000,                           --     NUMBER,
                        p_comm_pct        => .35,                             --     NUMBER,
                        p_mgr_id          => 146,                             --     NUMBER,
                        p_department_id   => 80,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 157         Patrick		         Sully			      PSULLY		  011.44.1345.929268   04-MAR-96    SA_REP	    9500	     .35	         146	       80
         create_emp(
                        p_emp_id          => 157,                                --     NUMBER,
                        p_first_name      => 'Patrick',                          --     VARCHAR2,
                        p_last_name       => 'Sully',                            --     VARCHAR2,
                        p_email           => 'PSULLY',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1345.929268',               --     VARCHAR2,
                        p_hiredate        => '1996-03-04T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 9500,                               --     NUMBER,
                        p_comm_pct        => .35,                                --     NUMBER,
                        p_mgr_id          => 146,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 158         Allan		            McEwen 		      AMCEWEN		  011.44.1345.829268   01-AUG-96    SA_REP	    9000	     .35	         146	       80
         create_emp(
                        p_emp_id          => 158,                                --     NUMBER,
                        p_first_name      => 'Allan',                            --     VARCHAR2,
                        p_last_name       => 'McEwen',                           --     VARCHAR2,
                        p_email           => 'AMCEWEN',                          --     VARCHAR2,
                        p_phone_number    => '011.44.1345.829268',               --     VARCHAR2,
                        p_hiredate        => '1996-08-01T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 9000,                               --     NUMBER,
                        p_comm_pct        => .35,                                --     NUMBER,
                        p_mgr_id          => 146,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 159         Lindsey		         Smith			      LSMITH		  011.44.1345.729268   10-MAR-97    SA_REP	    8000	      .3	         146	       80
         create_emp(
                        p_emp_id          => 159,                                --     NUMBER,
                        p_first_name      => 'Lindsey',                          --     VARCHAR2,
                        p_last_name       => 'Smith',                            --     VARCHAR2,
                        p_email           => 'LSMITH',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1345.729268',               --     VARCHAR2,
                        p_hiredate        => '1997-03-10T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 8000,                               --     NUMBER,
                        p_comm_pct        => .3,                                 --     NUMBER,
                        p_mgr_id          => 146,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 160         Louise		         Doran			      LDORAN		  011.44.1345.629268   15-DEC-97    SA_REP	    7500	      .3	         146	       80
         create_emp(
                        p_emp_id          => 160,                                --     NUMBER,
                        p_first_name      => 'Louise',                           --     VARCHAR2,
                        p_last_name       => 'Doran',                            --     VARCHAR2,
                        p_email           => 'LDORAN',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1345.629268',               --     VARCHAR2,
                        p_hiredate        => '1997-12-15T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 7500,                               --     NUMBER,
                        p_comm_pct        => .3,                                 --     NUMBER,
                        p_mgr_id          => 146,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 161         Sarath		         Sewall 		      SSEWALL		  011.44.1345.529268   03-NOV-98    SA_REP	    7000	     .25	         146	       80
         create_emp(
                        p_emp_id          => 161,                                --     NUMBER,
                        p_first_name      => 'Sarath',                           --     VARCHAR2,
                        p_last_name       => 'Sewall',                           --     VARCHAR2,
                        p_email           => 'SSEWALL',                          --     VARCHAR2,
                        p_phone_number    => '011.44.1345.529268',               --     VARCHAR2,
                        p_hiredate        => '1998-11-03T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 7000,                               --     NUMBER,
                        p_comm_pct        => .25,                                --     NUMBER,
                        p_mgr_id          => 146,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 162         Clara		            Vishney		      CVISHNEY		  011.44.1346.129268   11-NOV-97    SA_REP	   10500	     .25	         147	       80
         create_emp(
                        p_emp_id          => 162,                                --     NUMBER,
                        p_first_name      => 'Clara',                            --     VARCHAR2,
                        p_last_name       => 'Vishney',                          --     VARCHAR2,
                        p_email           => 'CVISHNEY',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1346.129268',               --     VARCHAR2,
                        p_hiredate        => '1997-11-11T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 10500,                              --     NUMBER,
                        p_comm_pct        => .25,                                --     NUMBER,
                        p_mgr_id          => 147,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 163         Danielle		         Greene 		      DGREENE		  011.44.1346.229268   19-MAR-99    SA_REP	    9500	     .15	         147	       80
         create_emp(
                        p_emp_id          => 163,                                 --     NUMBER,
                        p_first_name      => 'Danielle',                          --     VARCHAR2,
                        p_last_name       => 'Greene',                            --     VARCHAR2,
                        p_email           => 'DGREENE',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1346.229268',                --     VARCHAR2,
                        p_hiredate        => '1999-03-19T00:00:00.000Z',          --     VARCHAR2,
                        p_job_id          => 'SA_REP',                            --     VARCHAR2,
                        p_sal             => 9500,                                --     NUMBER,
                        p_comm_pct        => .15,                                 --     NUMBER,
                        p_mgr_id          => 147,                                 --     NUMBER,
                        p_department_id   => 80,                                  --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 164         Mattea		         Marvins		      MMARVINS		  011.44.1346.329268   24-JAN-00    SA_REP	    7200	      .1	         147	       80
         create_emp(
                        p_emp_id          => 164,                                --     NUMBER,
                        p_first_name      => 'Mattea',                           --     VARCHAR2,
                        p_last_name       => 'Marvins',                          --     VARCHAR2,
                        p_email           => 'MMARVINS',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1346.329268',               --     VARCHAR2,
                        p_hiredate        => '2000-01-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 7200,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 147,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 165         David		            Lee			      DLEE 		     011.44.1346.529268   23-FEB-00    SA_REP	    6800	      .1	         147	       80
         create_emp(
                        p_emp_id          => 165,                                --     NUMBER,
                        p_first_name      => 'David',                            --     VARCHAR2,
                        p_last_name       => 'Lee',                              --     VARCHAR2,
                        p_email           => 'DLEE',                             --     VARCHAR2,
                        p_phone_number    => '011.44.1346.529268',               --     VARCHAR2,
                        p_hiredate        => '2000-02-23T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 6800,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 147,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 166         Sundar		         Ande			      SANDE		     011.44.1346.629268   24-MAR-00    SA_REP	    6400	      .1	         147	       80
         create_emp(
                        p_emp_id          => 166,                                --     NUMBER,
                        p_first_name      => 'Sundar',                           --     VARCHAR2,
                        p_last_name       => 'Ande',                             --     VARCHAR2,
                        p_email           => 'SANDE',                            --     VARCHAR2,
                        p_phone_number    => '011.44.1346.629268',               --     VARCHAR2,
                        p_hiredate        => '2000-03-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 6400,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 147,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 167         Amit		            Banda			      ABANDA		  011.44.1346.729268   21-APR-00    SA_REP	    6200	      .1	         147	       80
         create_emp(
                        p_emp_id          => 167,                                --     NUMBER,
                        p_first_name      => 'Amit',                             --     VARCHAR2,
                        p_last_name       => 'Banda',                            --     VARCHAR2,
                        p_email           => 'ABANDA',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1346.729268',               --     VARCHAR2,
                        p_hiredate        => '2000-04-21T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 6200,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 147,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 168         Lisa		            Ozer			      LOZER		     011.44.1343.929268   11-MAR-97    SA_REP	   11500	     .25	         148	       80
         create_emp(
                        p_emp_id          => 168,                             --     NUMBER,
                        p_first_name      => 'Lisa',                          --     VARCHAR2,
                        p_last_name       => 'Ozer',                          --     VARCHAR2,
                        p_email           => 'LOZER',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1343.929268',            --     VARCHAR2,
                        p_hiredate        => '1997-03-11T00:00:00.000Z',      --     VARCHAR2,
                        p_job_id          => 'SA_REP',                        --     VARCHAR2,
                        p_sal             => 11500,                           --     NUMBER,
                        p_comm_pct        => .25,                             --     NUMBER,
                        p_mgr_id          => 148,                             --     NUMBER,
                        p_department_id   => 80,                              --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 169         Harrison		         Bloom			      HBLOOM		  011.44.1343.829268   23-MAR-98    SA_REP	   10000	      .2	         148	       80
         create_emp(
                        p_emp_id          => 169,                              --     NUMBER,
                        p_first_name      => 'Harrison',                       --     VARCHAR2,
                        p_last_name       => 'Bloom',                          --     VARCHAR2,
                        p_email           => 'HBLOOM',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1343.829268',             --     VARCHAR2,
                        p_hiredate        => '1998-03-23T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'SA_REP',                         --     VARCHAR2,
                        p_sal             => 10000,                            --     NUMBER,
                        p_comm_pct        => .2,                               --     NUMBER,
                        p_mgr_id          => 148,                              --     NUMBER,
                        p_department_id   => 80,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 170         Tayler		         Fox			      TFOX 		     011.44.1343.729268   24-JAN-98    SA_REP	    9600	      .2	         148	       80
         create_emp(
                        p_emp_id          => 170,                                --     NUMBER,
                        p_first_name      => 'Tayler',                           --     VARCHAR2,
                        p_last_name       => 'Fox',                              --     VARCHAR2,
                        p_email           => 'TFOX',                             --     VARCHAR2,
                        p_phone_number    => '011.44.1343.729268',               --     VARCHAR2,
                        p_hiredate        => '1998-01-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 9600,                               --     NUMBER,
                        p_comm_pct        => .2,                                 --     NUMBER,
                        p_mgr_id          => 148,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 171         William		         Smith			      WSMITH		  011.44.1343.629268   23-FEB-99    SA_REP	    7400	     .15	         148	       80
         create_emp(
                        p_emp_id          => 171,                                  --     NUMBER,
                        p_first_name      => 'William',                            --     VARCHAR2,
                        p_last_name       => 'Smith',                              --     VARCHAR2,
                        p_email           => 'WSMITH',                             --     VARCHAR2,
                        p_phone_number    => '011.44.1343.629268',                 --     VARCHAR2,
                        p_hiredate        => '1999-02-23T00:00:00.000Z',           --     VARCHAR2,
                        p_job_id          => 'SA_REP',                             --     VARCHAR2,
                        p_sal             => 7400,                                 --     NUMBER,
                        p_comm_pct        => .15,                                  --     NUMBER,
                        p_mgr_id          => 148,                                  --     NUMBER,
                        p_department_id   => 80,                                   --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 172         Elizabeth	         Bates			      EBATES		  011.44.1343.529268   24-MAR-99    SA_REP	    7300	     .15	         148	       80
         create_emp(
                        p_emp_id          => 172,                              --     NUMBER,
                        p_first_name      => 'Elizabeth',                      --     VARCHAR2,
                        p_last_name       => 'Bates',                          --     VARCHAR2,
                        p_email           => 'EBATES',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1343.529268',             --     VARCHAR2,
                        p_hiredate        => '1999-03-24T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'SA_REP',                         --     VARCHAR2,
                        p_sal             => 7300,                             --     NUMBER,
                        p_comm_pct        => .15,                              --     NUMBER,
                        p_mgr_id          => 148,                              --     NUMBER,
                        p_department_id   => 80,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 173         Sundita		         Kumar			      SKUMAR		  011.44.1343.329268   21-APR-00    SA_REP	    6100	      .1	         148	       80
         create_emp(
                        p_emp_id          => 173,                                --     NUMBER,
                        p_first_name      => 'Sundita',                          --     VARCHAR2,
                        p_last_name       => 'Kumar',                            --     VARCHAR2,
                        p_email           => 'SKUMAR',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1343.329268',               --     VARCHAR2,
                        p_hiredate        => '2000-04-21T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 6100,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 148,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 174         Ellen		            Abel			      EABEL		     011.44.1644.429267   11-MAY-96    SA_REP	   11000	      .3	         149	       80
         create_emp(
                        p_emp_id          => 174,                                   --     NUMBER,
                        p_first_name      => 'Ellen',                               --     VARCHAR2,
                        p_last_name       => 'Abel',                                --     VARCHAR2,
                        p_email           => 'EABEL',                               --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429267',                  --     VARCHAR2,
                        p_hiredate        => '1996-05-11T00:00:00.000Z',            --     VARCHAR2,
                        p_job_id          => 'SA_REP',                              --     VARCHAR2,
                        p_sal             => 11000,                                 --     NUMBER,
                        p_comm_pct        => .3,                                    --     NUMBER,
                        p_mgr_id          => 149,                                   --     NUMBER,
                        p_department_id   => 80,                                    --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 175         Alyssa		         Hutton 		      AHUTTON		  011.44.1644.429266   19-MAR-97    SA_REP	    8800	     .25	         149	       80
         create_emp(
                        p_emp_id          => 175,                                --     NUMBER,
                        p_first_name      => 'Alyssa',                           --     VARCHAR2,
                        p_last_name       => 'Hutton',                           --     VARCHAR2,
                        p_email           => 'AHUTTON',                          --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429266',               --     VARCHAR2,
                        p_hiredate        => '1997-03-19T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 8800,                               --     NUMBER,
                        p_comm_pct        => .25,                                --     NUMBER,
                        p_mgr_id          => 149,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 176         Jonathon		         Taylor 		      JTAYLOR		  011.44.1644.429265   24-MAR-98    SA_REP	    8600	      .2	         149	       80
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
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 177         Jack		            Livingston		   JLIVINGS		  011.44.1644.429264   23-APR-98    SA_REP	    8400	      .2	         149	       80
         create_emp(
                        p_emp_id          => 177,                            --     NUMBER,
                        p_first_name      => 'Jack',                         --     VARCHAR2,
                        p_last_name       => 'Livingston',                   --     VARCHAR2,
                        p_email           => 'JLIVINGS',                     --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429264',           --     VARCHAR2,
                        p_hiredate        => '1998-04-23T00:00:00.000Z',     --     VARCHAR2,
                        p_job_id          => 'SA_REP',                       --     VARCHAR2,
                        p_sal             => 8400,                           --     NUMBER,
                        p_comm_pct        => .2,                             --     NUMBER,
                        p_mgr_id          => 149,                            --     NUMBER,
                        p_department_id   => 80,                             --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 178         Kimberely	         Grant			      KGRANT		  011.44.1644.429263   24-MAY-99    SA_REP	    7000	     .15	         149
         create_emp(
                        p_emp_id          => 178,                                --     NUMBER,
                        p_first_name      => 'Kimberely',                        --     VARCHAR2,
                        p_last_name       => 'Grant',                            --     VARCHAR2,
                        p_email           => 'KGRANT',                           --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429263',               --     VARCHAR2,
                        p_hiredate        => '1999-05-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 7000,                               --     NUMBER,
                        p_comm_pct        => .15,                                --     NUMBER,
                        p_mgr_id          => 149,                                --     NUMBER,
                        p_department_id   => NULL,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 179         Charles		         Johnson		      CJOHNSON		  011.44.1644.429262   04-JAN-00    SA_REP	    6200	      .1	         149	       80
         create_emp(
                        p_emp_id          => 179,                                --     NUMBER,
                        p_first_name      => 'Charles',                          --     VARCHAR2,
                        p_last_name       => 'Johnson',                          --     VARCHAR2,
                        p_email           => 'CJOHNSON',                         --     VARCHAR2,
                        p_phone_number    => '011.44.1644.429262',               --     VARCHAR2,
                        p_hiredate        => '2000-01-04T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SA_REP',                           --     VARCHAR2,
                        p_sal             => 6200,                               --     NUMBER,
                        p_comm_pct        => .1,                                 --     NUMBER,
                        p_mgr_id          => 149,                                --     NUMBER,
                        p_department_id   => 80,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 180         Winston		         Taylor 		      WTAYLOR		  650.507.9876	        24-JAN-98    SH_CLERK	    3200			            120	       50
         create_emp(
                        p_emp_id          => 180,                                --     NUMBER,
                        p_first_name      => 'Winston',                          --     VARCHAR2,
                        p_last_name       => 'Taylor',                           --     VARCHAR2,
                        p_email           => 'WTAYLOR',                          --     VARCHAR2,
                        p_phone_number    => '650.507.9876',                     --     VARCHAR2,
                        p_hiredate        => '1998-01-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3200,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 120,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 181         Jean		            Fleaur 		      JFLEAUR		  650.507.9877	        23-FEB-98    SH_CLERK	    3100			            120	       50
         create_emp(
                        p_emp_id          => 181,                                --     NUMBER,
                        p_first_name      => 'Jean',                             --     VARCHAR2,
                        p_last_name       => 'Fleaur',                           --     VARCHAR2,
                        p_email           => 'JFLEAUR',                          --     VARCHAR2,
                        p_phone_number    => '650.507.9877',                     --     VARCHAR2,
                        p_hiredate        => '1998-02-23T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3100,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 120,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 182         Martha		         Sullivan		      MSULLIVA		  650.507.9878	        21-JUN-99    SH_CLERK	    2500			            120	       50
         create_emp(
                        p_emp_id          => 182,                         --     NUMBER,
                        p_first_name      => 'Martha',                    --     VARCHAR2,
                        p_last_name       => 'Sullivan',                  --     VARCHAR2,
                        p_email           => 'MSULLIVA',                  --     VARCHAR2,
                        p_phone_number    => '650.507.9878',              --     VARCHAR2,
                        p_hiredate        => '1999-06-21T00:00:00.000Z',  --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                  --     VARCHAR2,
                        p_sal             => 2500,                        --     NUMBER,
                        p_comm_pct        => NULL,                        --     NUMBER,
                        p_mgr_id          => 120,                         --     NUMBER,
                        p_department_id   => 50,                          --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 183         Girard		         Geoni			      GGEONI		  650.507.9879	        03-FEB-00    SH_CLERK	    2800			            120	       50
         create_emp(
                        p_emp_id          => 183,                                --     NUMBER,
                        p_first_name      => 'Girard',                           --     VARCHAR2,
                        p_last_name       => 'Geoni',                            --     VARCHAR2,
                        p_email           => 'GGEONI',                           --     VARCHAR2,
                        p_phone_number    => '650.507.9879',                     --     VARCHAR2,
                        p_hiredate        => '2000-02-03T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 2800,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 120,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 184         Nandita		         Sarchand		      NSARCHAN		  650.509.1876	        27-JAN-96    SH_CLERK	    4200			            121	       50
         create_emp(
                        p_emp_id          => 184,                                --     NUMBER,
                        p_first_name      => 'Nandita',                          --     VARCHAR2,
                        p_last_name       => 'Sarchand',                         --     VARCHAR2,
                        p_email           => 'NSARCHAN',                         --     VARCHAR2,
                        p_phone_number    => '650.509.1876',                     --     VARCHAR2,
                        p_hiredate        => '1996-01-27T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 4200,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 185         Alexis		         Bull			      ABULL		     650.509.2876	        20-FEB-97    SH_CLERK	    4100			            121	       50
         create_emp(
                        p_emp_id          => 185,                                --     NUMBER,
                        p_first_name      => 'Alexis',                           --     VARCHAR2,
                        p_last_name       => 'Bull',                             --     VARCHAR2,
                        p_email           => 'ABULL',                            --     VARCHAR2,
                        p_phone_number    => '650.509.2876',                     --     VARCHAR2,
                        p_hiredate        => '1997-02-20T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 4100,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 186         Julia		            Dellinger		   JDELLING		  650.509.3876	        24-JUN-98    SH_CLERK	    3400			            121	       50
         create_emp(
                        p_emp_id          => 186,                                --     NUMBER,
                        p_first_name      => 'Julia',                            --     VARCHAR2,
                        p_last_name       => 'Dellinger',                        --     VARCHAR2,
                        p_email           => 'JDELLING',                         --     VARCHAR2,
                        p_phone_number    => '650.509.3876',                     --     VARCHAR2,
                        p_hiredate        => '1998-06-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3400,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 187         Anthony		         Cabrio 		      ACABRIO		  650.509.4876	        07-FEB-99    SH_CLERK	    3000			            121	       50
         create_emp(
                        p_emp_id          => 187,                                --     NUMBER,
                        p_first_name      => 'Anthony',                          --     VARCHAR2,
                        p_last_name       => 'Cabrio',                           --     VARCHAR2,
                        p_email           => 'ACABRIO',                          --     VARCHAR2,
                        p_phone_number    => '650.509.4876',                     --     VARCHAR2,
                        p_hiredate        => '1999-02-07T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3000,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 121,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 188         Kelly		            Chung			      KCHUNG		  650.505.1876	        14-JUN-97    SH_CLERK	    3800			            122	       50
         create_emp(
                        p_emp_id          => 188,                              --     NUMBER,
                        p_first_name      => 'Kelly',                          --     VARCHAR2,
                        p_last_name       => 'Chung',                          --     VARCHAR2,
                        p_email           => 'KCHUNG',                         --     VARCHAR2,
                        p_phone_number    => '650.505.1876',                   --     VARCHAR2,
                        p_hiredate        => '1997-06-14T00:00:00.000Z',       --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                       --     VARCHAR2,
                        p_sal             => 3800,                             --     NUMBER,
                        p_comm_pct        => NULL,                             --     NUMBER,
                        p_mgr_id          => 122,                              --     NUMBER,
                        p_department_id   => 50,                               --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 189         Jennifer		         Dilly			      JDILLY		  650.505.2876	        13-AUG-97    SH_CLERK	    3600			            122	       50
         create_emp(
                        p_emp_id          => 189,                                 --     NUMBER,
                        p_first_name      => 'Jennifer',                          --     VARCHAR2,
                        p_last_name       => 'Dilly',                             --     VARCHAR2,
                        p_email           => 'JDILLY',                            --     VARCHAR2,
                        p_phone_number    => '650.505.2876',                      --     VARCHAR2,
                        p_hiredate        => '1997-09-13T00:00:00.000Z',          --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                          --     VARCHAR2,
                        p_sal             => 3600,                                --     NUMBER,
                        p_comm_pct        => NULL,                                --     NUMBER,
                        p_mgr_id          => 122,                                 --     NUMBER,
                        p_department_id   => 50,                                  --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 190         Timothy		         Gates			      TGATES		  650.505.3876	        11-JUL-98    SH_CLERK	    2900			            122	       50
         create_emp(
                        p_emp_id          => 190,                                  --     NUMBER,
                        p_first_name      => 'Timothy',                            --     VARCHAR2,
                        p_last_name       => 'Gates',                              --     VARCHAR2,
                        p_email           => 'TGATES',                             --     VARCHAR2,
                        p_phone_number    => '650.505.3876',                       --     VARCHAR2,
                        p_hiredate        => '1998-07-11T00:00:00.000Z',           --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                           --     VARCHAR2,
                        p_sal             => 2900,                                  --     NUMBER,
                        p_comm_pct        => NULL,                                 --     NUMBER,
                        p_mgr_id          => 122,                                  --     NUMBER,
                        p_department_id   => 50,                                   --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 191         Randall		         Perkins		      RPERKINS		  650.505.4876	        19-DEC-99    SH_CLERK	    2500			            122	       50
         create_emp(
                        p_emp_id          => 191,                                  --     NUMBER,
                        p_first_name      => 'Randall',                            --     VARCHAR2,
                        p_last_name       => 'Perkins',                            --     VARCHAR2,
                        p_email           => 'RPERKINS',                           --     VARCHAR2,
                        p_phone_number    => '650.505.4876',                       --     VARCHAR2,
                        p_hiredate        => '1999-12-19T00:00:00.000Z',           --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                           --     VARCHAR2,
                        p_sal             => 2500,                                 --     NUMBER,
                        p_comm_pct        => NULL,                                 --     NUMBER,
                        p_mgr_id          => 122,                                  --     NUMBER,
                        p_department_id   => 50,                                   --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 192         Sarah		            Bell			      SBELL		     650.501.1876	        04-FEB-96    SH_CLERK	    4000			            123	       50
         create_emp(
                        p_emp_id          => 192,                                --     NUMBER,
                        p_first_name      => 'Sarah',                            --     VARCHAR2,
                        p_last_name       => 'Bell',                             --     VARCHAR2,
                        p_email           => 'SBELL',                            --     VARCHAR2,
                        p_phone_number    => '650.501.1876',                     --     VARCHAR2,
                        p_hiredate        => '1996-02-04T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 4000,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 193         Britney		         Everett		      BEVERETT		  650.501.2876	        03-MAR-97    SH_CLERK	    3900			            123	       50
         create_emp(
                        p_emp_id          => 193,                                --     NUMBER,
                        p_first_name      => 'Britney',                          --     VARCHAR2,
                        p_last_name       => 'Everett',                          --     VARCHAR2,
                        p_email           => 'BEVERETT',                         --     VARCHAR2,
                        p_phone_number    => '650.501.2876',                     --     VARCHAR2,
                        p_hiredate        => '1997-03-03T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3900,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 194         Samuel		            McCain 		      SMCCAIN		  650.501.3876	        01-JUL-98    SH_CLERK	    3200			            123	       50
         create_emp(
                        p_emp_id          => 194,                                --     NUMBER,
                        p_first_name      => 'Samuel',                           --     VARCHAR2,
                        p_last_name       => 'McCain',                           --     VARCHAR2,
                        p_email           => 'SMCCAIN',                          --     VARCHAR2,
                        p_phone_number    => '650.501.3876',                     --     VARCHAR2,
                        p_hiredate        => '1998-07-01T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3200,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 195         Vance		            Jones			      VJONES		  650.501.4876	        17-MAR-99    SH_CLERK	    2800			            123	       50
         create_emp(
                        p_emp_id          => 195,                                --     NUMBER,
                        p_first_name      => 'Vance',                            --     VARCHAR2,
                        p_last_name       => 'Jones',                            --     VARCHAR2,
                        p_email           => 'VJONES',                           --     VARCHAR2,
                        p_phone_number    => '650.501.4876',                     --     VARCHAR2,
                        p_hiredate        => '1999-03-17T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 2800,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 123,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 196         Alana		            Walsh			      AWALSH		  650.507.9811	        24-APR-98    SH_CLERK	    3100			            124	       50
         create_emp(
                        p_emp_id          => 196,                                --     NUMBER,
                        p_first_name      => 'Alana',                            --     VARCHAR2,
                        p_last_name       => 'Walsh',                            --     VARCHAR2,
                        p_email           => 'AWALSH',                           --     VARCHAR2,
                        p_phone_number    => '650.507.9811',                     --     VARCHAR2,
                        p_hiredate        => '1998-04-24T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3100,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 124,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 197         Kevin		            Feeney 		      KFEENEY		  650.507.9822	        23-MAY-98    SH_CLERK	    3000			            124	       50
         create_emp(
                        p_emp_id          => 197,                                --     NUMBER,
                        p_first_name      => 'Kevin',                            --     VARCHAR2,
                        p_last_name       => 'Feeney',                           --     VARCHAR2,
                        p_email           => 'KFEENEY',                          --     VARCHAR2,
                        p_phone_number    => '650.507.9822',                     --     VARCHAR2,
                        p_hiredate        => '1998-05-23T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 3000,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 124,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 198         Donald	            OConnell		      DOCONNEL		  650.507.9833	        21-JUN-99    SH_CLERK	    2600			            124	       50
         create_emp(
                        p_emp_id          => 198,                          --     NUMBER,
                        p_first_name      => 'Donald',                     --     VARCHAR2,
                        p_last_name       => 'OConnell',                       --     VARCHAR2,
                        p_email           => 'DOCONNEL',                      --     VARCHAR2,
                        p_phone_number    => '650.507.9833',               --     VARCHAR2,
                        p_hiredate        => '1999-06-21T00:00:00.000Z',   --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                    --     VARCHAR2,
                        p_sal             => 2600,                        --     NUMBER,
                        p_comm_pct        => NULL,                         --     NUMBER,
                        p_mgr_id          => 124,                         --     NUMBER,
                        p_department_id   => 50,                           --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 199         Douglas	            Grant			      DGRANT		  650.507.9844	        13-JAN-00    SH_CLERK	    2600			            124	       50
         create_emp(
                        p_emp_id          => 199,                                --     NUMBER,
                        p_first_name      => 'Douglas',                          --     VARCHAR2,
                        p_last_name       => 'Grant',                            --     VARCHAR2,
                        p_email           => 'DGRANT',                           --     VARCHAR2,
                        p_phone_number    => '650.507.9844',                     --     VARCHAR2,
                        p_hiredate        => '2000-01-13T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'SH_CLERK',                         --     VARCHAR2,
                        p_sal             => 2600,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 124,                                --     NUMBER,
                        p_department_id   => 50,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 200         Jennifer	            Whalen 		      JWHALEN		  515.123.4444	        17-SEP-87    AD_ASST	    4400			            101	       10
         create_emp(
                        p_emp_id          => 200,                                 --     NUMBER,
                        p_first_name      => 'Jennifer',                          --     VARCHAR2,
                        p_last_name       => 'Whalen',                            --     VARCHAR2,
                        p_email           => 'JWHALEN',                           --     VARCHAR2,
                        p_phone_number    => '515.123.4444',                      --     VARCHAR2,
                        p_hiredate        => '1987-09-17T00:00:00.000Z',          --     VARCHAR2,
                        p_job_id          => 'AD_ASST',                           --     VARCHAR2,
                        p_sal             => 4400,                                --     NUMBER,
                        p_comm_pct        => NULL,                                --     NUMBER,
                        p_mgr_id          => 101,                                 --     NUMBER,
                        p_department_id   => 10,                                  --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 201         Michael	            Hartstein		   MHARTSTE		  515.123.5555	        17-FEB-96    MK_MAN	   13000			            100	       20
         create_emp(
                        p_emp_id          => 201,                                --     NUMBER,
                        p_first_name      => 'Michael',                          --     VARCHAR2,
                        p_last_name       => 'Hartstein',                        --     VARCHAR2,
                        p_email           => 'MHARTSTE',                         --     VARCHAR2,
                        p_phone_number    => '515.123.5555',                     --     VARCHAR2,
                        p_hiredate        => '1996-02-17T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'MK_MAN',                           --     VARCHAR2,
                        p_sal             => 13000,                              --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 100,                                --     NUMBER,
                        p_department_id   => 20,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
         -----------------------------------------------------------
         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
         -- 202         Pat 		            Fay			      PFAY 		     603.123.6666	        17-AUG-97    MK_REP	    6000			            201	       20
         create_emp(
                        p_emp_id          => 202,                                --     NUMBER,
                        p_first_name      => 'Pat',                              --     VARCHAR2,
                        p_last_name       => 'Fay',                              --     VARCHAR2,
                        p_email           => 'PFAY',                             --     VARCHAR2,
                        p_phone_number    => '603.123.6666',                     --     VARCHAR2,
                        p_hiredate        => '1997-09-17T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'MK_REP',                           --     VARCHAR2,
                        p_sal             => 6000,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 201,                                --     NUMBER,
                        p_department_id   => 20,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 203         Susan		            Mavris 		      SMAVRIS		  515.123.7777	        07-JUN-94    HR_REP	    6500			            101	       40
         create_emp(
                        p_emp_id          => 203,                                --     NUMBER,
                        p_first_name      => 'Susan',                            --     VARCHAR2,
                        p_last_name       => 'Mavris',                           --     VARCHAR2,
                        p_email           => 'SMAVRIS',                          --     VARCHAR2,
                        p_phone_number    => '515.123.7777',                     --     VARCHAR2,
                        p_hiredate        => '1994-06-07T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'HR_REP',                           --     VARCHAR2,
                        p_sal             => 6500,                               --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 101,                                --     NUMBER,
                        p_department_id   => 40,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 204         Hermann	            Baer			      HBAER		     515.123.8888	        07-JUN-94    PR_REP	   10000			            101	       70
         create_emp(
                        p_emp_id          => 204,                                --     NUMBER,
                        p_first_name      => 'Hermann',                          --     VARCHAR2,
                        p_last_name       => 'Baer',                             --     VARCHAR2,
                        p_email           => 'HBAER',                            --     VARCHAR2,
                        p_phone_number    => '515.123.8888',                     --     VARCHAR2,
                        p_hiredate        => '1994-07-17T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'PR_REP',                           --     VARCHAR2,
                        p_sal             => 10000,                              --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 101,                                --     NUMBER,
                        p_department_id   => 70,                                 --     NUMBER,
                        p_details         => v_cursor
                     );
--         -----------------------------------------------------------
--         -- EMPLOYEE_ID FIRST_NAME		      LAST_NAME		   EMAIL		     PHONE_NUMBER	        HIRE_DATE    JOB_ID	  SALARY    COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
--         -- 205         Shelley	            Higgins		      SHIGGINS		  515.123.8080	        07-JUN-94    AC_MGR	   12000			            101	      110
         create_emp(
                        p_emp_id          => 205,                                --     NUMBER,
                        p_first_name      => 'Shelley',                          --     VARCHAR2,
                        p_last_name       => 'Higgins',                          --     VARCHAR2,
                        p_email           => 'SHIGGINS',                         --     VARCHAR2,
                        p_phone_number    => '515.123.8080',                     --     VARCHAR2,
                        p_hiredate        => '1994-06-07T00:00:00.000Z',         --     VARCHAR2,
                        p_job_id          => 'AC_MGR',                           --     VARCHAR2,
                        p_sal             => 12000,                              --     NUMBER,
                        p_comm_pct        => NULL,                               --     NUMBER,
                        p_mgr_id          => 101,                                --     NUMBER,
                        p_department_id   => 110,                                --     NUMBER,
                        p_details         => v_cursor
                     );
      END;  --  create employees data
      --
   END;
   --
END;
/


