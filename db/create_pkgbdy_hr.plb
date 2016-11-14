--
-- hr.plb
--
CREATE OR REPLACE
PACKAGE BODY hr
IS
   --
   -----------------------------------------------------------------------------------
   --
   -- create an employee
   --
   PROCEDURE employees_c(
                            p_employee_id    IN     NUMBER,
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
                        )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.create_emp(
                                  p_employee_id,
                                  p_first_name,
                                  p_last_name,
                                  p_email,
                                  p_phone_number,
                                  p_hire_date,
                                  p_job_id,
                                  p_salary,
                                  p_commission_pct,
                                  p_manager_id,
                                  p_department_id,
                                  v_cursor
                              );
         p_details := v_cursor;
      END;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- obtain details for all employees
   --
   PROCEDURE employees_r(
                           p_details IN OUT hr_child.empl_details_refcur_t
                        )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT *
         FROM   employees;
      --
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read a specific employee's details
   --
   PROCEDURE employees_r(
                             p_employee_id   IN      employees.employee_id%TYPE,
                             p_details       IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     employees
         WHERE    employee_id = p_employee_id;
      --
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- Read the details for all of the employees in a specified department
   --
   PROCEDURE employees_r(
                             p_department_id    IN      departments.department_id%TYPE,
                             p_details          IN OUT  hr_child.empl_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     employees
         WHERE    department_id = p_department_id;
      --
      --
   END;
   --
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specific employee's salary
   --
   PROCEDURE employees_u(
                           p_employee_id  IN employees.employee_id%TYPE,
                           p_salary       IN NUMBER
                        )
   IS
   BEGIN
      hr_child.update_emp_salary(
                                    p_employee_id,
                                    p_salary
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
                           p_employee_id     IN  employees.employee_id%TYPE,
                           p_department_id   IN  employees.department_id%TYPE
                        )
   IS
   BEGIN
      hr_child.xver_employees(
                                p_employee_id,
                                p_department_id
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
                            p_employee_id IN employees.employee_id%TYPE
                        )
   IS
   BEGIN
      --
      hr_child.delete_emp( p_employee_id );
      --
   END;
   --
   --===========================================================
   --
   -- departments
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
                          )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.add_dept(
                              p_department_id => p_department_id,
                              p_dname         => p_dname,
                              p_location_id   => p_location_id,
                              p_mgr_id        => p_mgr_id,
                              p_details       => v_cursor
                           );
         p_details := v_cursor;
      END;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all employees details
   --
   PROCEDURE departments_r(
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
   -- Read details on a specified departments
   --
   PROCEDURE departments_r(
                             p_department_id    IN      NUMBER,
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
   PROCEDURE departments_u(
                              p_department_id   IN departments.department_id%TYPE,
                              p_department_name  IN VARCHAR2
                          )
   IS
   BEGIN
      hr_child.update_dept_name(
                                    p_department_id,
                                    p_department_name
                                );
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified department's location
   --
   PROCEDURE departments_u(
                              p_department_id  IN departments.department_id%TYPE,
                              p_loc     IN VARCHAR2
                          )
   IS
   BEGIN
      hr_child.update_dept_loc(
                                 p_department_id,
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
                              p_department_id  IN departments.department_id%TYPE
                           )
   IS
   BEGIN
      hr_child.delete_dept(
                              p_department_id
                          );
      --
   END;
   --
   --===========================================================
   --
   -- locations
   --
   -----------------------------------------------------------------------------------
   --
   -- create a location
   --
   PROCEDURE locations_c(
                           p_loc_id             IN     NUMBER,
                           p_street_address     IN     VARCHAR2,
                           p_postal_code        IN     VARCHAR2,
                           p_city               IN     VARCHAR2,
                           p_state_province     IN     VARCHAR2,
                           p_country_id         IN     NUMBER,
                           p_details            IN OUT hr_child.loc_details_refcur_t
                          )
   IS
   BEGIN
     --
      DECLARE
         v_cursor sys_refcursor;
      BEGIN
         hr_child.create_loc(
                              p_loc_id          => p_loc_id,
                              p_street_address  => p_street_address,
                              p_postal_code     => p_postal_code,
                              p_city            => p_city,
                              p_state_province  => p_state_province,
                              p_country_id      => p_country_id,
                              p_details         => v_cursor
                           );
         p_details := v_cursor;
      END;
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- Read all employees details
   --
   PROCEDURE locations_r(
                             p_details  IN OUT  hr_child.loc_details_refcur_t
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
   -- Read details on a specified locations
   --
   PROCEDURE locations_r(
                             p_loc_id    IN      NUMBER,
                             p_details   IN OUT  hr_child.loc_details_refcur_t
                          )
   IS
   BEGIN
      --
      OPEN p_details FOR
         SELECT   *
         FROM     locations
         WHERE    location_id = p_loc_id;
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- update a specified locations city
   --
   PROCEDURE locations_u(
                             p_loc_id    IN locations.location_id%TYPE,
                             p_city  IN VARCHAR2
                          )
   IS
   BEGIN
      hr_child.update_loc_city(
                                    p_loc_id,
                                    p_city
                                );
      --
   END;
   --
   -----------------------------------------------------------------------------------
   --
   -- destroy a specified location
   --
   PROCEDURE locations_d(
                             p_loc_id    IN locations.location_id%TYPE
                           )
   IS
   BEGIN
      hr_child.delete_loc(
                              p_loc_id
                          );
      --
   END;
   --
   --
   --==================================================================
   --
   -- return_codes_r()
   --
   --    obtains list of error messages for various user-defined Oracle Exceptions.
   --
   PROCEDURE return_codes_r( p_details  IN OUT SYS_REFCURSOR )
   IS
      --
      retcode_details_tab   retcode_nt := retcode_nt();
      --
   BEGIN
      --
      -- build up a nested table containing both
      -- return codes for all messages and
      -- message text for all messages
      --
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
      -- select the contents of the nested table into the resultset
      --
      OPEN p_details FOR
         SELECT *
         FROM TABLE(cast(retcode_details_tab AS retcode_nt));
      --
   END;
   --
   --==========================================================
   --
   -- reset database back to devault data (housekeeping)
   --
   PROCEDURE housekeeping_d
   IS
   BEGIN
      hr_child.housekeeping_d;
   END;
   --
   --
END;
/


