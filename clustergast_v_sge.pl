#!/usr/bin/env perl

#########################################
#
# clustergast: imports blast data to database and runs gast 
#
# Author: Susan Huse, shuse@mbl.edu
#
# Date: Tue Jan  9 06:55:53 EST 2007
#
# Keywords: cluster GAST refssu
# 
# Assumptions: 
#
# Revisions:
#			2007, Oct 29 -- removed -qEG parameters from clusterblast, holdovers from distal trim
#           2010, Apr 1 -- added reftable conversion for v6v4 -> v4v6
#           2010, July 2 -- converted from using blast, muscle and bestalign, to using UClust for 
#                           finding nearest reference
#
#	    2014, July 22 -- use module to get the correct usearch
#
# Programming Notes:
#
########################################
use strict;
use warnings;
use Conjbpcdb;
use File::Temp qw/ tempfile /;
use Cwd;
require 'pipeline_subs.pl';

#######################################
# -------- Table of Content ---------
# Set up usage statement
# Definition statements
# Test for commandline arguments
# Parse commandline arguments, ARGV
# Set up file names and table names
# Export the fasta and unique it
# UClust the data
# ----- Prepare the GAST table in the database
# ----- Split the uniques fasta and run UClust per node
# Clean up and close out
#######################################



#######################################
#
# Set up usage statement
#
#######################################
my $scriptHelp = "
 clustergast - runs the GAST pipeline on the cluster
               GAST uses UClust to identify the best matches of a read sequence
               to references sequences in a reference database.
\n";

my $usage = "
   Usage:  clustergast -r run -reg variableregion -trim trim_table -n nodes -start step
      ex:  clustergast -r 20070920  -reg v6

   options:  
             -r           FLX data run to be gasted
             -reg         source field [default: v6]
             -trim        table containing trimmed sequences to gast [default: trimseq]
             -n           number of nodes to split to [default: 100]
             -start       where to pick up a regast run [default: db2fasta]
             -w           where string 
             -reftable    alternative reference database [default: refhvr_\$source]
             -refdb       (refudb for usearch) 
             -gt          alternative gast table [default: gast_rundate_\$source]
             -mh          maximum number of reference hits to store [default: 15]
             -pctid       minimum percent identity of the read to a reference to be considered a hit [default: 0.70]
             -ignoreterm  ignore terminal gaps when checking for large indels [default: don't ignore] (http://www.drive5.com/usearch/manual/aln_params.html)
             -strand      plus or both [default: plus]
             -refhvr_db_dir alternative directory with refhvr fasta and tax files (use '/' ate the end)
   steps:  db2fasta, unique, usearch

\n";
             #-blast       alternative blast database [default: refhvr_\$source]
             #-bt          alternative blast table [default: refhvr_\$source]

#######################################
#
# Definition statements
#
#######################################
#Commandline parsing
my $verbose = 0;

#Runtime variables
my $run					  = "";
my $db_name				= "env454";
my $db_host       = "bpcdb1";
# my $trim_table    = "trimseq_temp";
my $trim_table		= "trimseq";
my $trimsequence_table = "trimsequence";
my $nodes					= 100;
my $log_file			= "clustergast.log";
my $refhvr_udb;
# (= refv3v5.udb or refv4v6.udb)
#my $refhvr_udb_dir = "/xraid2-2/g454/blastdbs/";
my $refhvr_udb_dir = "/xraid2-2/g454/blastdbs/gast_distributions/";
my $vRegion				= "v6";
my $vref_table;
my $start					= "db2fasta";
my $termGapStr    = "";
my $where					= "";
my $tmpDir				= "/usr/local/tmp/";
my $rand_file			= "_" . int(rand(999)) . "_";
my $qsub_prefix		= "clustergast_sub_";
my $node_name;

my $run_table			= "run";
my $dna_region_table = "dna_region";
my $idField				= "read_id";
my $sequence_field = "sequence_comp";
my $facount				= 2000;
my $quitAfterBlast= 0;
my $blast_table;
my $gast_table;
my $max_accepts		= 15;
my $max_rejects		= 0;
my $pctid_threshold	= 0.70;
my $ignoreterm    = 0;
my $gapopen       = "6I/1E";
my $strand        = "plus";


## todo: uncommented!
my $sqlimport_cmd = "/usr/local/mysql/bin/mysqlimport";
# my $sqlimport_cmd = "";
# "/usr/local/mysql/bin/mysqlimport";
my $usearch_exe   = "vsearch";
my $tortured_soul	= "ashipunova\@mbl.edu";

#######################################
#
# Test for commandline arguments
#
#######################################

if (! $ARGV[0] ) 
{
	print $scriptHelp;
	print $usage;
	exit -1;
} 
my $clustergast_cmd = join(" ", $0, @ARGV);

if ($verbose)
{
  print "AAA \$ARGV: ";
  print $ARGV;
  print "\n";
}
while ((scalar @ARGV > 0) && ($ARGV[0] =~ /^-/))
{
	if ($ARGV[0] =~ /-h/) {
		print $scriptHelp;
		print $usage;
		exit 0;
	} elsif ($ARGV[0] eq "-reftable") {
		shift @ARGV;
		$vref_table = shift @ARGV;
	} elsif ($ARGV[0] eq "-refudb") {
		shift @ARGV;
		$refhvr_udb = shift @ARGV;
	} elsif ($ARGV[0] eq "-refdb") {
		shift @ARGV;
		$refhvr_udb = shift @ARGV;
	} elsif ($ARGV[0] eq "-refhvr_db_dir") {
		shift @ARGV;
		$refhvr_udb_dir = shift @ARGV;
	} elsif ($ARGV[0] eq "-reg") {
		shift @ARGV;
		$vRegion = shift @ARGV;
	} elsif ($ARGV[0] eq "-r" ) {
		shift @ARGV;
		$run = shift @ARGV;
	} elsif ($ARGV[0] eq "-trim") {
		shift @ARGV;
		$trim_table = shift @ARGV;
	} elsif ($ARGV[0] eq "-gt") {
		shift @ARGV;
		$gast_table = shift @ARGV;
	} elsif ($ARGV[0] eq "-start") {
		shift @ARGV;
		$start = shift @ARGV;
	} elsif ($ARGV[0] eq "-n") {
		shift @ARGV;
		$nodes = shift @ARGV;
	} elsif ($ARGV[0] eq "-w") {
		shift @ARGV;
		$where = shift @ARGV;
	} elsif ($ARGV[0] eq "-d") {
		shift @ARGV;
		$db_name = shift @ARGV;
	} elsif ($ARGV[0] eq "-pctid") {
		shift @ARGV;
		$pctid_threshold = shift @ARGV;
	} elsif ($ARGV[0] eq "-mh") {
		shift @ARGV;
		$max_accepts = shift @ARGV;
	} elsif ($ARGV[0] eq "-strand") {
		shift @ARGV;
		$strand = shift @ARGV;
	} elsif ($ARGV[0] eq "-ignoreterm") {
		shift @ARGV;
		$ignoreterm = 1;
	} elsif ($ARGV[0] eq "-v") {
		$verbose = 1;
		shift @ARGV;
	} elsif ($ARGV[0] =~ /^-/) { #unknown parameter, just get rid of it
		print "Unknown commandline flag \"$ARGV[0]\".\n";
		print $usage;
		exit -1;
	}
}


#######################################
#
# Parse commandline arguments, ARGV
#
#######################################

if (! $vRegion) 
{
	print "Need to specify a source hypervariable region.\n";
	print "$usage\n";
	exit;
} 

if ( (! $run)  && (! $where) )
{
	print "Need to specify a run or a where statement\n";
	print "$usage\n";
	exit;
} 
# That's important especially for ITC
$vRegion = lc($vRegion);

my $file_prefix;
if ($where) 
{
	my $theDate = `date +%Y%m%d`;
	chomp $theDate;
	my $randSuffix = rand();
	$randSuffix = int($randSuffix * 100000);
	$file_prefix = join("_", $theDate, $randSuffix);
} else {
	$file_prefix = $run . "_" . $vRegion;
}

if ($verbose)
{
  print("\n=======\n");
	print("\$run = $run\n");
	print("\$db_name = $db_name\n");
	print("\$db_host = $db_host\n");
	print("\$trim_table = $trim_table\n");
	print("\$trimsequence_table = $trimsequence_table\n");
	print("\$nodes = $nodes\n");
	print("\$log_file = $log_file\n");
	print("\$refhvr_udb = $refhvr_udb\n");
	print("\$refhvr_udb_dir = $refhvr_udb_dir\n");
	print("\$vRegion = $vRegion\n");
	print("\$vref_table = $vref_table\n");
	print("\$start = $start\n");
	print("\$termGapStr = $termGapStr\n");
	print("\$where = $where\n");
	print("\$tmpDir = $tmpDir\n");
	print("\$rand_file = $rand_file\n");
	print("\$qsub_prefix = $qsub_prefix\n");
	print("\$node_name = $node_name\n");

	print("\$run_table = $run_table\n");
	print("\$dna_region_table = $dna_region_table\n");
	print("\$idField = $idField\n");
	print("\$sequence_field = $sequence_field\n");
	print("\$facount = $facount\n");
	print("\$quitAfterBlast = $quitAfterBlast\n");
	print("\$blast_table = $blast_table\n");
	print("\$gast_table = $gast_table\n");
	print("\$max_accepts = $max_accepts\n");
	print("\$max_rejects = $max_rejects\n");
	print("\$pctid_threshold = $pctid_threshold\n");
	print("\$ignoreterm = $ignoreterm\n");
	print("\$gapopen = $gapopen\n");
	print("\$strand = $strand\n");
  print("\n=======\n");
}
# =====
my $dbh = &db_connect($db_host, $db_name);

# Get run_id
my $run_id = &prep_exec_fetch_query($dbh, "SELECT run_id from $run_table where run='" . $run ."'");

# Create the where clause
if (! $where) 
{
	$where = "WHERE run_id = '" . $run_id . "' and dna_region = '" . $vRegion . "'";
}

if ( ($where) && ($where !~ /dna_region\s+=/) ) {
	$where .= " AND dna_region = '" . $vRegion . "'";
}

if ( ($where) && ($run_id) && ($where !~ /run_id\s+=/) ) {
	$where .= " AND run_id = '" . $run_id . "'";
}
	
$where =~ s/where//i;
$where = "WHERE $where";

#######################################
#
# Set up file names and table names
#
#######################################

my $fasta_filename = $file_prefix . ".fa";
my $fasta_uniqs_filename = $file_prefix . ".unique.fa";
my $usearch_filename = $file_prefix . ".uc";

if (! $gast_table) { $gast_table = "gast_" . $file_prefix; }

my $whereFilename = $file_prefix . "_where.sql";

my $vRegion53 = $vRegion;
# If source is 3'-5' (e.g., v6v4) than need to flip for reference table name
if ($vRegion =~ /v[0-9]v[0-9]/i)
{
    my $region_a = $vRegion;
    my $region_b = $vRegion;
    $region_a =~ s/v([0-9])v([0-9]).*/$1/i;
    $region_b =~ s/v([0-9])v([0-9]).*/$2/i;
    if ($region_b < $region_a)
    {
        $vRegion53 = "v" . $region_b . "v" . $region_a;
    }
    if (length($vRegion53) < length($vRegion) )
    {
        $vRegion53 .= substr($vRegion, length($vRegion53));
    }
}

# if (! $refhvr_udb) { $refhvr_udb = $refhvr_udb_dir . "ref" . $vRegion53; }
if ($verbose) {print "HHH \$refhvr_udb = $refhvr_udb\n";}
if (! $refhvr_udb) { $refhvr_udb = "ref" . $vRegion53; }

# todo: change "blast fasta" in verbose to blast udb?
if (! $vref_table) { $vref_table = "refhvr_" . $vRegion53; }

    
if ($verbose) {print "Reference table and blast fasta: $vref_table, $refhvr_udb\n";}

# Create a new gast directory and move into it.
my $gastDir = $file_prefix;
my $current_dir = getcwd;
if ($current_dir !~ /\/$gastDir$/)
{
    if (! -d $gastDir) 
    {
    	my $mkdirErr = system("mkdir $gastDir");
    	if ($mkdirErr) {print "Unable to create directory $gastDir.  Exiting\n\n"; exit 2;}
    }   
        
    # Enter the gast directory (so all files are stored there)
    chdir $gastDir;
}
open (LOG, ">$log_file") || die ("Unable to write to output log file: $log_file.  Exiting.\n");
`chgrp g454 $log_file`;
`chmod g+w $log_file`;
print LOG "$clustergast_cmd\n";  # print the clustergast command
print LOG "Reference blast fasta: $refhvr_udb\n";

#######################################
#
# Export the fasta and unique it
#
#######################################

my $dir = `pwd`;
chomp $dir;

open (OUTWHERE, ">$whereFilename") || die ("Unable to write to output where file: $whereFilename.  Exiting.\n");
print OUTWHERE "$where\n";
close(OUTWHERE);
`chgrp g454 $whereFilename`;
`chmod g+w $whereFilename`;

if ($start eq "db2fasta")
{
	#
	# trimseq still uses read_id, need to delete below and return to above, when it has been modified.
	#
	my $db2fasta_cmd = "db2fasta -d $db_name -sql \"SELECT $idField, uncompress($trimsequence_table.$sequence_field) as sequence 
	  FROM $trim_table join $trimsequence_table using(trimsequence_id)
	  join $dna_region_table using(dna_region_id)
	  $where\" -o $fasta_filename";
	print LOG "$db2fasta_cmd\n";
    if ($verbose) {print "$db2fasta_cmd\n";}
    system("$db2fasta_cmd");
}

if ( ($start eq "db2fasta") || ($start eq "unique") )
{
	if (! -f $fasta_filename) 
    {
	    print LOG "Unable to create fasta file: $fasta_filename.\n";
	    exit;
	}       
    my $mothur_cmd = "mothur \"#unique.seqs(fasta=$fasta_filename);\"";

	print LOG "$mothur_cmd\n";
    if ($verbose) {print "Uniquing: $mothur_cmd\n";}
    system("$mothur_cmd");
	
	if (! -f $fasta_uniqs_filename) 
    {
	    print LOG "Unable to locate uniqs fasta file: $fasta_uniqs_filename.\n";
	    exit;
	}       
}

#######################################
#
# UClust the data
#
#######################################
if ( ($start eq "db2fasta") || ($start eq "unique") || ($start eq "usearch") )
{
    if ($verbose) {print "Creating table $gast_table\n";}
    #######################################
    #
    # Prepare the GAST table in the database
    #
    #######################################

    &prep_exec_query($dbh, "DROP TABLE IF EXISTS $gast_table");
  
    if ($verbose) {print "gast_table: $gast_table\n";}
  
    my $gast_table_id_name = $gast_table . "_id";
    &prep_exec_query($dbh, 
      "CREATE TABLE $gast_table ( 
        $gast_table_id_name mediumint(8) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `read_id` char(15) NOT NULL DEFAULT '',
        `refhvr_id` varchar(16) NOT NULL DEFAULT '0',
        `distance` decimal(14,3) DEFAULT NULL,
        `alignment` varchar(74) NOT NULL DEFAULT '',
        UNIQUE KEY `read_refhvr` (`read_id`,`refhvr_id`)
      )"
    );

    # remove any old *.gast files in the directory as well, just in case
    my $file_string = $file_prefix . "_*.gast\n";
    
    # my $rm_err = system("rm $file_string"); 

    #######################################
    #
    # Split the uniques fasta and run UClust per node
    #
    #######################################
    # . /xraid/bioware/Modules/etc/profile.modules
    
    my $add_module = <<"END_MESSAGE";    
    echo ". /usr/share/Modules/init/sh"
    . /usr/share/Modules/init/sh
END_MESSAGE

# echo "module unload usearch"
# module unload usearch
# echo "module load usearch/6.0.217-32"
# module load usearch/6.0.217-32

    # Count the number of sequences so the job can be split for nodes
    $facount = `grep -c \">\" $fasta_uniqs_filename`;
    chomp $facount;
    my $calcs = `calcnodes -t $facount -n $nodes -f 1`;
    my @lines = split(/\n/, $calcs);
    
    my $i = 1;
    
    if ($verbose) {print "Keep all files here, not on temp\n"; print LOG "Keep all files here, not on temp\n"; $tmpDir = "";}
    $tmpDir = "";
  
    print LOG "\$tmpDir = $tmpDir\n";
    
    foreach my $l (@lines)
    {
        # calcnodes returns a series of lines describing each set, parse the set and use for the qsub
        my @data = split (/\s+/, $l);

        my $start = $data[1];
        $start =~ s/start=//;
        my $end = $data[2];
        $end =~ s/end=//;

        # Create qsub script
        my $script_filename				= $tmpDir . $qsub_prefix . $file_prefix . $rand_file . $i . ".sh";
        my $qstat_name				    = "gast" . substr($file_prefix, 4) . "_" . $i;
        my $tmp_usearch_filename  = $tmpDir . $usearch_filename . $rand_file . "$i.txt";
        my $usearch_filename			= $usearch_filename . "_$i.txt";
        my $tmp_fasta_filename		= $tmpDir . $fasta_uniqs_filename . $rand_file . $i;
        my $gast_filename				  = "gast_" . $file_prefix . ".$i.txt";
        
        if ($gast_table) { $gast_filename = $gast_table . ".$i.txt"; }
        
        
        open (QSUB, ">$script_filename") || die "Unable to write to qsub script: $script_filename.  Exiting\n";

        print QSUB "#!/bin/sh\n";
        print QSUB "#\$ -j y\n";
        print QSUB "#\$ -o $log_file\n";
        print QSUB "#\$ -e $log_file\n";
        print QSUB "#\$ -N $qstat_name\n";
        print QSUB "#\$ -cwd\n";
        print QSUB "#\$ -V\n";
        
        print QSUB $add_module;

        # Run UClust
        my $script_text = "";
        $script_text .= "hostname >> $log_file\n";
        $script_text .= "date >> $log_file\n";

        my $fastasampler_cmd = "fastasampler -n $start,$end $fasta_uniqs_filename $tmp_fasta_filename";
        $script_text .= "$fastasampler_cmd\n\n";
        if ($verbose) {print "$fastasampler_cmd\n";}
        # my $refhvr_udb_name = $refhvr_udb . ".udb";
        my $refhvr_udb_name = $refhvr_udb . ".fa";
        if ($verbose) {print "\$$refhvr_udb = $refhvr_udb\n";}
        my $refhvr_udb_full_name = $refhvr_udb_dir . $refhvr_udb_name;
        if ($verbose) {print "\$refhvr_udb_full_name = $refhvr_udb_full_name\n";}
        
        
        if ($ignoreterm == 1) {$gapopen = "0E -gapext 0E"}  
        
        # clustergast.log:From clustergast: $usearch_cmd = vsearch -usearch_global 20071203_v3.unique.fa_688_100 -gapopen 0E -gapext 0E -uc_allhits -strand plus -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/refv3.fa -uc 20071203_v3.uc_688_100.txt -maxaccepts 15 -maxrejects 0 -id 0.7
        
        my $usearch_cmd = $usearch_exe . " -usearch_global $tmp_fasta_filename -gapopen $gapopen -uc_allhits -strand $strand -db $refhvr_udb_full_name -uc $tmp_usearch_filename -maxaccepts $max_accepts -maxrejects $max_rejects -id $pctid_threshold";
        print "CCC clustergast: \$usearch_cmd = $usearch_cmd\n";
        print LOG "From clustergast: \$usearch_cmd = $usearch_cmd\n";
        $script_text .= "$usearch_cmd\n\n";
        if ($verbose) {print "$usearch_cmd\n";}
    
        # sort the results for valid hits, saving only the ids and pct identity
        my $tophit_cmp = "clustergast_tophit_v.pl";
        if ($ignoreterm == 1) {$tophit_cmp = "clustergast_tophit_v.pl -ignore_terminal_gaps";}  
        
        if ($verbose) {print "vRegion = $vRegion\n";}
        
        
        # doing ITS fungal? if so then ignore terminal gaps
        if ($vRegion eq "its1")
        {
            $tophit_cmp .= " -ignore_terminal_gaps"
        }
        
        my $clean_usearch_cmd = "grep -P \"^H\\t\" $tmp_usearch_filename | sed -e 's/|.*\$//' | awk '{print \$9 \"\\t\" \$4 \"\\t\" \$10 \"\\t\" \$8}' | sort -k1,1b -k2,2gr | $tophit_cmp > $gast_filename";
        $script_text .= "$clean_usearch_cmd\n\n";
        if ($verbose) {print "Ridiculous commandline usearch clean:\n\t$clean_usearch_cmd\n\n";}

        # Load the resulting file into the database
        # "LOAD INFILE" gave errors on an older MySQL version, use mysqlimport instead
        #my $load_cmd = "mysql -h jbpcdb env454 -e \"load data local infile '$gast_filename' into table $gast_table\"";
        my $load_cmd = "$sqlimport_cmd -C -v -L --columns='read_id','refhvr_id','distance','alignment' -h $db_host $db_name $gast_filename";
        # "For each text file named on the command line, mysqlimport strips any extension from the file name and uses the result to determine the name of the table into which to import the file's contents. For example, files named patient.txt, patient.text, and patient all would be imported into a table named patient."
        
        #$script_text .= "echo \"loading file $gast_filename into table $gast_table\n\"";
        $script_text .= "$load_cmd\n\n";
        if($verbose) {print "Load to database: $load_cmd\n"}

        # ----- error handling ----- 
        $script_text .= "if [ \$? -ne 0 ]; then\n";
        # From Rich:
        # "The compute nodes can't reliably deliver mail because the don't map to computers in the real world, most mail transport agents will reject email that gets sent through them."
        # Mail delivery is slow.
        # TODO: Another way to know about mysalimport failure?
        $script_text .= "  echo \"Error: \\\"$load_cmd\\\" failed for $gast_filename on \$HOSTNAME\" | mail -s 'Clustergast Failure Notice' $tortured_soul\n";
        # $script_text .= "else\n";
        # Do not delete "$gast_filename", needed to check if all entries are in the db!
        # $script_text .= "   rm $gast_filename\n";
        $script_text .= "fi\n";
        
        # Clean up the tmp files
        # TODO: check (Doesn't work if previous line (with mail) doesn't work.)
        # my $clean_qsubfile_cmd = "";
        my $clean_qsubfile_cmd = "";
          # "/bin/rm -f $tmp_fasta_filename\n" .
          # "/bin/rm -f $script_filename\n" ;
            
        # $tmp_usearch_filename where does this one go?!?
        $script_text .= "$clean_qsubfile_cmd\n\n";
        # if ($verbose) {print "remove qsub file: $clean_qsubfile_cmd\n";}

        # Print the commands to the qsub script and then
        # submit the script to the cluster
        print QSUB $script_text;
        close(QSUB);
        #system("chmod +x $script_filename");
        #print $script_text; exit;

        # w/o -S /bin/bash running different shell (not bash)
        my $qsub_error = system("qsub -S /bin/bash $script_filename");
        if ($qsub_error) {my $err_txt = "Error submitting $script_filename to the cluster, $qsub_error.\n"; print LOG $err_txt; warn $err_txt;}
        
        $i++;
    }
}

#######################################
#
# Clean up and close out
#
#######################################
close(LOG);
my $chmodErr = system("chmod -f g+w $log_file");
if ($chmodErr) {print "Error changing $log_file permissions\n\n";}

