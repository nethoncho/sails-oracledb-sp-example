'use strict';

angular.module('exampleApp').controller('employeesCtrl', ['$scope', '$sailsBind', '$q', '$http', 'departments',
  function ($scope, $sailsBind, $q, $http, departments) {
    $scope.departments = departments;
    $sailsBind.bind('api/employee', $scope);
    $sailsBind.bind('api/department', $scope);

    $scope.showDepartment = function(employee) {
      return _.result(_.find($scope.departments, { id: employee.department }), 'name');
    };

    $scope.updateDepartment = function(employee, data) {
      var d = $q.defer();

      $http.put('api/employee/' + employee.id, {
        department: data
      })
      .success(function(response) {
        d.resolve(false);
      })
      .error(function(response) {
        if(angular.isObject(response)) {
          if(response.hasOwnProperty('message')) {
            d.reject(response.message);
          } else {
            d.reject('API Error!');
          }
        } else {
          d.reject('Unknown API Error!');
        }
      });

      return d.promise;
    };

    $scope.updateSalary = function(employee, data) {
      var d = $q.defer();

      $http.put('api/employee/' + employee.id, {
        salary: data
      })
      .success(function(response) {
        d.resolve(false);
      })
      .error(function(response) {
        if(angular.isObject(response)) {
          if(response.hasOwnProperty('message')) {
            d.reject(response.message);
          } else {
            d.reject('API Error!');
          }
        } else {
          d.reject('Unknown API Error!');
        }
      });

      return d.promise;
    };
  }
]);
