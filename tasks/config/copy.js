/**
 * Copy files and folders.
 *
 * ---------------------------------------------------------------
 *
 * # dev task config
 * Copies all directories and files, exept coffescript and less fiels, from the sails
 * assets folder into the .tmp/public directory.
 *
 * # build task config
 * Copies all directories nd files from the .tmp/public directory into a www directory.
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-copy
 */
module.exports = function(grunt) {

	grunt.config.set('copy', {
		dev: {
			files: [{
				expand: true,
				cwd: './assets',
				src: ['**/*.!(coffee|less)'],
				dest: '.tmp/public'
			},{
				expand: true,
				cwd: './bower_components',
				src: [
					'angular/angular.js',
					'angular-touch/angular-touch.js',
					'angular-animate/angular-animate.js',
					'angular-loading-bar/build/loading-bar.js',
					'angular-toastr/dist/angular-toastr.tpls.js',
					'angular-bootstrap/ui-bootstrap-tpls.js',
					'ui-router/release/angular-ui-router.js',
					'angular-xeditable/dist/js/xeditable.js',
					'lodash/lodash.js',
				],
				flatten: true,
				dest: '.tmp/public/js/dependencies'
			},{
				expand: true,
				cwd: './bower_components',
				src: [
				        'bootstrap/dist/css/bootstrap.css',
				        'angular-loading-bar/build/loading-bar.css',
					'angular-toastr/dist/angular-toastr.css',
					'font-awesome/css/font-awesome.css',
					'font-awesome/css/font-awesome.css.map',
					'angular-xeditable/dist/css/xeditable.css'
				],
				flatten: true,
				dest: '.tmp/public/styles'
			},{
				expand: true,
				cwd: './bower_components',
				src: [
				        'bootstrap/dist/fonts/*',
					'font-awesome/fonts/*'
				],
				flatten: true,
				dest: '.tmp/public/fonts'
			}]
		},
		build: {
			files: [{
				expand: true,
				cwd: '.tmp/public',
				src: ['**/*'],
				dest: 'www'
			}]
		}
	});

	grunt.loadNpmTasks('grunt-contrib-copy');
};
