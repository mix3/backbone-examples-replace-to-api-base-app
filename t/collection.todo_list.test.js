var requirejs = require(__dirname + '/helper');

describe('TodoList', function() {
	var g = {};
	beforeEach(function(done) {
		requirejs(["js/collection/TodoList"], function(TodoList) {
			g.todoList = new TodoList();
			g.todoList.add([
				{title: "todo-1", done: false},
				{title: "todo-2", done: false},
				{title: "todo-3", done: false},
				{title: "todo-4", done: true },
			]);
			sinon.spy($, "ajax");
			done();
		});
	});
	afterEach(function(done) {
		$.ajax.restore();
		done();
	});
	it('where', function(done) {
		chai.assert.ok(g.todoList.done().length == 1);
		chai.assert.ok(g.todoList.remaining().length == 3);
		done();
	});
});
