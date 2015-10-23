'use strict';

var vApp = angular.module('exampleApp', ['ngTouch', 'ui.router', 'ui.bootstrap', 'ngAnimate', 'angular-loading-bar', 'toastr', 'xeditable', , 'ngSailsBind'])
  .config(['$urlRouterProvider', function ($urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
  }])
  .config(['cfpLoadingBarProvider', function(cfpLoadingBarProvider) {
    cfpLoadingBarProvider.latencyThreshold = 250;
  }])
  .run(['editableOptions', 'editableThemes', function(editableOptions, editableThemes) {
    editableThemes.bs3.inputClass = 'input-sm';
    editableThemes.bs3.buttonsClass = 'btn-sm';
    editableOptions.theme = 'bs3';
  }]);
