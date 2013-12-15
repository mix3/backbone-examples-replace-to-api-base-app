//if (typeof define !== 'function') { var define = require('amdefine')(module) }

define(["backbone", "js/view/TodoView", "js/collection/TodoList"], function(Backbone, TodoView, TodoList) {
	'use strict';

	var AppView = Backbone.View.extend({
		el: $("#todoapp"),

		statsTemplate: _.template($('#stats-template').html()),

		events: {
			"keypress #new-todo"     : "createOnEnter",
			"click #clear-completed" : "clearCompleted",
			"click #toggle-all"      : "toggleAllComplete",
		},

		initialize: function() {
			this.input = this.$("#new-todo");
			this.allCheckbox = this.$("#toggle-all")[0];
			this.todoList = new TodoList();
			this.listenTo(this.todoList, 'add', this.addOne);
			this.listenTo(this.todoList, 'reset', this.addAll);
			this.listenTo(this.todoList, 'all', this.render);
			this.footer = this.$('footer');
			this.main = $('#main');
			this.todoList.fetch();
		},

		render: function() {
			var done = this.todoList.done().length;
			var remaining = this.todoList.remaining().length;
			if (this.todoList.length) {
				this.main.show();
				this.footer.show();
				this.footer.html(this.statsTemplate({done: done, remaining: remaining}));
			} else {
				this.main.hide();
				this.footer.hide();
			}
			this.allCheckbox.checked = !remaining;
		},

		addOne: function(todo) {
			var view = new TodoView({model: todo});
			this.$("#todo-list").append(view.render().el);
		},

		addAll: function() {
			this.todoList.each(this.addOne, this);
		},

		createOnEnter: function(e) {
			if (e.keyCode != 13) return;
			if (!this.input.val()) return;
			this.todoList.create({title: this.input.val()});
			this.input.val('');
		},

		clearCompleted: function() {
			_.invoke(this.todoList.done(), 'destroy');
			return false;
		},

		toggleAllComplete: function () {
			var done = this.allCheckbox.checked;
			this.todoList.each(function (todo) { todo.save({'done': done}); });
		},
	});

	return AppView;
});
