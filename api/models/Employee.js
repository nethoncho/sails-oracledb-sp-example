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
      columnName: 'EMPNO',
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    name: {
      columnName: 'ENAME',
      type: 'string',
      required: false
    },
    job: {
      columnName: 'JOB',
      type: 'string',
      required: true
    },
    hireDate: {
      columnName: 'HIREDATE',
      type: 'string',
      required: true
    },
    department: {
      columnName: 'DEPTNO',
      type: 'integer',
      required: true
    },
    salary: {
      columnName: 'SAL',
      type: 'float',
      required: false
    },
    commission: {
      columnName: 'COMM',
      type: 'float',
      required: false
    },
    managerId: {
      columnName: 'MGR',
      type: 'integer',
      required: false
    }
  }
};

