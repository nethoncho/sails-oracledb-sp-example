/**
* Department.js
*
* @description :: TODO: You might write a short summary of how this model works and what it represents here.
* @docs        :: http://sailsjs.org/#!documentation/models
*/

module.exports = {

  tableName: 'DEPARTMENTS',
  schema: true,
  connection: 'oraclehr',
  autoCreatedAt: false,
  autoUpdatedAt: false,

  attributes: {
    DEPARTMENT_ID: {
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    DEPARTMENT_NAME: {
      type: 'string',
      required: true
    },
    MANAGER_ID: {
      type: 'integer',
      required: false
    },
    LOCATION_ID: {
      type: 'integer',
      required: false
    },
    EMPLOYEES: {
      collection: 'EMPLOYEES',
      via: 'DEPARTMENT'
    }
  }
};

