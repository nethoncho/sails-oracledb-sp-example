'use strict';

angular.module('exampleApp').config(['$stateProvider',
  function($stateProvider) {
    $stateProvider
      .state('root', {
        abstract: true,
        controller: 'navCtrl',
        templateUrl: 'view/navbar.html',
      })
      .state('root.home', {
        url: '/',
        templateUrl: 'view/home.html'
      })
      .state('root.employees', {
        url: '/employees',
        controller: 'employeesCtrl',
        templateUrl: 'view/employees.html'
      })
      .state('root.departments', {
        url: '/departments',
        controller: 'departmentsCtrl',
        templateUrl: 'view/departments.html',
        resolve: {
          locations: ['$http', function ($http) {
            return $http.get('api/location').then(function (data) {
              return data.data;
            });
          }]
        }
      });
  }
]);

angular.module('exampleApp').controller('navCtrl', ['$scope',
  function ($scope) {
    $scope.nav = {
      navCollapsed: true
    };
  }
]);
