# sails-oracledb-sp-example

## About
Example sails project using the [sails-oracledb-sp](https://github.com/Buto/sails-oracledb-sp) adapter

The current version exposes the Oracle HR Employee table via a REST API
Future versions will include a working web UI


## Installation

```bash
$ git clone https://github.com/nethoncho/sails-oracledb-sp-example.git
$ cd sails-oracledb-sp-example
$ npm install
```

## Configuration

Edit the oraclehr adapter in the config/connections.js file to match your needs

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

Apply the stored procedures to the HR schema in db/

```bash
cd db
```

The order is important

```bash
sqlplus "hr/welcome@localhost/xe" < create_pkg_hr-child.pls
sqlplus "hr/welcome@localhost/xe" < create_pkgbdy_hr-child.plb
sqlplus "hr/welcome@localhost/xe" < create_pkg_hr.pls
sqlplus "hr/welcome@localhost/xe" < create_pkgbdy_hr.plb
```

```bash
cd ..
```

## Run the application

```bash
$ sails lift
```

Point your browser to http://127.0.0.1:1337/Employees

### Routes

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
