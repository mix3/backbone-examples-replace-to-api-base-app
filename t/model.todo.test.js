var requirejs = require(__dirname + '/helper');

describe('Todo', function() {
	var g = {};
	beforeEach(function(done) {
		requirejs(["js/model/Todo"], function(Todo) {
			g.todo = new Todo();
			g.todo.url = '/todo';
			sinon.spy($, "ajax");
			done();
		});
	});
	afterEach(function(done) {
		$.ajax.restore();
		done();
	});
	it('default', function(done) {
		chai.assert.equal(g.todo.get('title'), 'empty todo...');
		chai.assert.notOk(g.todo.get('done'));
		done();
	});
	it('toggle', function(done) {
		g.todo.toggle();
		chai.assert.ok(g.todo.get('done'));
		chai.assert.ok($.ajax.calledOnce);
		g.todo.toggle();
		chai.assert.notOk(g.todo.get('done'));
		chai.assert.ok($.ajax.calledTwice);
		g.todo.toggle();
		chai.assert.ok(g.todo.get('done'));
		chai.assert.ok($.ajax.calledThrice);
		done();
	});
});
