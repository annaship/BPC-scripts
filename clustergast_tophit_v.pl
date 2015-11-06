#!/usr/bin/env perl

#########################################
#
# clustergast_tophit: called by clustergast for sorting best UClust hits
#
# Author: Susan Huse, shuse@mbl.edu
#
# Date: Wed Jul  7 14:04:41 EDT 2010
#
# Copyright (C) 2010 Marine Biological Laborotory, Woods Hole, MA
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
# Keywords : remove the space before the colon and list keywords separated by a space
# 
# Assumptions: 
#
# Revisions:
#
# Programming Notes:
#
########################################
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

#######################################
#
# Set up usage statement
#
#######################################
my $script_help = "
 clustergast_tophit - reads STDIN from clustergast (uclust) and outputs top 
                      gast hit and the distances
\n";

my $usage = "
   Usage:  clustergast_tophit  is not used outside of clustergast
           grep -P \"^H\\t\" /usr/local/tmp/20100312_v6v4.uc_797_1.txt | sed -e 's/|.*\$//' | awk '{print \$9 \"\\t\" \$4 \"\\t\" \$10}' | sort -k1,1b -k2,2gr | clustergast_tophit > /usr/local/tmp/20100312_v6v4.gast_797_1\n\n";
#
#      ex:  clustergast_tophit in.fasta out.fasta
#           clustergast_tophit -p X in.fasta out.fasta
#
# Options:  
#           -a does something
#           -d does something else
#\n";

#######################################
#
# Definition statements
#
#######################################
#Commandline parsing
#my $arg_count = 3;
#my $min_arg_count = 2;
#my $max_arg_count = 4;
my $verbose = 0;
my $max_gap = 10;
my $ignore_terminal_gaps = 0;  # only ignore for max gap size, still included in the distance calculations
my $ignore_all_gaps = 0;
my $use_full_length = 0;       # if can't find ref database then use full-length refssu

# illumina defline: A5BCDEF3:25:Z987YXWUQ:3:1101:8415:2237 1:N:0:CGATGT|frequency:1
my $remove_defline_frequency = 0; # 
my $log_file = "clustergast_tophit.log";

#######################################
#
# Test for commandline arguments
#
#######################################

#if (! $ARGV[0] ) 
#{
#	print $script_help;
#	print $usage;
#	exit -1;
#} 

while ((scalar @ARGV > 0) && ($ARGV[0] =~ /^-/)) 
{
	if ($ARGV[0] =~ /-h/) 
	{
		print $script_help;
		print $usage;
		exit 0;
#	} elsif ($ARGV[0] eq "-p") {
#		shift @ARGV;
#		$example_var = shift @ARGV;
	} elsif ($ARGV[0] eq "-v") {
		$verbose = 1;
		shift @ARGV;
	} elsif ($ARGV[0] eq "-max_gap") {
		shift @ARGV;
		$max_gap = shift @ARGV;
	} elsif ($ARGV[0] eq "-ignore_terminal_gaps") {
		$ignore_terminal_gaps = 1;
		shift @ARGV;
	} elsif ($ARGV[0] eq "-ignore_all_gaps") {
		$ignore_all_gaps = 1;
		shift @ARGV;
	} elsif ($ARGV[0] eq "-use_full_length") {
		$use_full_length = 1;
		shift @ARGV;
	}elsif ($ARGV[0] eq "-remove_defline_frequency") {
		$remove_defline_frequency = 1;
		shift @ARGV;
	}  
	elsif ($ARGV[0] =~ /^-/) { #unknown parameter, just get rid of it
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

#if (scalar @ARGV != $arg_count)
#if ((scalar @ARGV < $min_arg_count) || (scalar @ARGV > $max_arg_count))
#if ( (! $db_name) || (! $in_filename) ) 
#{
#	print "Incorrect number of arguments.\n";
#	print "$usage\n";
#	exit;
#} 
#
##Test validity of commandline arguments
#$in_filename = $ARGV[0];
#if ( ($in_filename ne "stdin") && (! -f $in_filename) ) 
#{
#	print "Unable to locate input fasta file: $in_filename.\n";
#	exit -1;
#}
#$out_filename = $ARGV[1];

#######################################
#
# Run the transformation
#
#######################################

open (LOG, ">$log_file") || die ("Unable to write to output log file: $log_file.  Exiting.\n");

# Open standard in
open(IN, "-") ;

#initialize the variables
my $last_id = 0; 
my $last_pi = 0; 

# read in the data
while (my $line = <IN>)
{
    my $skip_this_hit = 0;
    my $found_hit = 0;
    chomp $line; 

    # split the line into read_id, percent identity and reference ID
    # print "LLL: line = $line\n";
    my($read_id, $pi, $ri, $align) = split("\t", $line); 
    my $full_align = $align;
    # print BOLD, BLUE "AAA0: full_align = $full_align; read_id = $read_id, pi = $pi, ri = $ri, align = $align\n", RESET;
    print LOG "AAA0: full_align = $full_align; read_id = $read_id, pi = $pi, ri = $ri, align = $align\n";
    
    print LOG "BBB: \$read_id = $read_id; \$read_id = $read_id, \$last_id = $last_id, \$pi = $pi, \$last_pi = $last_pi\n";
    
    # Assume data are in order of read id and descending pct_id
    # If the first line of this read_id, or if the pct_id is the same or better, print
    if ( ($read_id ne $read_id) || ( ($read_id eq $last_id) && ($pi >= $last_pi) ) ) 
    {
        
        print LOG "CCC: from ( (\$read_id ne \$read_id) || ( (\$read_id eq \$last_id) && (\$pi >= \$last_pi) ) )\n";
        
        if ($remove_defline_frequency && $read_id =~ /\|frequency:/)
        {
            $read_id =~ s/\|frequency.+$//;
        }
        #
        # before assuming it is okay, check for excessive gaps
        #
        
        # remove terminal gaps if appropriate
        if ($ignore_terminal_gaps || $ignore_all_gaps)
        {
            $align =~ s/^[0-9]*[DI]//;
            $align =~ s/[0-9]*[DI]$//;
        }
        elsif($use_full_length)
        {
            $align =~ s/^[0-9]*[I]//;
            $align =~ s/[0-9]*[I]$//;
            # $align =~ s/^[0-9]*[DI]//;
            # $align =~ s/[0-9]*[DI]$//;
        }
        
        # print "AAA: align = $align\n";
        # has internal gaps
        if ( ($use_full_length) || (! $ignore_all_gaps) ) 
        {
          # print "HHH: HERE, use_full_length = $use_full_length, ignore_all_gaps = $ignore_all_gaps\n";
          
            while ($align =~ /[DI]/)
            {
               # print "AAA1: align = $align\n";
                $align =~ s/^[0-9]*[M]//;  # leading remove matches 
                $align =~ s/^[ID]//; # remove singleton indels
                # print "AAA2: align = $align\n";
    
                if ($align =~ /^[0-9]*[ID]/)
                {
                    my $gap = $align;
                    $align =~ s/^[0-9]*[ID]//;  # remove gap from aligment
                    $gap =~ s/[ID]$align//;     # remove alignment from gap
                    # print "AAA3: align = $align, gap = $gap\n";
                    
                    # if too large a gap, tends to be indicative of chimera or other non-matches
                    # then skip to the next ref
                    if ($gap > $max_gap) 
                    {
                      # print "AAA4: gap = $gap > max_gap = $max_gap\n";
                        $skip_this_hit = 1; 
                        if ($verbose) { print "Skip $read_id for $gap gap.  $line\n";} 
                        last;
                    }
                }
                # print "SSS: skip_this_hit = $skip_this_hit\n";                
                if ($skip_this_hit) {last;}
            }
        }
        # skip this ref altogether, 
        if ($skip_this_hit) {next;}
        
        $found_hit = 1;
        #
        # convert from percent identity to distance
        #
        print LOG "PPP: pi = $pi, ri = $ri\n";
        my $dist = (int((10* (100 - $pi)) + 0.5)) / 1000; 
        print LOG "DDD1: dist = $dist\n";
        # my $dist = (int((10* (100 - $ri)) + 0.5)) / 1000; 
        # print LOG "DDD2: dist = $dist\n";
        
        #
        # print out the data
        #
        print LOG "FFF: \$read_id = $read_id; \$dist = $dist, pi = $pi, ri = $ri, \$full_align = $full_align\n";
        print join ("\t", $read_id, $ri, $dist, $full_align) . "\n"; 
        # print "JJJ: read_id = $read_id, ri = $ri, dist = $dist, full_align = $full_align\n";
        #
        # update the last variables
        #
        $last_pi = $pi; 
        $last_id = $read_id;
    }
}
