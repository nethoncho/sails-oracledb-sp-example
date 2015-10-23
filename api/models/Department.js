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
      columnName: 'DEPTNO',
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    name: {
      columnName: 'DNAME',
      type: 'string',
      required: true
    },
    location: {
      columnName: 'LOC',
      type: 'string',
      required: true
    }
  }
};

