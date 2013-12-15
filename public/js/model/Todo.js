//if (typeof define !== 'function') { var define = require('amdefine')(module) }

define(["backbone"], function(Backbone) {
	'use strict';

	var Todo = Backbone.Model.extend({
		defaults: function() {
			return {
				title: "empty todo...",
				done:  false,
			};
		},
		toggle: function() {
			this.save({done: !this.get("done")});
		},
	});

	return Todo;
});
