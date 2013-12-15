//if (typeof define !== 'function') { var define = require('amdefine')(module) }

define(["backbone", "js/model/Todo"], function(Backbone, Todo) {
	'use strict';

	var TodoList = Backbone.Collection.extend({
		model: Todo,

		url: '/todo',

		comparator: 'id',

		done: function() {
			return this.where({done: true});
		},

		remaining: function() {
			return this.where({done: false});
		},
	});

	return TodoList;
});
