#! python

import sys
import mysql_util as util
import shared #use shared to call connection from outside of the module
from argparse import RawTextHelpFormatter

# todo:
# *) add verbose to print outs
# *) remove -* at the end (see Euk example! python findprimers119.py -domain "Eukar" -f "CCAGCA[CG]C[CT]GCGGTAATTCC" -r "[CT][CT][AG]ATCAAGAACGAAAGT")
# *) add possibility work without groups in .my.cnf
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
# Search for primers in db, then for both or one in alingned result (convert primer_seq to "-*" first)

class Findprimer:
  
#######################################
#
# Definition statements
#
#######################################
  
  def __init__(self):
  
    #Runtime variables
    self.refID_field     = "refssu_name_id"
    self.refssu_name     = "CONCAT_WS('_', accession_id, start, stop)"
    self.ref_table       = "refssu_119_ok"
    self.align_table     = "refssu_119_align"
    self.domain          = ""
    self.d_from_letter   = {}
    self.d_to_letter     = {}
    self.select_ref_seqs = ""
    self.get_counts_sql  = ""
    self.both            = False
    self.search_in_db    = ""
    self.regexp_ext      = ""
    self.align_seq       = ""
    self.refssu_name_res = ""
    # primerSeq = f_primerSeq = r_primerSeq = domain = version = ""

  def print_v(self, message):
    if args.verbose:
      print message

  # todo:
  # *) ref_table, align_table - add to arguments with default values
  #######################################
  #
  # SQL statements
  #
  #######################################
  # regexp1 = "CCAGCAGC[CT]GCGGTAA."
  # domain = "Bacter"

  def get_sql_queries(self):
    # r.sequence as unalignseq, 
    self.select_ref_seqs = """SELECT %s, a.sequence as alignseq 
      FROM %s as r
      JOIN refssu_119_taxonomy_source on(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
      JOIN taxonomy_119 on (taxonomy_id = original_taxonomy_id)
      JOIN %s as a using(%s) 
      WHERE taxonomy like '%s%%' and deleted=0 and r.sequence REGEXP '%s'
        LIMIT 1""" % (self.refssu_name, self.ref_table, self.align_table, self.refID_field, self.domain, self.search_in_db)
    
    self.print_v("self.select_ref_seqs from get_sql_queries(): %s" % (self.select_ref_seqs))

    self.get_counts_sql = """SELECT count(refssuid_id)
    FROM %s AS r
      JOIN refssu_119_taxonomy_source ON(refssu_taxonomy_source_id = refssu_119_taxonomy_source_id) 
      JOIN taxonomy_119 ON (taxonomy_id = original_taxonomy_id)
        WHERE taxonomy like \"%s%%\" and deleted=0 and r.sequence REGEXP '%s'""" % (self.ref_table, self.domain, self.search_in_db)

    self.print_v("self.get_counts_sql from get_sql_queries(): %s" % (self.get_counts_sql))
      
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
  # #######################################
  # #
  # # Find a valid sequence to search through, for each silva alignment version
  # #
  # #######################################

  # ===

  def test_mysql_conn(self):
    query_1 = """show tables;		
  """
    self.print_v("from test_mysql_conn = %s" % (query_1))
    shared.my_conn.cursor.execute (self.query_1)
    res_names = shared.my_conn.cursor.fetchall ()
    self.print_v("from test_mysql_conn")
    self.print_v(res_names[-1])
  
  def make_dicts(self):
    self.d_from_letter = {
    'R':'[AG]',
    'Y':'[CT]',
    'S':'[CG]',
    'W':'[AT]',
    'K':'[GT]',
    'M':'[AC]',
    'B':'[CGT]',
    'D':'[AGT]',
    'H':'[ACT]',
    'V':'[ACG]',
    '.':'[ACGT]'
    }

    self.print_v("From make_dicts(), switching keys and values in d_from_letter.")
    self.d_to_letter = {y:x for x,y in self.d_from_letter.items()}
    self.print_v("From make_dicts(), d_to_letter = ")
    self.print_v(self.d_to_letter)
  
  def convert_regexp(self, regexp):
    self.make_dicts()
  # http://stackoverflow.com/questions/2400504/easiest-way-to-replace-a-string-using-a-dictionary-of-replacements
    self.print_v("From convert_regexp(), self.d_to_letter:")
    self.print_v(self.d_to_letter)
    self.print_v("From convert_regexp(), convert each regexp to one letter")
    regexp_rep1 = reduce(lambda x, y: x.replace(y, self.d_to_letter[y]), self.d_to_letter, regexp)
    self.print_v("From convert_regexp(), was: %s\n,         with all changes: %s" % (regexp, regexp_rep1))
    self.print_v("Add possible align signs after each nucleotide.")
    regexp_ch = [ch + "-*" for ch in regexp_rep1]
    self.print_v("Convert one letter back to regexp where needed.")
    return reduce(lambda x, y: x.replace(y, self.d_from_letter[y]), self.d_from_letter, ''.join(regexp_ch))
  
    # C-*C-*A-*G-*C-*A-*G-*C-*[-*C-*T-*]-*G-*C-*G-*G-*T-*A-*A-*.-*
  
  def get_ref_seqs_position(self):  
    import re
  
    self.print_v("From get_ref_seqs_position() self.search_in_db: %s" % (self.search_in_db))

    m = re.search(self.search_in_db, self.align_seq)
    aligned_primer  = m.group(0)
    align_start_pos = m.start() + 1
    align_end_pos   = m.end()

    return  "aligned_primer = %s\nalign_start_pos\t= %s\nalign_end_pos\t= %s\n" %(aligned_primer, align_start_pos, align_end_pos)
    # C-*C-*A-*G-*C-*A-*G-*C-*[CT]-*G-*C-*G-*G-*T-*A-*A-*.
    # aligned_primer  = C-CA--G-C---A--G-C--CG---C-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------GG--TA-AT
    # align_start_pos = 13127
    # align_end_pos = 13862

  #######################################
  #
  # Set up usage statement
  #
  #######################################
  # 


  def parse_arguments(self):
    import argparse
  
    description = """Find the location of a primer sequence in the aligned RefSSU.
    Primer sequence must be inserted as read in 5\'-3\' direction (reverse complement the distal primers).
    You can provide both forward and reverse primers or just one of them.
    Primers can have this regular expressions (note the order in square brackets):               
       'R':'[AG]',
       'Y':'[CT]',
       'S':'[CG]',
       'W':'[AT]',
       'K':'[GT]',
       'M':'[AC]',
       'B':'[CGT]',
       'D':'[AGT]',
       'H':'[ACT]',
       'V':'[ACG]'.
    Use dot '.' instead of 'N'.
    At least one of primer sequences and domain should be provided.
    """

    usage =  """%(prog)s -seq primerseq -domain domainname
    ex: python %(prog)s -seq \"CCAGCAGC[CT]GCGGTAA.\" -domain Bacteria
        python findprimers119.py -domain 'Eukar' -f 'CCAGCA[CG]C[CT]GCGGTAATTCC' -r '[CT][CT][AG]ATCAAGAACGAAAGT' -cnt
    """

    parser = argparse.ArgumentParser(usage = "%s" % usage, description = "%s" % description, formatter_class=RawTextHelpFormatter)
  
    parser.add_argument('-domain', dest = "domain", help = 'superkingdom (in short form: Archae, Bacter, Eukar)')
    parser.add_argument('-ref'   , dest = "ref_table", help = 'reference table (default: refssu)')
    parser.add_argument('-align' , dest = "align_table", help = 'align table (default: refssu_align)')
    parser.add_argument('-cnt'   , action="count", default=0, help = 'count amount of sequences where primer was found (useful if found in both directions)')
    parser.add_argument('-f'     , dest = "f_primer_seq", help = 'forward primer')
    parser.add_argument('-r'     , dest = "r_primer_seq", help = 'reverse primer')
    parser.add_argument('-seq'   , dest = "primer_seq", help = 'primer with unknown direction')
    parser.add_argument('-v'     , '--verbose', action='store_true', help = 'VERBOSITY')

    args = parser.parse_args()
    return args

  #######################################
  #
  # Test for commandline arguments
  #
  #######################################

  def form_seq_regexp(self):
    if (args.primer_seq):
      return self.convert_regexp(args.primer_seq)  
    elif (args.f_primer_seq):
     return self.convert_regexp(args.f_primer_seq)  
    elif (args.r_primer_seq):
      return self.convert_regexp(args.r_primer_seq)  

  def get_counts(self):
    print "Counting, please wait..."
    shared.my_conn.cursor.execute (self.get_counts_sql)
    res = shared.my_conn.cursor.fetchall ()
    print "%s is found in %s sequences." % (self.search_in_db, res[0][0])
    # ((35200L,),)
    
  def form_search_in_db(self):
    if (args.f_primer_seq and args.r_primer_seq):
      self.both = True
      self.search_in_db = args.f_primer_seq  + ".*" + args.r_primer_seq

    self.print_v("From form_search_in_db(), removes fuzzy matching from the right side, otherwise it gets '-' at the end of the result.")
    self.search_in_db = self.search_in_db.rstrip("*").rstrip("-") 

    self.print_v("From form_search_in_db, self.search_in_db = %s" % (self.search_in_db))
    self.print_v("self.both = %s" % (self.both))
    
  def get_info_from_db(self):
    # test_mysql_conn()
    shared.my_conn.cursor.execute (self.select_ref_seqs)    
    info_from_db   = shared.my_conn.cursor.fetchall ()
    self.print_v("From get_info_from_db, info_from_db: ")
    # self.print_v(info_from_db)

    self.align_seq = info_from_db[0][1]
    self.print_v("From get_info_from_db, self.align_seq: ")
    # self.print_v(self.align_seq)
    
    self.refssu_name_res = info_from_db[0][0]
    self.print_v("From get_info_from_db, self.refssu_name_res: ")
    self.print_v(self.refssu_name_res)
    
# ===
# time findprimers119 -domain Bacteria -r CCAGCAGC[CT]GCGGTAA. -ref refssu_119_ok -align refssu_119_align -cnt

if __name__ == '__main__':
  findprimers = Findprimer()
  args = findprimers.parse_arguments()
  findprimers.print_v(args)
  
  shared.my_conn = util.MyConnection(read_default_group="clientenv454")

  # domain = "Bacter"
  findprimers.domain = args.domain
  findprimers.search_in_db = findprimers.form_seq_regexp()
  findprimers.print_v("From __main__, findprimers.search_in_db = %s" % (findprimers.search_in_db))
  findprimers.form_search_in_db()
  findprimers.get_sql_queries()
  findprimers.get_info_from_db()
  
  if (findprimers.both):
    f_primer = findprimers.get_ref_seqs_position(self.align_seq, findprimers.convert_regexp(args.f_primer_seq))
    r_primer = findprimers.get_ref_seqs_position(self.align_seq, findprimers.convert_regexp(args.r_primer_seq))
    print """From __main__. Both primers are in the same sequence:\n
F primer: %s\n
R primer: %s
    """ % (f_primer, r_primer)
  else:
    print findprimers.get_ref_seqs_position()
  
  print "findprimers.refssu_name_res = %s" % (findprimers.refssu_name_res)
  
  if args.cnt:
    findprimers.get_counts()
  