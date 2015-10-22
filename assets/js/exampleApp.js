'use strict';

var vApp = angular.module('exampleApp', ['ngTouch', 'ui.router', 'ui.bootstrap', 'ngAnimate', 'angular-loading-bar', 'toastr', 'xeditable'])
  .config(['$urlRouterProvider', function ($urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
  }]);
