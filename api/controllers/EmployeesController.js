/**
 * EmployeesController
 *
 * @description :: Server-side logic for managing employees
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

    Employees.find(params, function(err, employeess) {
      if (err) return res.negotiate(err);
      res.json(employeess);
    });
  },

  create: function(req, res) {
    var allParams = req.allParams();
    Employees.create(allParams, function(err, employee) {
      if (err) return res.negotiate(err);
      res.json(employee);
    });
  }
	
};

