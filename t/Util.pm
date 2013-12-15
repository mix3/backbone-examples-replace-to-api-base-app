package t::Util;

use strict;
use warnings;
use Test::More;
use Todo::Web;
use Exporter 'import';
our @EXPORT_OK = qw/subtest_psgi/;

sub subtest_psgi {
	my $name = shift;
	my @args = @_;
	Test::More::subtest $name, sub {
		main::test_psgi(@args);
	};
}

sub setup_webapp {
	use Plack::Builder;
	my $root_dir = File::Basename::dirname(__FILE__) . "/..";
	my $app = Todo::Web->psgi($root_dir);
	builder {
		enable 'ReverseProxy';
		enable 'Static',
			path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
			root => $root_dir . '/public';
		$app;
	};
}

1;
