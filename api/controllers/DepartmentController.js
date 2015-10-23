/**
 * DepartmentController
 *
 * @description :: Server-side logic for managing departments
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

    Department.find(params, function(err, departments) {
      if (err) return res.negotiate(err);
      if(req.isSocket) {
        Department.subscribe(req, _.pluck(departments, 'id'));
      }
      res.json(departments);
    });
  },

  create: function(req, res) {
    var allParams = req.allParams();
    Department.create(allParams, function(err, department) {
      if (err) return res.negotiate(err);
      res.json(department);
    });
  }
	
};
