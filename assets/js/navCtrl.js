'use strict';

angular.module('exampleApp').config(['$stateProvider',
  function($stateProvider) {
    $stateProvider
      .state('root', {
        abstract: true,
        ontroller: 'navCtrl',
        templateUrl: 'view/navbar.html',
      })
      .state('root.home', {
        url: '/',
        templateUrl: 'view/home.html'
      })
      .state('root.employees', {
        url: '/employees',
        ontroller: 'employeesCtrl',
        templateUrl: 'view/employees.html',
      })
      .state('root.departments', {
        url: '/departments',
        ontroller: 'departmentsCtrl',
        templateUrl: 'view/departments.html',
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
