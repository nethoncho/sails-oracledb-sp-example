/**
* Employee.js
*
* @description :: Employee
*/

module.exports = {

  tableName: 'EMPLOYEES',
  schema: true,
  connection: 'oraclehr',
  autoCreatedAt: false,
  autoUpdatedAt: false,

  attributes: {
    id: {
      columnName: 'EMPLOYEE_ID',
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    firstName: {
      columnName: 'FIRST_NAME',
      type: 'string',
      required: false
    },
    lastName: {
      columnName: 'LAST_NAME',
      type: 'string',
      required: false
    },
    email: {
      columnName: 'EMAIL',
      type: 'string',
      required: true
    },
    phoneNumber: {
      columnName: 'PHONE_NUMBER',
      type: 'string',
      required: false
    },
    hireDate: {
      columnName: 'HIRE_DATE',
      type: 'string',
      required: true
    },
    jobId: {
      columnName: 'JOB_ID',
      type: 'string',
      required: true
    },
    salary: {
      columnName: 'SALARY',
      type: 'float',
      required: false
    },
    commission: {
      columnName: 'COMMISSION_PCT',
      type: 'float',
      required: false
    },
    managerId: {
      columnName: 'MANAGER_ID',
      type: 'integer',
      required: false
    },
    departmentId: {
      columnName: 'DEPARTMENT_ID',
      type: 'integer',
      required: true
    }
  }
};
