# package Pipeline_subs;
use Conjbpcdb;

#######################################
#
# db connection
# $vdbh = &db_connect("vampsdev", "vamps");
#
#######################################
sub db_connect() {
  my $db_host  = shift;
  my $db_name  = shift;
  my $condb = Conjbpcdb::new($db_host, $db_name); 
  my $condbh = $condb->dbh();
}

#######################################
#
# prepare sql statement
# $selectFlow_h = prep_query($dbh, "SELECT uncompress(flow) as flow FROM $inFlowTable WHERE read_id=?");
# 
#######################################

sub prep_query()
{
  my $dbh = shift;
  my $sql = shift || die("Please provide an sql statement");
  my $sql_prep = $dbh->prepare($sql) || die "Unable to prepare query: $sql\nError: " . $dbh->errstr . "\n";
  warn print LOG "YYY2: dbh = $dbh; sql = $sql; sql_prep = $sql_prep\n";
      
}

#######################################
#
# prepare and execute sql statement
# prep_exec_query ($dbh, $sql)
#
#######################################

sub prep_exec_query()
{
  my $dbh = shift;
  my $sql = shift || die("Please provide an sql statement");
  my $sql_prep = $dbh->prepare($sql) || die "Unable to prepare query: $sql\nError: " . $dbh->errstr . "\n";    
  my $rows_affected = $sql_prep->execute() || die "Unable to execute MySQL statement: $sql\nError: " . $dbh->errstr . "(" . (localtime) . ")\n";  
  warn $DBI::errstr if $DBI::err;
  return $DBI::errstr if $DBI::err;
  return $rows_affected;
}

#######################################
#
# prepare and execute sql statement
# prep_exec_query ($dbh, $exec_arg, $sql)
#
#######################################

sub prep_exec_query_w_arg()
{
  my $dbh      = shift;
  my $exec_arg = shift;
  my $sql      = shift || die("Please provide an sql statement");
  my $sql_prep = $dbh->prepare($sql) || die "Unable to prepare query: $sql\nError: " . $dbh->errstr . "\n";    
  my $rows_affected = $sql_prep->execute($exec_arg) || die "Unable to execute MySQL statement: $sql\nError: " . $dbh->errstr . "(" . (localtime) . ")\n";  
  return $rows_affected;
}

#######################################
#
# fetchrow after preparing and executing sql statement
# my $run_id = &prep_exec_fetch_query($dbh, "SELECT run_id from $run_table where run='" . $run ."'");
# 
#######################################

sub prep_exec_fetch_query()
{
  my $dbh = shift;
  my $sql = shift || die("Please provide an sql statement");
  my $sql_prep = $dbh->prepare($sql) || die "Unable to prepare MySQL statement: $sql\n. Error: " . $dbh->errstr . "\n";    
  $sql_prep->execute() || die "Unable to execute MySQL statement: $sql. Error: " . $dbh->errstr . "\n";
  my $result = $sql_prep->fetchrow();
  return $result;
}

#######################################
#
# fetchrow_ARRAY after preparing and executing sql statement
# my $missed_read_ids_list = &prep_exec_fetchrow_array_query($dbhVamps, "SELECT read_id FROM $read_id_table");
# 
#######################################
# commented out because not called form the vamps_upload, don't know why. ASh
# sub prep_exec_fetchrow_array_query()
# {
#   my @result;
#   print "III222: in prep_exec_fetchrow_array_query\n";
#   my $dbh = shift;
#   my $sql = shift || die("Please provide an sql statement");
#   my $sql_prep = $dbh->prepare_cached($sql) || die "Unable to prepare MySQL statement: $sql\n. Error: " . $dbh->errstr . "\n";    
#   $sql_prep->execute() || die "Unable to execute MySQL statement: $sql. Error: " . $dbh->errstr . "\n";
#   while (my @data = $sql_prep->fetchrow_array()) 
#   {
#     push @result, @data;
#   }
#   
#   return @result;
# }

#######################################
#
# run mysqlimport to insert file into a table
#
# Usage: &insert_file_into_table(sqlImportCmd=>$sqlImportCmd, replace=>$replace, columns=>$columns, out_filename=>$tax_assignment_tmp_filename, log_filename=>$log_filename);

#######################################

sub insert_file_into_table()
{
  # if some parameters are not provided, use default:
  my %defaults     = (sqlImportCmd=>"/usr/local/mysql/bin/mysqlimport", replace=>"", db_host=>"bpcdb1", db_name=>"env454");
  my %args         = (%defaults, @_);
  my $sqlImportCmd = $args{sqlImportCmd};  
  my $replace      = $args{replace};  
  my $columns      = $args{columns}; 
  my $db_host			 = $args{db_host};
  my $db_name			 = $args{db_name};
  my $out_filename = $args{out_filename};  
  my $log_filename = $args{log_filename};
  
  my $sqlCmd       = "$sqlImportCmd -C -v -L $replace $columns -h $db_host $db_name $out_filename >> $log_filename";
  warn print LOG "$sqlCmd\n";
  my $sqlErr       = system($sqlCmd);
  if ($sqlErr) { warn print LOG "Unable to execute MySQL statement: $sqlCmd.  Error:  $sqlErr (" . (localtime) . ")\n"; }
  return $sqlErr;
}

# strip whitespace 
sub trim()
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

1; # need to end with a true value
