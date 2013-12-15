var requirejs = require('requirejs');
requirejs.config({
	baseUrl: __dirname + "/../public",
	nodeRequire: require,
});
jsdom = require("jsdom").jsdom;
global.document = jsdom();
global.window = global.document.parentWindow;
global.navigator = window.navigator;
global.Backbone = require('backbone');
global.Backbone.$ = global.$ = require('jquery');
global._ = require('underscore');
global.chai = require('chai');
global.sinon = require('sinon');
window = global.window;

module.exports = requirejs;
