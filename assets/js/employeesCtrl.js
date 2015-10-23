'use strict';

angular.module('exampleApp').controller('employeesCtrl', ['$scope', '$sailsBind', '$q', '$http', 'toastr',
  function ($scope, $sailsBind, $q, $http, toastr) {
    $sailsBind.bind('api/employee', $scope);

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
