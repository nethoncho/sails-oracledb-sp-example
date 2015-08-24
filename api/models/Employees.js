/**
* Employees.js
*
* @description :: Employees
*/

module.exports = {

  tableName: 'EMPLOYEES',
  schema: true,
  connection: 'oraclehr',
  autoCreatedAt: false,
  autoUpdatedAt: false,

  attributes: {
    EMPLOYEE_ID: {
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    FIRST_NAME: {
      type: 'string',
      required: false
    },
    LAST_NAME: {
      type: 'string',
      required: true
    },
    EMAIL: {
      type: 'string',
      required: true
    },
    PHONE_NUMBER: {
      type: 'string',
      required: false
    },
    HIRE_DATE: {
      type: 'string',
      required: true
    },
    JOB_ID: {
      type: 'string',
      required: true
    },
    SALARY: {
      type: 'float',
      required: false
    },
    COMMISSION_PCT: {
      type: 'float',
      required: false
    },
    MANAGER_ID: {
      type: 'integer',
      required: false
    },
    DEPARTMENT: {
      type: 'integer',
      model: 'DEPARTMENTS',
      columnName: 'DEPARTMENT_ID',
      foreignKey: true,
      required: false
    }
  }
};

