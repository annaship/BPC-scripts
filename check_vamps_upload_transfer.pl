#!/bioware/perl/bin/perl

use strict;
use warnings;
use List::Util qw(sum);
use File::Basename;

my $transfer_tables = 0;
my $previous_tables = 0;
my $script_name = basename($0);

# defalts:
my $host_name = "vampsdb";
my $db_name   = "vamps";

my $usage     = 
"
Compare number of rows in export files and the VAMPS database.
Usage: $script_name [-t -h -d -help]
-help : print this statment
-t : compare with _transfer tables
-h : host name (default vampsdb)
-d : database name (default vamps)
";


while ((scalar @ARGV > 0) && ($ARGV[0] =~ /^-/))
{
  if ($ARGV[0] =~ /-help/) 
  {
    print $usage;
    exit;
  } 
  elsif ($ARGV[0] eq "-t") 
  {
    shift @ARGV;
    $transfer_tables = 1;
  } 
  elsif ($ARGV[0] eq "-h") 
  {    
    shift @ARGV;
    $host_name = shift @ARGV;
  } 
  elsif ($ARGV[0] eq "-d") 
  {
    shift @ARGV;
    $db_name = shift @ARGV;
  } 
  elsif ($ARGV[0] =~ /^-/) 
  { #unknown parameter, just get rid of it
    print "Unknown commandline argument: $ARGV[0]\n";
    shift @ARGV;
  }
  
}

my $cur_dir = `pwd`;
print "Host = $host_name; Data Base = $db_name; Current dir = $cur_dir\n\n"; 

my $log_file_name     = "check_vamps_upload.log";
open(LOG, ">>$log_file_name") or warn "Unable to write to log file: $log_file_name. (" . (localtime) .")\n";

my @table_names       = ("vamps_data_cube", "vamps_export", "vamps_projects_datasets", "vamps_projects_info");
# my @table_names       = ("vamps_projects_datasets", "vamps_projects_info");
my $export_dir        = "exports/";
my %numbers_file_hash;
my %numbers_db_hash;

# count data in db
# count data in files
# compare

foreach my $table_name (@table_names)
{
  &print_twice("============ $table_name ============\n");  
  &count_data_in_db($table_name);
  &count_data_in_files($table_name);
}

# if compare_single_res() not called from count_data_in_files(), then uncomment that:
# &compare_res();  

# ================= Subs ===================
sub count_data_in_db()
{
  my $table_name = shift;
  my $full_table_name = $table_name;
  $full_table_name = $table_name."_transfer" if ($transfer_tables == 1); 
  
  &print_twice("Rows in table\t$full_table_name\t: ");
  my $db_res=`mysql -h $host_name $db_name -e "SELECT count(*) FROM $full_table_name" | grep -o [0-9]*`;
  &print_twice($db_res);
  
  $numbers_db_hash{$table_name} = $db_res;
}

sub count_data_in_files()
{
  my $file_name = shift;
  my $full_file_name = $export_dir . $file_name."_transfer";
  
  print_twice("Rows in file(s)\t$file_name*.txt\t: ");
  my $wc_res = `cat $full_file_name* | wc -l | awk '{print \$1}'`;
  
  # First line in a file has column names, delete it from counts
  my $files_amount = `ls -l $full_file_name* | wc -l`;
  my $files_res    = $wc_res - $files_amount;
  $numbers_file_hash{$file_name} = $files_res;
  
  print_twice("$files_res\n");
  
  compare_single_res($files_res, $file_name);
}

sub compare_single_res()
{
  my $txt_num  = shift;
  my $txt_name = shift;
  
  for my $table_name (keys %numbers_db_hash)
  {
    if ($txt_name eq $table_name)
    {
      my $db_num   = $numbers_db_hash{$table_name};
      if ( $txt_num > $db_num )
      {
        print_twice("Warning: Not all lines from file(s) $txt_name"."* made it into the database\n");        
      }
    }
  }
}

# Could be called separately, after filling out both hashes
sub compare_res()
{
  &print_twice("\n=========================================\n============ Compare results ============\n=========================================\n");
  for my $txt_name (keys %numbers_file_hash)
  {  
    for my $table_name (keys %numbers_db_hash)
    {
      if ($txt_name eq $table_name)
      {
        my $txt_num  = $numbers_file_hash{$txt_name};
        my $db_num   = $numbers_db_hash{$table_name};
        print_twice("For $table_name:\n");
        print_twice("Numbers in file = $txt_num" . "Numbers in db   = $db_num");
        if ( $txt_num > $db_num )
        {
          print_twice("Warning: Not all lines from file(s) $txt_name"."* made it into the database\n");        
        }
      }
    }
  }
}

sub print_twice()
{
  my $to_print = shift;
  print LOG $to_print;
  print $to_print;
}
