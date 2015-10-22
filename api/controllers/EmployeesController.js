/**
 * EmployeesController
 *
 * @description :: Server-side logic for managing employees
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
  create: function(req, res) {
    sails.log.verbose('Project: create');
    sails.log.silly(req.body);

    var allParams = req.allParams();
    sails.log.silly(allParams);

    Employees.create(allParams, function(err, employee) {
      if (err) return res.negotiate(err);
      res.json(employee);
    });
  }
	
};

