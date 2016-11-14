'use strict';

angular.module('exampleApp').controller('departmentsCtrl', ['$scope', '$sailsBind', '$q', '$http', 'locations',
  function ($scope, $sailsBind, $q, $http, locations) {
    $scope.locations = locations;
    $sailsBind.bind('api/department', $scope);

    $scope.getLocationCity = function(id) {
      return _.find($scope.locations, {'id': id}).city;
    };

    $scope.updateName = function(department, data) {
      var d = $q.defer();

      if(data) {
        data = data.trim();
      }

      $http.put('api/department/' + department.id, {
        name: data
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

    $scope.updateLocation = function(department, data) {
      var d = $q.defer();

      if(data) {
        data = data.trim();
      }

      $http.put('api/department/' + department.id, {
        location: data
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
