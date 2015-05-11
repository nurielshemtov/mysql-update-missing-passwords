#!/usr/bin/perl -w
use strict;
use DBI;
use Data::Dumper;
use vars qw/$debug $dry_run/;

$debug = 1 if $ENV{DEBUG};
$dry_run = 1 if $ENV{DRY_RUN};

my $username = 'root';
my $password = 'xxxx';
my $dsn = 'dbi:mysql:dbname=mysql';

my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1 })
  or die $DBI::errstr;

print STDERR "*** DRY RUN ***\n"
  if $dry_run;

my $sth = $dbh->prepare("SELECT User,Password FROM user WHERE Password != '' AND Host = 'localhost' AND User != 'root';");
$sth->execute();

while (my @row = $sth->fetchrow_array) {
  my ($username, $password) = @row;

  print STDERR "Query: UPDATE user SET Password = '$password' WHERE User = '$username' and Password = '';\n"
    if $debug;

  unless ( $dry_run ) {
    my $sth2 = $dbh->prepare("UPDATE user SET Password = '$password' WHERE User = '$username' and Password = '';");
    $sth2->execute();
  }
}

$sth->finish();
$dbh->disconnect();

