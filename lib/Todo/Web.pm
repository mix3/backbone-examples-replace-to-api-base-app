package Todo::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBIx::Sunny;
use Time::Piece;
use Try::Tiny;

sub now { localtime->strftime("%Y-%m-%d %H:%M:%S") }

sub prejson {
	my ($app, $row) = @_;
	return {
		id    => $row->{id},
		title => $row->{title},
		done  => $row->{done} ?
			Types::Serialiser::true  :
			Types::Serialiser::false ,
	};
}

sub prejsons {
	my ($app, $rows) = @_;
	my @ret = ();
	for my $row (@$rows) {
		push @ret, {
			id    => $row->{id},
			title => $row->{title},
			done  => $row->{done} ?
				Types::Serialiser::true  :
				Types::Serialiser::false ,
		};
	}
	return \@ret;
}

sub dbh {
	my $app = shift;
	$app->{_dbh} ||= do {
		my $dbh = DBIx::Sunny->connect("dbi:SQLite:dbname=:memory:");
		$dbh->query(q{
CREATE TABLE IF NOT EXISTS todo (
	id         INTEGER PRIMARY KEY AUTOINCREMENT,
	title      TEXT    NOT NULL,
	done       INTEGER NOT NULL,
	created_at TEXT    NOT NULL,
	updated_at TEXT    NOT NULL,
	deleted_at TEXT        NULL
);
		});
		$dbh;
	};
}

get '/todo' => sub {
	my ($self, $c) = @_;
	try {
		my $rows = $self->dbh->select_all(
			q{SELECT * FROM todo WHERE deleted_at IS NULL}
		);
		$c->render_json($self->prejsons($rows));
	} catch {
		$c->halt(500);
	}
};

post '/todo' => sub {
	my ($self, $c) = @_;
	$c->env->{"kossy.request.parse_json_body"} = 1;
	my $title = $c->req->param('title');
	my $done  = $c->req->param('done');
	try {
		my $now = $self->now;
		$self->dbh->query(q{
			INSERT INTO todo
				(title, done, created_at, updated_at)
			VALUES
				(?, ?, ?, ?)
		}, $title, $done, $now, $now);
		my $row = $self->dbh->select_row (
			q{SELECT * FROM todo WHERE id = ? AND deleted_at IS NULL},
			$self->dbh->sqlite_last_insert_rowid(),
		);
		$c->render_json($self->prejson($row));
	} catch {
		$c->halt(500);
	}
};

get '/todo/:id' => sub {
	my ($self, $c) = @_;
	my $id = $c->args->{id};
	try {
		my $row = $self->dbh->select_row(q{
			SELECT *
			FROM todo
			WHERE id = ?
			AND deleted_at IS NULL
		}, $id);
		die unless ($row);
		$c->render_json($self->prejson($row));
	} catch {
		$c->halt(500);
	}
};

router PUT => '/todo/:id' => sub {
	my ($self, $c) = @_;
	$c->env->{"kossy.request.parse_json_body"} = 1;
	my $id    = $c->args->{id};
	my $title = $c->req->param('title');
	my $done  = $c->req->param('done');
	try {
		my $now = $self->now;
		my $ret = $self->dbh->query(q{
			UPDATE todo
			SET
				title = ?,
				done = ?,
				updated_at = ?
			WHERE id = ?
			AND deleted_at IS NULL
		}, $title, $done, $now, $id);
		die if ($ret eq '0E0');
		my $row = $self->dbh->select_row(
			q{SELECT * FROM todo WHERE id = ? AND deleted_at IS NULL}, $id,
		);
		$c->render_json($self->prejson($row));
	} catch {
		$c->halt(500);
	}
};

router DELETE => '/todo/:id' => sub {
	my ($self, $c) = @_;
	my $id = $c->args->{id};
	try {
		my $row = $self->dbh->select_row(
			q{SELECT * FROM todo WHERE id = ? AND deleted_at IS NULL}, $id,
		);
		my $now = $self->now;
		my $ret = $self->dbh->query(
			q{UPDATE todo SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL},
			$now, $id,
		);
		die if ($ret eq '0E0');
		$c->render_json($self->prejson($row));
	} catch {
		$c->halt(500);
	}
};

get '/' => sub {
	my ($self, $c) = @_;
	$c->render('index.tx');
};

1;
