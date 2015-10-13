#!/usr/bin/env perl

#########################################
#
# findprimers: finds primer locations in RefSSU
#
# Author: Susan Huse, shuse@mbl.edu
#
# Date: Sun Oct 14 19:56:25 EDT 2007
#
# Copyright (C) 2008 Marine Biological Laboratory, Woods Hole, MA
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# For a copy of the GNU General Public License, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# or visit http://www.gnu.org/copyleft/gpl.html
#
# Keywords: primer database 454 align refssu
# 
# Assumptions: 
#
# Revisions: work with "." Jul 27 2013
#            Usage statements to include all valid options Aug 14 2015
#	           Change table names (joins) to use with Silva119 (ASh) Sep 24 2015
#            Show accession_id with start and stop. (Ash) Oct 1 2015
#
# Programming Notes:
#
########################################
use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Conjbpcdb;

#######################################
#
# Set up usage statement
#
#######################################
my $scriptHelp = "
 findprimers - find the location of a primer sequence in the aligned RefSSU.
               Primer sequence must be inserted as read in 5'-3' direction
               (reverse complement the distal primers)
\n";

my $usage = "
   Usage:  findprimers -seq primerseq -domain domainname
      ex:  findprimers -seq \"CAACGCGAAGAACCTTACC\" -domain Bacteria
           findprimers -seq \"AGGTGCTGCATGGTTGTCG\" -domain Bacteria 

 Options:  
           -seq     sequence to search for
           -domain  superkingdom (e.g., Archaea, Bacteria, Eukarya)
           -ref     reference table (default: refssu)
           -align   align table (default: refssu_align)
           -cnt     count amount of sequences where primer was found (useful if found in both directions)
           -f       forward primer (to seach both)
           -r       reverse primer (to seach both)
           -v       verbose
\n";

#######################################
#
# Definition statements
#
#######################################
#Commandline parsing
#my $argNum = 3;
my $minargNum = 2;
my $maxargNum = 4;
my $verbose = 0;

#Runtime variables
#my $inFilename;
#my $outFilename;
my $dbName = "env454";
my $db_host = "newbpcdb2";
my $refTable = "refssu";
my $refID_field = "refssu_name_id";
my $refssu_name = "CONCAT_WS('_', accession_id, start, stop)";
my $alignTable = "refssu_align";
my $cnt = 0;
my $primerSeq;
my $f_primerSeq;
my $r_primerSeq;
my $domain;
my $version;

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

while ((scalar @ARGV > 0) && ($ARGV[0] =~ /^-/))
{
	if ($ARGV[0] =~ /-h/) {
		print $scriptHelp;
		print $usage;
		exit 0;
	} elsif ($ARGV[0] eq "-seq") {
		shift @ARGV;
		$primerSeq = shift @ARGV;
	} elsif ($ARGV[0] eq "-domain") {
		shift @ARGV;
		$domain = shift @ARGV;
	} elsif ($ARGV[0] eq "-ref") {
		shift @ARGV;
		$refTable = shift @ARGV;
	} elsif ($ARGV[0] eq "-align") {
		shift @ARGV;
		$alignTable = shift @ARGV;
	} elsif ($ARGV[0] eq "-cnt") {
		shift @ARGV;
		$cnt = 1;
	} elsif ($ARGV[0] eq "-f") {
		shift @ARGV;
		$f_primerSeq = shift @ARGV;
	} elsif ($ARGV[0] eq "-r") {
		shift @ARGV;
		$r_primerSeq = shift @ARGV;
	} elsif ($ARGV[0] eq "-v") {
		shift @ARGV;
    $verbose = 1;
	} elsif ($ARGV[0] eq "-version") {
		shift @ARGV;
		$version = shift @ARGV;
	} elsif ($ARGV[0] =~ /^-/) { #unknown parameter, just get rid of it
		print "Unknown commandline flag \"$ARGV[0]\".";
		print $usage;
		exit -1;
	}
}


#######################################
#
# Parse commandline arguments, ARGV
#
#######################################

#if (scalar @ARGV != $argNum) 
#if ((scalar @ARGV < $minargNum) || (scalar @ARGV > $maxargNum)) 
if ( (! ($primerSeq || ($f_primerSeq && $r_primerSeq))) || (! $domain))
{
	print "Incorrect number of arguments.\n";
	print "$usage\n";
	exit;
} 

# replace ambiguous . with _ for SQL syntax
# $primerSeq =~ s/\./_/g;
# We'll use regexp instead - AS, Jul 23 2013
# Should be like: G[CT][CT]TAAA..[AG][CT][CT][CT]GTAGC

#######################################
#
# SQL statements
#
#######################################

my $condb = Conjbpcdb::new($db_host, $dbName);
my $dbh = $condb->dbh();

#Select 5 sequences that have the primer in it
my $selectRefSeqs;
my $regexp1;
if ($f_primerSeq && $r_primerSeq)
{
  $regexp1 = $f_primerSeq . ".*" . $r_primerSeq;
}
else
{
  $regexp1 = $primerSeq;
}

if ($domain eq "all")
{
$selectRefSeqs = "SELECT $refssu_name, r.sequence as unalignseq, a.sequence as alignseq 
  FROM $refTable as r
  JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
  JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
  JOIN $alignTable as a using($refID_field) 
    WHERE deleted=0 and r.sequence REGEXP '$regexp1' 
    LIMIT 1";
} else 
{
$selectRefSeqs = "SELECT $refssu_name, r.sequence as unalignseq, a.sequence as alignseq 
  FROM $refTable as r
  JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
  JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
  JOIN $alignTable as a using($refID_field) 
    WHERE taxonomy like \"$domain%\" and deleted=0 and r.sequence REGEXP '$regexp1'
    LIMIT 1";
}

if ($verbose)
{
 print "\$selectRefSeqs: $selectRefSeqs\n"; 
}
#exit;
my $selectRefSeqs_h = $dbh->prepare($selectRefSeqs);

#get counts
my $get_counts_sql = "SELECT count(refssuid_id)
FROM $refTable AS r
  JOIN refssu_119_taxonomy_source ON(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
  JOIN taxonomy_119 ON (taxonomy_id = original_taxonomy_id)
    WHERE taxonomy like \"$domain%\" and deleted=0 and r.sequence REGEXP '$regexp1'";

if ($verbose)
{
  print "\$get_counts_sql = $get_counts_sql\n"; 
}
my $get_counts_sql_h = $dbh->prepare($get_counts_sql);

#######################################
#
# Find a valid sequence to search through, for each silva alignment version
#
#######################################
my $foundPrimer  = 0;
$selectRefSeqs_h->execute();
my $refStartPos  = 0;
my $match_length = 0;
while(my ($refssu_name, $refSeq, $alignSeq) = $selectRefSeqs_h->fetchrow())
{
  if ($verbose)
  {
    print "\$refssu_name = $refssu_name\n"; 
    print "\$refSeq      = $refSeq\n"; 
    print "\$alignSeq    = $alignSeq\n"; 
  }
  
	# Save out original aligned sequence for substring at the end
	my $initAlignSeq = $alignSeq;
  
	# Position of the beginning and the end of the primer in the unaliged (ref) sequence
	if ($refSeq =~ /$regexp1/) {
    if ($verbose)
    {
      print "\$`  = $`\n"; 
      print "\$& = $&\n"; 
    }
        $refStartPos  = length($`); #$PREMATCH from regexp
        $match_length = length($&);
    }
    
    if ($verbose)
    {
      print "\$refStartPos  = $refStartPos\n"; 
      print "\$match_length = $match_length\n"; 
    }
    
    # my $refStartPos = index($refSeq, $primerSeq);
    # my $refEndPos = $refStartPos + length($primerSeq) - 1;
    my $refEndPos = $refStartPos + $match_length - 1;
    
    if ($verbose)
    {
      print "\$refEndPos  = $refEndPos\n"; 
    }
    
	# Initialize index positions of the aligned sequence
	my $alignStartPos;
	my $alignEndPos;

	# Full length of both aligned and unaligned sequences
	my $alignPos = length($alignSeq);
	my $refPos = length($refSeq);
  
  if ($verbose)
  {
    print "\$alignPos = $alignPos\n"; 
    print "\$refPos   = $refPos\n"; 
  }

	# Step along the aligned sequence starting at the end, 
	# chop off gaps, and walk through the actual bases, ticking them off in the unaligned sequence.
	while ($alignSeq)
	{
		# remove trailing gap characters
		# and grab the last real base
		$alignSeq =~ s/-*$//;
		my $base = chop $alignSeq;
    
    # if ($verbose)
    # {
    #   print "s/-*$//\n\$base = $base\n";
    # }

		# decrement the position along the reference sequence (step back one base)
		$refPos--;

		# if you are now at the end of the primer, store as $alignEndPos
		if ($refPos == $refEndPos) 
    {
      $alignEndPos = length($alignSeq) + 1;
      if ($verbose)
      {
        print "at the end of the primer\n\$alignEndPos = $alignEndPos\n";       
      }
    }

    # if ($verbose && $alignEndPos)
    # {
    #   print "\$alignEndPos = $alignEndPos\n";
    # }

		# if you are now at the beginning of the primer, print out the information
		if ($refPos == $refStartPos) 
		{
      if ($verbose)
      {
        print "at the beginning of the primer, print out the information\n\$refPos = $refPos\n";
      }
			$alignStartPos = length($alignSeq) + 1;
      
      if ($f_primerSeq && $r_primerSeq)
      { 
        my $f_length;
        my $r_length;
        my $start_f;
        my $start_r;
        my $end_f;
        my $end_r;
        # say qq{>$1< found at $-[ 0 ]} while
        # $line =~ m{([ (),.;:?!-])}g;
        
        my $f_primerSeq_align;
        my $r_primerSeq_align;
        # $line =~ m{\d+};
        # my $pos = length $`;
        
        # $initAlignSeq =~ m{($f_primerSeq)};
        # my $l_pos = length $`;
        # $f_primerSeq_align = length $&;
        #
        # print "\$l_pos of \$f_primerSeq = $l_pos of $f_primerSeq\n";
        # print "\$f_primerSeq_align      = $f_primerSeq_align\n";
        # print "\@- = @-\n";
        # print "\@+ = @+\n";
        # print "\$-[0] = $-[0]\n";
        # print "\$+[0] = $+[0]\n";
        #
        $initAlignSeq =~ /$f_primerSeq/;
        print "\n\$MATCH = $&\n";
        print "\nLeft:  <", substr( $initAlignSeq, 0, $-[0] ),
              ">\nMatch: <", substr( $initAlignSeq, $-[$#-], $+[$#-] ),
              ">\nRight: <", substr( $initAlignSeq, $+[$#+] ), ">\n";
        print "\$-[0] = $-[0]\n";
        print "\$-[\$#-] = $-[$#-]\n";
        print "\$+[\$#-] - \$-[\$#-] = $+[$#-] - $-[$#-]\n";
        print "\$+[\$#-] = $+[$#-]\n";
              
        
        # ----

        # $initAlignSeq =~ m{$r_primerSeq};
        # $l_pos = length $`;
        # $r_primerSeq_align = length $&;
        #
        # print "\$l_pos of \$r_primerSeq = $l_pos\n";
        # print "\$r_primerSeq_align      = $r_primerSeq_align\n";
        # print "\@- = @-\n";
        # print "\@+ = @+\n";
        # print "\$-[0] = $-[0]\n";
        # print "\$+[0] = $+[0]\n";



        # $initAlignSeq =~ m{$f_primerSeq};
        # my $l_pos = length $`;
        # print "\$l_pos of \$f_primerSeq = $l_pos\n";
        #
        # $initAlignSeq =~ m{$f_primerSeq};
        # my $l_pos = length $`;
        # print "\$l_pos of \$f_primerSeq = $l_pos\n";

        $f_length = length($f_primerSeq);
        $r_length = length($r_primerSeq);
        $start_f = $alignStartPos;
        $end_f = $start_f + $f_length;
        $end_r = $alignEndPos;
        $start_r = $end_r - $r_length;
        
        if ($verbose)
        {
          print "\$start_f = $start_f, \$end_f = $end_f, \$start_r = $start_r, \$end_r = $end_r\n";
        }
        
  			print "Primer F ($f_primerSeq): " . substr($initAlignSeq, $start_f - 1, $end_f - $start_f + 1) . "\n";
  			print "Primer R: ($r_primerSeq): " . substr($initAlignSeq, $start_r - 1, $end_r - $start_r + 1) . "\n";
        # print "Primer F: start = $start_f, end = $end_f ($refssu_name)\n";
        # print "Primer R: start = $start_r, end = $end_r ($refssu_name)\n";
      }     
      else
      {
  			print "Primer: " . substr($initAlignSeq, $alignStartPos - 1, $alignEndPos - $alignStartPos + 1) . "\n";
  			print "start=$alignStartPos, end=$alignEndPos ($refssu_name)\n";        
      } 
			$foundPrimer = 1;
			last;
		}
	}
	if ($foundPrimer) {last;}
}
if (! $foundPrimer) {print "Unable to locate primer in aligned sequences\n";}

# Print out cnts:
if ($cnt)
{
  print "Counting sequences where primer was found, please wait...\n";
  $get_counts_sql_h->execute();
  while(my ($cnt_seq) = $get_counts_sql_h->fetchrow())
  {
    print "Primer was found in " . $cnt_seq . " sequences.\n";
  }
}

# Clean up database connections
$selectRefSeqs_h->finish;
$dbh->disconnect;
