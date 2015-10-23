'use strict';

angular.module('exampleApp').controller('departmentsCtrl', ['$scope', '$sailsBind', '$q', '$http',
  function ($scope, $sailsBind, $q, $http) {
    $sailsBind.bind('api/department', $scope);

    $scope.updateName = function(department, data) {
      var d = $q.defer();

      if(data) {
        data = data.trim();
      }

      $http.put('api/department/' + department.id, {
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
