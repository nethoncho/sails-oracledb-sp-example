# sails-oracledb-sp-example
Example sails project using oracledb stored procedures


## Installation

```bash
$ git clone https://github.com/nethoncho/sails-oracledb-sp-example.git
$ cd sails-oracledb-sp-example
$ npm install
```

## Sails Configuration

Edit the oracle hr adapter in the config/connections.js file to match your needs

```javascript
module.exports.connections = {
  oraclehr: {
    adapter: 'oracle-sp',
    user: 'hr',
    password: 'welcome',
    package: 'HR',
    cursorName: 'DETAILS',
    connectString: 'localhost/xe'
  }
};
```

## Apply the database changes in db/

## Run the application

```bash
$ sails lift
```

Point your browser to http://127.0.0.1:1337/Employees

## Routes

```
GET    /Employees
GET    /Employees/[EMPLOYEE_ID]
POST   /Employees
PUT    /Employees/[EMPLOYEE_ID]
DELETE /Employees/[EMPLOYEE_ID]
```

In this version of the example only EMAIL can be updated via put:

### POST Body example

```json
{
    "FIRST_NAME": "John",
    "LAST_NAME": "Doe",
    "EMAIL": "JDOE",
    "PHONE_NUMBER": "800-555-1212",
    "HIRE_DATE": "2014-07-07T04:00:00.000Z",
    "JOB_ID": "AD_PRES",
    "SALARY": 24000,
    "COMMISSION_PCT": 0.3,
    "MANAGER_ID": 100,
    "DEPARTMENT_ID": 90
}
```

### PUT Body example

```json
{
    "EMAIL": "JOHND"
}
```

#### License

**[MIT](./LICENSE)**
&copy; 2015
