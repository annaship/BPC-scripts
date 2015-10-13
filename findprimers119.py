#! python

import sys
import mysql_util as util
import shared #use shared to call connection from outside of the module

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
# This program is free software you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
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
#            Search for both primers (Ash) Oct 13 2015
#
# Programming Notes:
# Rewritten in python Oct 13 2015. Anna Shipunova (ashipunova@mbl.edu)


#######################################
#
# Set up usage statement
#
#######################################
scriptHelp = """
 findprimers - find the location of a primer sequence in the aligned RefSSU.
               Primer sequence must be inserted as read in 5'-3' direction
               (reverse complement the distal primers)
"""

usage = """
   Usage:  %s -seq primerseq -domain domainname
      ex:  %s -seq \"CAACGCGAAGAACCTTACC\" -domain Bacteria
           %s -seq \"AGGTGCTGCATGGTTGTCG\" -domain Bacteria 

 Options:  
           -domain  superkingdom (e.g., Archaea, Bacteria, Eukarya)
           -ref     reference table (default: refssu)
           -align   align table (default: refssu_align)
           -cnt     count amount of sequences where primer was found (useful if found in both directions)
           -f       forward primer (to seach both)
           -r       reverse primer (to seach both)
           -v       verbose
""" % (sys.argv[0], sys.argv[0], sys.argv[0])

#######################################
#
# Definition statements
#
#######################################
verbose = 0

#Runtime variables
#inFilename
#outFilename
db_host = "newbpcdb2"
db_name = "env454"
ref_table = "refssu_119_ok"
refID_field = "refssu_name_id"
refssu_name = "CONCAT_WS('_', accession_id, start, stop)"
align_table = "refssu_119_align"
cnt = 0
primerSeq = f_primerSeq = r_primerSeq = domain = version = ""

#######################################
#
# Test for commandline arguments
#
#######################################

try:
  if (sys.argv[1] == "help" or sys.argv[1] == "-h"):
      print usage
except IndexError:
  # print sys.exc_info()[0]
  pass
  
# 
# while ((scalar @ARGV > 0) && (ARGV[0] =~ /^-/))
# {
#   if (ARGV[0] =~ /-h/) {
#     print scriptHelp
#     print usage
#     exit 0
#   } elsif (ARGV[0] eq "-seq") {
#     shift @ARGV
#     primerSeq = shift @ARGV
#   } elsif (ARGV[0] eq "-domain") {
#     shift @ARGV
#     domain = shift @ARGV
#   } elsif (ARGV[0] eq "-ref") {
#     shift @ARGV
#     refTable = shift @ARGV
#   } elsif (ARGV[0] eq "-align") {
#     shift @ARGV
#     alignTable = shift @ARGV
#   } elsif (ARGV[0] eq "-cnt") {
#     shift @ARGV
#     cnt = 1
#   } elsif (ARGV[0] eq "-f") {
#     shift @ARGV
#     f_primerSeq = shift @ARGV
#   } elsif (ARGV[0] eq "-r") {
#     shift @ARGV
#     r_primerSeq = shift @ARGV
#   } elsif (ARGV[0] eq "-v") {
#     shift @ARGV
#     verbose = 1
#   } elsif (ARGV[0] eq "-version") {
#     shift @ARGV
#     version = shift @ARGV
#   } elsif (ARGV[0] =~ /^-/) { #unknown parameter, just get rid of it
#     print "Unknown commandline flag \"ARGV[0]\"."
#     print usage
#     exit -1
#   }
# }
# 
# 
# #######################################
# #
# # Parse commandline arguments, ARGV
# #
# #######################################
# 
# #if (scalar @ARGV != argNum) 
# #if ((scalar @ARGV < minargNum) || (scalar @ARGV > maxargNum)) 
# if ( (! (primerSeq || (f_primerSeq && r_primerSeq))) || (! domain))
# {
#   print "Incorrect number of arguments.\n"
#   print "usage\n"
#   exit
# } 
# 
# # replace ambiguous . with _ for SQL syntax
# # primerSeq =~ s/\./_/g
# # We'll use regexp instead - AS, Jul 23 2013
# # Should be like: G[CT][CT]TAAA..[AG][CT][CT][CT]GTAGC
# 
#######################################
#
# SQL statements
#
#######################################
regexp1 = "CCAGCAGC[CT]GCGGTAA."
domain = "Bacter"

select_ref_seqs = """SELECT %s, r.sequence as unalignseq, a.sequence as alignseq 
  FROM %s as r
  JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
  JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
  JOIN %s as a using(%s) 
  WHERE taxonomy like '%s%%' and deleted=0 and r.sequence REGEXP '%s'
    LIMIT 1""" % (refssu_name, ref_table, align_table, refID_field, domain, regexp1)
    
print "select_ref_seqs: %s" % (select_ref_seqs)

get_counts_sql = """SELECT count(refssuid_id)
FROM %s AS r
  JOIN refssu_119_taxonomy_source ON(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
  JOIN taxonomy_119 ON (taxonomy_id = original_taxonomy_id)
    WHERE taxonomy like \"%s%%\" and deleted=0 and r.sequence REGEXP '%s'""" % (ref_table, domain, regexp1)

# condb = Conjbpcdb::new(db_host, dbName)
# dbh = condb->dbh()
# 
# #Select 5 sequences that have the primer in it
# select_ref_seqs
# regexp1
# if (f_primerSeq && r_primerSeq)
# {
#   regexp1 = f_primerSeq . ".*" . r_primerSeq
# }
# else
# {
#   regexp1 = primerSeq
# }
# 
# if (domain eq "all")
# {
# select_ref_seqs = "SELECT refssu_name, r.sequence as unalignseq, a.sequence as alignseq 
#   FROM refTable as r
#   JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
#   JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
#   JOIN alignTable as a using(refID_field) 
#     WHERE deleted=0 and r.sequence REGEXP 'regexp1' 
#     LIMIT 1"
# } else 
# {
# select_ref_seqs = "SELECT refssu_name, r.sequence as unalignseq, a.sequence as alignseq 
#   FROM refTable as r
#   JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
#   JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
#   JOIN alignTable as a using(refID_field) 
#     WHERE taxonolike \"domain%\" and deleted=0 and r.sequence REGEXP 'regexp1'
#     LIMIT 1"
# }
# 
# if (verbose)
# {
#  print "\select_ref_seqs: select_ref_seqs\n" 
# }
# #exit
# select_ref_seqs_h = dbh->prepare(select_ref_seqs)
# 
# #get counts
# get_counts_sql = "SELECT count(refssuid_id)
# FROM refTable AS r
#   JOIN refssu_119_taxonomy_source ON(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
#   JOIN taxonomy_119 ON (taxonomy_id = original_taxonomy_id)
#     WHERE taxonolike \"domain%\" and deleted=0 and r.sequence REGEXP 'regexp1'"
# 
# if (verbose)
# {
#   print "\get_counts_sql = get_counts_sql\n" 
# }
# get_counts_sql_h = dbh->prepare(get_counts_sql)
# 
# #######################################
# #
# # Find a valid sequence to search through, for each silva alignment version
# #
# #######################################
# foundPrimer  = 0
# select_ref_seqs_h->execute()
# refStartPos  = 0
# match_length = 0
# while((refssu_name, refSeq, alignSeq) = select_ref_seqs_h->fetchrow())
# {
#   if (verbose)
#   {
#     print "\refssu_name = refssu_name\n" 
#     print "\refSeq      = refSeq\n" 
#     print "\alignSeq    = alignSeq\n" 
#   }
#   
#   # Save out original aligned sequence for substring at the end
#   initAlignSeq = alignSeq
#   
#   # Position of the beginning and the end of the primer in the unaliged (ref) sequence
#   if (refSeq =~ /regexp1/) {
#     if (verbose)
#     {
#       print "\`  = `\n" 
#       print "\& = &\n" 
#     }
#         refStartPos  = length(`) #PREMATCH from regexp
#         match_length = length(&)
#     }
#     
#     if (verbose)
#     {
#       print "\refStartPos  = refStartPos\n" 
#       print "\match_length = match_length\n" 
#     }
#     
#     # refStartPos = index(refSeq, primerSeq)
#     # refEndPos = refStartPos + length(primerSeq) - 1
#     refEndPos = refStartPos + match_length - 1
#     
#     if (verbose)
#     {
#       print "\refEndPos  = refEndPos\n" 
#     }
#     
#   # Initialize index positions of the aligned sequence
#   alignStartPos
#   alignEndPos
# 
#   # Full length of both aligned and unaligned sequences
#   alignPos = length(alignSeq)
#   refPos = length(refSeq)
#   
#   if (verbose)
#   {
#     print "\alignPos = alignPos\n" 
#     print "\refPos   = refPos\n" 
#   }
# 
#   # Step along the aligned sequence starting at the end, 
#   # chop off gaps, and walk through the actual bases, ticking them off in the unaligned sequence.
#   while (alignSeq)
#   {
#     # remove trailing gap characters
#     # and grab the last real base
#     alignSeq =~ s/-*//
#     base = chop alignSeq
#     
#     # if (verbose)
#     # {
#     #   print "s/-*//\n\base = base\n"
#     # }
# 
#     # decrement the position along the reference sequence (step back one base)
#     refPos--
# 
#     # if you are now at the end of the primer, store as alignEndPos
#     if (refPos == refEndPos) 
#     {
#       alignEndPos = length(alignSeq) + 1
#       if (verbose)
#       {
#         print "at the end of the primer\n\alignEndPos = alignEndPos\n"       
#       }
#     }
# 
#     # if (verbose && alignEndPos)
#     # {
#     #   print "\alignEndPos = alignEndPos\n"
#     # }
# 
#     # if you are now at the beginning of the primer, print out the information
#     if (refPos == refStartPos) 
#     {
#       if (verbose)
#       {
#         print "at the beginning of the primer, print out the information\n\refPos = refPos\n"
#       }
#       alignStartPos = length(alignSeq) + 1
#       
#       if (f_primerSeq && r_primerSeq)
#       { 
#         f_length
#         r_length
#         start_f
#         start_r
#         end_f
#         end_r
#         # say qq{>1< found at -[ 0 ]} while
#         # line =~ m{([ (),.:?!-])}g
#         
#         f_primerSeq_align
#         r_primerSeq_align
#         # line =~ m{\d+}
#         # pos = length `
#         
#         # initAlignSeq =~ m{(f_primerSeq)}
#         # l_pos = length `
#         # f_primerSeq_align = length &
#         #
#         # print "\l_pos of \f_primerSeq = l_pos of f_primerSeq\n"
#         # print "\f_primerSeq_align      = f_primerSeq_align\n"
#         # print "\@- = @-\n"
#         # print "\@+ = @+\n"
#         # print "\-[0] = -[0]\n"
#         # print "\+[0] = +[0]\n"
#         #
#         initAlignSeq =~ /f_primerSeq/
#         print "\n\MATCH = &\n"
#         print "\nLeft:  <", substr( initAlignSeq, 0, -[0] ),
#               ">\nMatch: <", substr( initAlignSeq, -[#-], +[#-] ),
#               ">\nRight: <", substr( initAlignSeq, +[#+] ), ">\n"
#         print "\-[0] = -[0]\n"
#         print "\-[\#-] = -[#-]\n"
#         print "\+[\#-] - \-[\#-] = +[#-] - -[#-]\n"
#         print "\+[\#-] = +[#-]\n"
#               
#         
#         # ----
# 
#         # initAlignSeq =~ m{r_primerSeq}
#         # l_pos = length `
#         # r_primerSeq_align = length &
#         #
#         # print "\l_pos of \r_primerSeq = l_pos\n"
#         # print "\r_primerSeq_align      = r_primerSeq_align\n"
#         # print "\@- = @-\n"
#         # print "\@+ = @+\n"
#         # print "\-[0] = -[0]\n"
#         # print "\+[0] = +[0]\n"
# 
# 
# 
#         # initAlignSeq =~ m{f_primerSeq}
#         # l_pos = length `
#         # print "\l_pos of \f_primerSeq = l_pos\n"
#         #
#         # initAlignSeq =~ m{f_primerSeq}
#         # l_pos = length `
#         # print "\l_pos of \f_primerSeq = l_pos\n"
# 
#         f_length = length(f_primerSeq)
#         r_length = length(r_primerSeq)
#         start_f = alignStartPos
#         end_f = start_f + f_length
#         end_r = alignEndPos
#         start_r = end_r - r_length
#         
#         if (verbose)
#         {
#           print "\start_f = start_f, \end_f = end_f, \start_r = start_r, \end_r = end_r\n"
#         }
#         
#         print "Primer F (f_primerSeq): " . substr(initAlignSeq, start_f - 1, end_f - start_f + 1) . "\n"
#         print "Primer R: (r_primerSeq): " . substr(initAlignSeq, start_r - 1, end_r - start_r + 1) . "\n"
#         # print "Primer F: start = start_f, end = end_f (refssu_name)\n"
#         # print "Primer R: start = start_r, end = end_r (refssu_name)\n"
#       }     
#       else
#       {
#         print "Primer: " . substr(initAlignSeq, alignStartPos - 1, alignEndPos - alignStartPos + 1) . "\n"
#         print "start=alignStartPos, end=alignEndPos (refssu_name)\n"        
#       } 
#       foundPrimer = 1
#       last
#     }
#   }
#   if (foundPrimer) {last}
# }
# if (! foundPrimer) {print "Unable to locate primer in aligned sequences\n"}
# 
# # Print out cnts:
# if (cnt)
# {
#   print "Counting sequences where primer was found, please wait...\n"
#   get_counts_sql_h->execute()
#   while((cnt_seq) = get_counts_sql_h->fetchrow())
#   {
#     print "Primer was found in " . cnt_seq . " sequences.\n"
#   }
# }
# 
# # Clean up database connections
# select_ref_seqs_h->finish
# dbh->disconnect

# ===

def test_mysql_conn():
  query_1 = """show tables;		
        """
  print query_1
  shared.my_conn.cursor.execute (query_1)
  res_names = shared.my_conn.cursor.fetchall ()
  print res_names[-1]
  
def convert_regexp(regexp):
  # todo: get all changes
  regexp_ch = [ch + "-*" for ch in regexp.replace("[CT]", "Y")]
  return ''.join(regexp_ch).replace("Y", "[CT]")
  # C-*C-*A-*G-*C-*A-*G-*C-*[-*C-*T-*]-*G-*C-*G-*G-*T-*A-*A-*.-*
  
def get_ref_seqs_position(align_seq):  
  import re
    
  regexp_ext = convert_regexp(regexp1)  
  regexp_ext1 = regexp_ext.rstrip("*").rstrip("-") # removes fuzzy matching from the rigt side, otherwise it gets "-" at the end of the result
  print regexp_ext1

  m = re.search(regexp_ext1, align_seq)
  aligned_primer  = m.group(0)
  align_start_pos = m.start() + 1
  align_end_pos   = m.end()


  return  "aligned_primer\t= %s\nalign_start_pos\t= %s\nalign_end_pos\t= %s\n" %(aligned_primer, align_start_pos, align_end_pos)
  # C-*C-*A-*G-*C-*A-*G-*C-*[CT]-*G-*C-*G-*G-*T-*A-*A-*.
  # aligned_primer  = C-CA--G-C---A--G-C--CG---C-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------GG--TA-AT
  # align_start_pos = 13127
  # align_end_pos = 13862


# ===
if __name__ == '__main__':
  # shared.my_conn = util.MyConnection("newbpcdb2", "env454")
  shared.my_conn = util.MyConnection(read_default_group="clientenv454")
  
  # test_mysql_conn()
  shared.my_conn.cursor.execute (select_ref_seqs)    
  res = shared.my_conn.cursor.fetchall ()
  
  print regexp1
  # CCAGCAGC[CT]GCGGTAA.
  
  align_seq = res[0][2]
  print get_ref_seqs_position(align_seq)
  
  refssu_name_res = res[0][0]
  print "refssu_name_res = %s" % (refssu_name_res)
  
  shared.my_conn.cursor.execute (get_counts_sql)
  res = shared.my_conn.cursor.fetchall ()
  print "Primer was found in %s sequences." % (res[0][0])
  # ((35200L,),)
  
  