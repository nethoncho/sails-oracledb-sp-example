/**
* Location.js
*
* @description :: Location
*/

module.exports = {

  tableName: 'LOCATIONS',
  schema: true,
  connection: 'oraclehr',
  autoCreatedAt: false,
  autoUpdatedAt: false,

  attributes: {
    id: {
      columnName: 'LOCATION_ID',
      type: 'integer',
      autoIncrement: true,
      primaryKey: true,
      unique: true
    },
    state: {
      columnName: 'STATE_PROVINCE',
      type: 'string',
      required: false
    },
    street: {
      columnName: 'STREET_ADDRESS',
      type: 'string',
      required: false
    },
    postalCode: {
      columnName: 'POSTAL_CODE',
      type: 'string',
      required: false
    },
    countryId: {
      columnName: 'COUNTRY_ID',
      type: 'integer',
      required: false
    },
    city: {
      columnName: 'CITY',
      type: 'string',
      required: false
    }
  }
};
