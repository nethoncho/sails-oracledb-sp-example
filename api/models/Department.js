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
    id: {
      columnName: 'DEPARTMENT_ID',
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    name: {
      columnName: 'DEPARTMENT_NAME',
      type: 'string',
      required: true
    },
    managerId: {
      columnName: 'MANAGER_ID',
      type: 'string',
      required: true
    },
    locationId: {
      columnName: 'LOCATION_ID',
//      type: 'string',
//      required: true
      type: 'integer',
      required: false
    }
  }
};

