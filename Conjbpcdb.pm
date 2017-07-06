package Conjbpcdb;

use strict;
use warnings;
use DBI;

our $VERSION = '0.01';

sub new 
{
	my $self = {};
	my $hostname = shift;
	my $database = shift;
	my $db_info = shift;
	my $version = "mysql5";
	
	# Set up defaults that will be used when called without a config file (.dbconf) and/or arguments.
	$self->{DRIVER} = "mysql";
	$self->{HOSTNAME} = "bpcdb1";
	$self->{PORT} = "3306";
	$self->{DATABASE} = "env454";
	$self->{USER} = "env454_ref_ro";
	$self->{PASSWORD} = "env454_ref_ro";

	#	if ($database =~ /^mysql4\./) 
	#	{
	#		$version = "mysql4";
	#		$database =~ s/^mysql4.//;
	#	}

	
	my $userconf = `echo ~/.dbconf`;
    	#if ($hostname) {$userconf = `echo ~/.$hostname`;}
	chomp ($userconf);

	if (-f $userconf) 
	{
		#/
		open (CONF, "<$userconf");
		my $user = <CONF>;
		chomp($user);
		my $password = <CONF>;
		chomp($password);

		if ($hostname) {
        		$self->{HOSTNAME} = $hostname;
		}
		if ($database) {
        		$self->{DATABASE} = $database;
		}
        	$self->{USER} = $user;
        	$self->{PASSWORD} = $password;

	} elsif($ENV{MBLPIPE_DBFILE}) {
		my $option_hash;
		$option_hash = process_options_file($ENV{MBLPIPE_DBFILE});
		
		$self->{DRIVER}   = $option_hash->{'driver'};
		$self->{HOSTNAME} = $option_hash->{hostname};
		$self->{PORT}     = $option_hash->{port};
		$self->{USER}     = $option_hash->{user};
		$self->{PASSWORD} = $option_hash->{password};

	} else {
		if ($database) {
			warn "Warning: Ignoring database argument since you are lacking a .dbconf file.";
		}
		if ($hostname) {
			$self->{HOSTNAME} = $hostname;
		}
		warn "\nUsing read-only access to database ". $self->{DATABASE} . " on host " . $self->{HOSTNAME};
		#warn "\nUnable to connect to the database, please contact your database administrator for access privileges\n\n";
	}

	#$self->{DATABASE} = $database;
	bless($self);
	return $self;
}

sub dbh
{
    my $self = shift;
    if(@_)
    {
        $self->{DBH} = shift;
    } else
    {    
    
          
        my $dsn =   "DBI:" . $self->{DRIVER} .
                    ":database=" . $self->{DATABASE} .
                    ";host=" . $self->{HOSTNAME} .  
                    ";port=" . $self->{PORT};
        #print "dsn $dsn\n";       
        my $dbh = DBI->connect($dsn, $self->{USER}, $self->{PASSWORD}) or return 0;
        $dbh->{mysql_auto_reconnect} = 1;
        $self->{DBH} = $dbh;
    }

    return $self->{DBH};
}


