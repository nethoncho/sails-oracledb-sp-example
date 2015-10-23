/**
 * EmployeeController
 *
 * @description :: Server-side logic for managing employee
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
  find: function(req, res) {
    var allParams = req.allParams();

    var params = [];
    _.forOwn(allParams, function(value, key) {
      if(!_.isUndefined(value)) {
        var param = {};
        param[key] = value;
        params.push(param);
      }
    });

    if(params.length === 0) {
      params = null;
    }

    Employee.find(params, function(err, employees) {
      if (err) return res.negotiate(err);
      if(req.isSocket) {
        Employee.subscribe(req, _.pluck(employees, 'id'));
      }
      res.json(employees);
    });
  },

  create: function(req, res) {
    var allParams = req.allParams();
    Employee.create(allParams, function(err, employee) {
      if (err) return res.negotiate(err);
      res.json(employee);
    });
  }
	
};

