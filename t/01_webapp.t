use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw/GET POST PUT DELETE/;
use t::Util qw/subtest_psgi/;
use JSON::XS;
use Test::Deep;
use Test::Deep::Matcher;

my $app = t::Util::setup_webapp();

subtest_psgi "read empty",
	app => $app,
	client => sub {
		my $cb = shift;
		my $res = $cb->(GET "http://localhost/todo");
		is $res->code => 200;
		my $r = decode_json( $res->content );
		cmp_deeply $r => [];
	};

subtest_psgi "create and read",
	app => $app,
	client => sub {
		my $cb = shift;
		{
			my $content = encode_json({
				title => "hoge",
				done  => Types::Serialiser::false,
			});
			my $req = POST "http://localhost/todo";
			$req->header("Content-Type" => "application/json");
			$req->header("Content-Length" => length($content));
			$req->content($content);
			my $res = $cb->($req);
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => {
				id    => 1,
				title => "hoge",
				done  => Types::Serialiser::false,
			};
		}
		{
			my $content = encode_json({
				title => "bar",
				done  => Types::Serialiser::false,
			});
			my $req = POST "http://localhost/todo";
			$req->header("Content-Type" => "application/json");
			$req->header("Content-Length" => length($content));
			$req->content($content);
			my $res = $cb->($req);
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => {
				id    => 2,
				title => "bar",
				done  => Types::Serialiser::false,
			};
		}
		{
			my $res = $cb->(GET "http://localhost/todo");
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => [
				{ id => 1, title => "hoge", done => Types::Serialiser::false },
				{ id => 2, title => "bar",  done => Types::Serialiser::false },
			];
		}
		{
			my $res = $cb->(GET "http://localhost/todo/1");
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => { id => 1, title => "hoge", done => Types::Serialiser::false };
		}
		{
			my $res = $cb->(GET "http://localhost/todo/2");
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => { id => 2, title => "bar",  done => Types::Serialiser::false };
		}
	};

subtest_psgi "update",
	app => $app,
	client => sub {
		my $cb = shift;
		{
			my $content = encode_json({
				title => "ypaaa!!",
				done  => Types::Serialiser::true,
			});
			my $req = PUT "http://localhost/todo/99999";
			$req->header("Content-Type" => "application/json");
			$req->header("Content-Length" => length($content));
			$req->content($content);
			my $res = $cb->($req);
			is $res->code => 500;
		}
		{
			my $content = encode_json({
				title => "ypaaa!!",
				done  => Types::Serialiser::true,
			});
			my $req = PUT "http://localhost/todo/1";
			$req->header("Content-Type" => "application/json");
			$req->header("Content-Length" => length($content));
			$req->content($content);
			my $res = $cb->($req);
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => {
				id => 1, title => "ypaaa!!", done => Types::Serialiser::true,
			};
		}
	};

subtest_psgi "delete",
	app => $app,
	client => sub {
		my $cb = shift;
		{
			my $req = DELETE "http://localhost/todo/99999";
			my $res = $cb->($req);
			is $res->code => 500;
		}
		{
			my $req = DELETE "http://localhost/todo/1";
			my $res = $cb->($req);
			is $res->code => 200;
			my $r = decode_json( $res->content );
			cmp_deeply $r => {
				id => 1, title => "ypaaa!!", done => Types::Serialiser::true
			};
		}
		{
			my $res = $cb->(GET "http://localhost/todo/1");
			is $res->code => 500;
		}
		{
			my $content = encode_json({
				title => "piyo!!",
				done  => Types::Serialiser::false,
			});
			my $req = PUT "http://localhost/todo/1";
			$req->header("Content-Type" => "application/json");
			$req->header("Content-Length" => length($content));
			$req->content($content);
			my $res = $cb->($req);
			is $res->code => 500;
		}
	};

done_testing;
