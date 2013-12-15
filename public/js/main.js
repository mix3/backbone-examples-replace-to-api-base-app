requirejs.config({
	baseUrl: "..",
	paths: {
		jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min",
		underscore: "lib/underscore",
		backbone: "lib/backbone",
	},
	shim: {
		jquery: {
			exports: "jQuery",
		},
		underscore: {
			exports: "_",
		},
		backbone: {
			deps: ["jquery", "underscore"],
			exports: "Backbone",
		},
	},
});

define(
	["js/view/AppView"],
	function (AppView) {
		'use strict';
		window.App = new AppView();
	}
);
