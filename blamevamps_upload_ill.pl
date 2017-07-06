e71f9464 (annaship 2013-01-03 13:05:51 -0500    1) #!/usr/bin/env perl
e71f9464 (annaship 2013-01-03 13:05:51 -0500    2) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500    3) #########################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500    4) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500    5) # vamps_upload: Create a data cube for VAMPS
e71f9464 (annaship 2013-01-03 13:05:51 -0500    6) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500    7) # Author: Susan Huse, shuse@mbl.edu
e71f9464 (annaship 2013-01-03 13:05:51 -0500    8) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500    9) # Date: Tue Aug 12 07:37:52 EDT 2008
e71f9464 (annaship 2013-01-03 13:05:51 -0500   10) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   11) # Copyright (C) 2008 Marine Biological Laborotory, Woods Hole, MA
e71f9464 (annaship 2013-01-03 13:05:51 -0500   12) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   13) # This program is free software; you can redistribute it and/or
e71f9464 (annaship 2013-01-03 13:05:51 -0500   14) # modify it under the terms of the GNU General Public License
e71f9464 (annaship 2013-01-03 13:05:51 -0500   15) # as published by the Free Software Foundation; either version 2
e71f9464 (annaship 2013-01-03 13:05:51 -0500   16) # of the License, or (at your option) any later version.
e71f9464 (annaship 2013-01-03 13:05:51 -0500   17) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   18) # This program is distributed in the hope that it will be useful,
e71f9464 (annaship 2013-01-03 13:05:51 -0500   19) # but WITHOUT ANY WARRANTY; without even the implied warranty of
e71f9464 (annaship 2013-01-03 13:05:51 -0500   20) # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
e71f9464 (annaship 2013-01-03 13:05:51 -0500   21) # GNU General Public License for more details.
e71f9464 (annaship 2013-01-03 13:05:51 -0500   22) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   23) # For a copy of the GNU General Public License, write to the Free Software
e71f9464 (annaship 2013-01-03 13:05:51 -0500   24) # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
e71f9464 (annaship 2013-01-03 13:05:51 -0500   25) # or visit http://www.gnu.org/copyleft/gpl.html
e71f9464 (annaship 2013-01-03 13:05:51 -0500   26) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   27) # Keywords: vamps datacube taxonomy upload
e71f9464 (annaship 2013-01-03 13:05:51 -0500   28) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   29) # Assumptions:
e71f9464 (annaship 2013-01-03 13:05:51 -0500   30) #
d183bd5c (annaship 2013-12-20 17:59:29 -0500   31) # Revisions: 2012-05-15 by Anna Shipunova. Added new normalize tales, sequences dump.
c7ca1d90 (annaship 2013-12-20 18:08:18 -0500   32) #            2013-12-20 by Anna Shipunova. Fix seq_counts to sum in vamps_sequences_transfer_temp
3fb56f83 (annaship 2014-11-17 15:43:55 -0500   33) #            2014-11-17 ASh. Get the sequence table by chunks.
e71f9464 (annaship 2013-01-03 13:05:51 -0500   34) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   35) # Programming Notes:
e71f9464 (annaship 2013-01-03 13:05:51 -0500   36) #    20090826 - SMH: added date_trimmed field FROM trimseq into final_reads_table (vamps_export)
e71f9464 (annaship 2013-01-03 13:05:51 -0500   37) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   38) ########################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500   39) use strict;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   40) use warnings;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   41) #use lib '/usr/local/www/vamps/special/perl/lib';
e71f9464 (annaship 2013-01-03 13:05:51 -0500   42) use Conjbpcdb;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   43) use IO::Handle;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   44) require 'pipeline_subs.pl'; #subroutines
e71f9464 (annaship 2013-01-03 13:05:51 -0500   45) use Time::HiRes qw(gettimeofday tv_interval);
e71f9464 (annaship 2013-01-03 13:05:51 -0500   46) use Time::Format qw(%time %strftime %manip);
e71f9464 (annaship 2013-01-03 13:05:51 -0500   47) use File::Temp qw/ tempfile tempdir /;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   48) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   49) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   50) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500   51) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   52) # Set up usage statement
e71f9464 (annaship 2013-01-03 13:05:51 -0500   53) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   54) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500   55) my $scriptHelp = "
e71f9464 (annaship 2013-01-03 13:05:51 -0500   56)   vamps_upload - refreshes tables: vamps_data_cube, vamps_sequences and vamps_export FROM pokey
e71f9464 (annaship 2013-01-03 13:05:51 -0500   57)   to VAMPS.
e71f9464 (annaship 2013-01-03 13:05:51 -0500   58)   \n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   59) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   60) my $usage = "
e71f9464 (annaship 2013-01-03 13:05:51 -0500   61)   Usage:  vamps_upload [-e -i -t -a] [-s startpoint] vampsHostName
e71f9464 (annaship 2013-01-03 13:05:51 -0500   62) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   63)   Ex:  vamps_upload -a vampsdev [export the data, import to dev, and transfer on the dev side]
e71f9464 (annaship 2013-01-03 13:05:51 -0500   64)   vamps_upload -i -t vamps [update the production website!]
e71f9464 (annaship 2013-01-03 13:05:51 -0500   65) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   66)   Options:
e71f9464 (annaship 2013-01-03 13:05:51 -0500   67)   -e export records to text files
e71f9464 (annaship 2013-01-03 13:05:51 -0500   68)   -i import FROM text file to transfer table
e71f9464 (annaship 2013-01-03 13:05:51 -0500   69)   -t swap data FROM transfer tables to production tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500   70)   -a do it all! (-e -i -t)
e71f9464 (annaship 2013-01-03 13:05:51 -0500   71)   -s start point (projectdataset, taxonomy, sequences, reads, keys, norm_tables, rename_norm, add_illumina, rollback_illumina)
e71f9464 (annaship 2013-01-03 13:05:51 -0500   72)   -stop  stop immediately after selected step (projectdataset, taxonomy, sequences, reads, keys)
e71f9464 (annaship 2013-01-03 13:05:51 -0500   73)   -skip skip recreating the vamps_projects_datasets table on env454
e71f9464 (annaship 2013-01-03 13:05:51 -0500   74)   -no_analyze prevents the mysql analyze table query
e71f9464 (annaship 2013-01-03 13:05:51 -0500   75)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500   76)   \n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   77) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   78) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500   79) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   80) # Definition statements
e71f9464 (annaship 2013-01-03 13:05:51 -0500   81) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500   82) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500   83) my $argNum       = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500   84) my $tblSuffix    = "_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   85) my $tblSuffixOld = "_previous";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   86) my $fileSuffix   = ".txt";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   87) my $subdir       = "exports/";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   88) my $chunk_size_reads = 500000;  # dump data to transfer files 500K records at a time FOR READS
1939a05e (annaship 2014-11-13 16:07:32 -0500   89) # my $chunk_size_seqs  = 250000;  # dump data to transfer files 250K records at a time FOR SEQS
e71f9464 (annaship 2013-01-03 13:05:51 -0500   90) my $do_not_analyze   = 0;
6df2bab4 (annaship 2014-04-17 11:25:14 -0400   91) my $test_only        = 0;
6df2bab4 (annaship 2014-04-17 11:25:14 -0400   92) my $illSuffix        = "_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   93) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500   94) # Host, database, log etc
e71f9464 (annaship 2013-01-03 13:05:51 -0500   95) my $logFile = "vamps_upload.log";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   96) #my $publicVAMPSHostName = "vamps.mbl.edu";
57f46ef3 (annaship 2013-02-15 16:15:12 -0500   97) my $publicVAMPSHostName = "vampsdb";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   98) #my $privateVAMPSHostName = "vampsdev.mbl.edu";
e71f9464 (annaship 2013-01-03 13:05:51 -0500   99) my $privateVAMPSHostName = "bpcweb7";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  100) # my $publicVAMPSHostName = "bpcweb7"; (dev)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  101) my $sourceHost = "bpcdb1";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  102) my $sourceDB   = "env454";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  103) my $vampsHost  = ''; # user-specified below
e71f9464 (annaship 2013-01-03 13:05:51 -0500  104) my $vampsDB    = "vamps";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  105) # my $vampsDB    = "vamps2";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  106) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  107) # ====== illumina tables ======
e71f9464 (annaship 2013-01-03 13:05:51 -0500  108) my $sequence_ill_table = "sequence_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  109) my $sequence_ill_id    = $sequence_ill_table . "_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  110) my $run_info_ill_table = "run_info_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  111) my $run_info_ill_id    = $run_info_ill_table . "_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  112) # unique sequence info = taxonomy info
e71f9464 (annaship 2013-01-03 13:05:51 -0500  113) my $seq_tax_ill_table  = "sequence_uniq_info_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  114) my $seq_tax_ill_id     = $seq_tax_ill_table . "_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  115) # sequence per run/project/dataset = global id 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  116) my $glob_seq_id_table = "sequence_pdr_info_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  117) my $glob_seq_id_id    = $glob_seq_id_table . "_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  118) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  119) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  120) # New normalized tables on vamps
e71f9464 (annaship 2013-01-03 13:05:51 -0500  121) # TODO: remove "new_" when ready
e71f9464 (annaship 2013-01-03 13:05:51 -0500  122) # TODO: remove "_copy"  after testing
e71f9464 (annaship 2013-01-03 13:05:51 -0500  123) my $class_table             = "new_class";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  124) my $family_table            = "new_family";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  125) my $genus_table             = "new_genus";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  126) my $orderx_table            = "new_orderx";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  127) my $phylum_table            = "new_phylum";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  128) my $species_table           = "new_species";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  129) my $strain_table            = "new_strain";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  130) my $superkingdom_table      = "new_superkingdom";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  131) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  132) my $env_sample_source_table = "new_env_sample_source";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  133) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  134) my $contact_table           = "new_contact";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  135) my $dataset_table           = "new_dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  136) my $project_table           = "new_project";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  137) my $project_dataset_table   = "new_project_dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  138) my $rank_table              = "new_rank";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  139) my $rank_number_table       = "new_rank_number";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  140) my $sequence_table          = "new_sequence";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  141) my $summed_data_cube_table  = "new_summed_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  142) my $taxon_string_table      = "new_taxon_string";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  143) my $taxonomy_table          = "new_taxonomy";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  144) my $user_table              = "new_user";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  145) my $user_contact_table      = "new_user_contact";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  146) # todo: new_read_id on prod!!!
e71f9464 (annaship 2013-01-03 13:05:51 -0500  147) my $read_id_table           = "new_read_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  148) # dop table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  149) my $vamps_auth_table        = "vamps_auth";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  150) my $vamps_sequences_transfer_temp_table = "vamps_sequences_transfer_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  151) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  152) my %previous_res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  153) my %new_res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  154) my @table_names_update;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  155) my @query_names_exec;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  156) my $missed_read_ids_list = "";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  157) my $query_to_norm_number = 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  158) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  159) my %norm_table_names =
e71f9464 (annaship 2013-01-03 13:05:51 -0500  160) (
e71f9464 (annaship 2013-01-03 13:05:51 -0500  161)  "class" 						=> $class_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  162)  "contact" 					=> $contact_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  163)  "dataset" 					=> $dataset_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  164)  "family" 					=> $family_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  165)  "genus" 						=> $genus_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  166)  "orderx" 					=> $orderx_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  167)  "phylum" 					=> $phylum_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  168)  "project" 					=> $project_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  169)  "project_dataset" 	=> $project_dataset_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  170)  # "read_id"          => $read_id_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  171)  # "sequence"         => $sequence_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  172)  "species" 					=> $species_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  173)  "strain" 					=> $strain_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  174)  "summed_data_cube" => $summed_data_cube_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  175)  "superkingdom" 		=> $superkingdom_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  176)  "taxon_string" 		=> $taxon_string_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  177)  "taxonomy" 				=> $taxonomy_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  178)  "user" 						=> $user_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  179)  "user_contact"     => $user_contact_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  180) );
e71f9464 (annaship 2013-01-03 13:05:51 -0500  181) # todo:
e71f9464 (annaship 2013-01-03 13:05:51 -0500  182) # "sequence"         => $sequence_table,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  183) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  184) # Taxonomy data cube (un-integrated)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  185) my $final_taxes_table = "vamps_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  186) my $tmp_taxes_table = $final_taxes_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  187) my $previous_taxes_table = $final_taxes_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  188) my $taxesFile = $subdir . $tmp_taxes_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  189) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  190) # Integrated (summed) data cube
e71f9464 (annaship 2013-01-03 13:05:51 -0500  191) my $final_summed_taxes_table = "vamps_junk_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  192) my $tmp_summed_taxes_table = $final_summed_taxes_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  193) my $previous_summed_taxes_table = $final_summed_taxes_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  194) my $summedTaxesFile = $subdir . $tmp_summed_taxes_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  195) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  196) # Table grouped by sequence
e71f9464 (annaship 2013-01-03 13:05:51 -0500  197) my $final_seqs_table = "vamps_sequences";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  198) my $tmp_seqs_table = $final_seqs_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  199) my $previous_seqs_table = $final_seqs_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  200) my $seqsFile = $subdir . $tmp_seqs_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  201) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  202) # Table by individual reads
e71f9464 (annaship 2013-01-03 13:05:51 -0500  203) my $final_reads_table = "vamps_export";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  204) my $tmp_reads_table = $final_reads_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  205) my $previous_reads_table = $final_reads_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  206) my $readsFile = $subdir . $tmp_reads_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  207) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  208) # Table containing unique project/dataset combos, used for community visualization
e71f9464 (annaship 2013-01-03 13:05:51 -0500  209) # on the vamps side
e71f9464 (annaship 2013-01-03 13:05:51 -0500  210) my $final_project_dataset_table = "vamps_projects_datasets";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  211) my $tmp_project_dataset_table = $final_project_dataset_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  212) my $previous_project_dataset_table = $final_project_dataset_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  213) my $projectDatasetFile = $subdir . $tmp_project_dataset_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  214) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  215) # Unique list of taxa and whether or not they have kids (need to open in the SELECT menu)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  216) my $final_distinct_taxa_table = "vamps_taxonomy";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  217) my $tmp_distinct_taxa_table = $final_distinct_taxa_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  218) my $previous_distinct_taxa_table = $final_distinct_taxa_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  219) my $distinctTaxaFile = $subdir . $tmp_distinct_taxa_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  220) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  221) # Table containing descriptions for each project
e71f9464 (annaship 2013-01-03 13:05:51 -0500  222) my $final_project_desc_table = "vamps_projects_info";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  223) my $tmp_project_desc_table = $final_project_desc_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  224) my $previous_project_desc_table = $final_project_desc_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  225) my $projectDescFile = $subdir . $tmp_project_desc_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  226) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  227) # Table containing project/dataset counts for each project
e71f9464 (annaship 2013-01-03 13:05:51 -0500  228) # local env454 copy for use in joining
e71f9464 (annaship 2013-01-03 13:05:51 -0500  229) my $final_project_dataset_counts_table = "vamps_projects_datasets";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  230) my $tmp_project_dataset_counts_table = $final_project_dataset_counts_table . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  231) my $previous_project_dataset_counts_table = $final_project_dataset_counts_table . $tblSuffixOld;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  232) my $projectDatasetCountsFile = $subdir . $tmp_project_dataset_counts_table . $fileSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  233) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  234) # env454 source tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500  235) my $source_tax_table											= "tagtax";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  236) my $source_tax_assignment_table						= "tax_assignment";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  237) my $source_trim_table											= "trimseq";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  238) my $source_trimsequence_table							= "trimsequence";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  239) my $source_gast_table											= "gast_concat";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  240) my $source_longs_tax_table								= "tagtax_longs";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  241) my $source_project_table									= "project";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  242) my $source_dataset_table									= "dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  243) my $source_run_table											= "run";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  244) my $source_taxonomy_table									= "taxonomy";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  245) my $source_rank_table											= "rank";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  246) my $source_trimseq_not_chimera_temp_table	= "trimseq_not_chimera_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  247) my $source_vamps_sequences_temp_table			= "vamps_sequences_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  248) # my $target_vamps_sequences_temp_table     = "vamps_sequences_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  249) #my $source_unique_trim_table = "trimseq_illumina";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  250) #my $source_unique_tax_table = "tagtax_uniques";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  251) # env454 destination table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  252) #my $icomm_dates_table = "icomm2vamps";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  253) # final_project_dataset_counts_table = vamps_projects_datasets
e71f9464 (annaship 2013-01-03 13:05:51 -0500  254) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  255) # env454 source of dataset information
e71f9464 (annaship 2013-01-03 13:05:51 -0500  256) # my $datasets_info_table = 'vamps_projects_datasets_info';
e71f9464 (annaship 2013-01-03 13:05:51 -0500  257) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  258) ## Chimera filter added 2011-03-15
e71f9464 (annaship 2013-01-03 13:05:51 -0500  259) my $source_chimera_table = 'chimeras';
e71f9464 (annaship 2013-01-03 13:05:51 -0500  260) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  261) # vamps source tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500  262) my $user_uploads_table = "vamps_data_cube_uploads";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  263) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  264) # other
e71f9464 (annaship 2013-01-03 13:05:51 -0500  265) my $sqlImportCommand = "/usr/local/mysql/bin/mysqlimport";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  266) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  267) my $export = 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  268) my $import = 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  269) my $transfer = 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  270) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  271) # Define the list of ranks
e71f9464 (annaship 2013-01-03 13:05:51 -0500  272) #my @ranks = ('superkingdom','phylum','class','orderx','family','genus','species','strain');
e71f9464 (annaship 2013-01-03 13:05:51 -0500  273) # Andy -- I moved this FROM below so it would be available throughout the code
e71f9464 (annaship 2013-01-03 13:05:51 -0500  274) my @ranks = ('superkingdom','phylum','class','orderx','family','genus','species','strain');
e71f9464 (annaship 2013-01-03 13:05:51 -0500  275) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  276) my $start = 'projectdataset';
e71f9464 (annaship 2013-01-03 13:05:51 -0500  277) my $stop = 'final';
e71f9464 (annaship 2013-01-03 13:05:51 -0500  278) my $skip = 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  279) my $commandline = $0 . " " . join(" ", @ARGV);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  280) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  281) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  282) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  283) # Test for commandline arguments
e71f9464 (annaship 2013-01-03 13:05:51 -0500  284) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  285) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  286) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  287) if (! $ARGV[0] )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  288) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  289)   print $scriptHelp;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  290)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  291)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  292) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  293) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  294) while ((scalar @ARGV > 0) && ($ARGV[0] =~ /^-/))
e71f9464 (annaship 2013-01-03 13:05:51 -0500  295) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  296)   if ($ARGV[0] =~ /-h/)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  297)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  298)     print $scriptHelp;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  299)     print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  300)     exit 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  301)   } elsif ($ARGV[0] eq "-e")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  302)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  303)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  304)     $export = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  305)   } elsif ($ARGV[0] eq "-i")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  306)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  307)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  308)     $import = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  309)   } elsif ($ARGV[0] eq "-t")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  310)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  311)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  312)     $transfer = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  313)   } elsif ($ARGV[0] eq "-a")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  314)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  315)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  316)     $export = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  317)     $import = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  318)     $transfer = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  319)   } elsif ( ($ARGV[0] eq "-s") || ($ARGV[0] eq "-start") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  320)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  321)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  322)     $start = shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  323)   } elsif ($ARGV[0] eq "-stop")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  324)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  325)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  326)     $stop = shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  327)   } elsif ($ARGV[0] eq "-skip")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  328)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  329)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  330)     $skip = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  331)   } elsif ($ARGV[0] eq "-test")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  332)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  333)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  334)     $test_only = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  335)   } elsif ($ARGV[0] eq "-no_analyze")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  336)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  337)     shift @ARGV;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  338)     $do_not_analyze = 1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  339)   } elsif ($ARGV[0] =~ /^-/) #unknown parameter, just get rid of it
e71f9464 (annaship 2013-01-03 13:05:51 -0500  340)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  341)     print "Unknown commandline flag \"$ARGV[0]\".\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  342)     print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  343)     exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  344)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  345) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  346) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  347) if (scalar @ARGV != 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  348) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  349)   print "Incorrect commandline arguments.  Please try again.\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  350)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  351)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  352) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  353) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  354) $vampsHost = $ARGV[0];
e71f9464 (annaship 2013-01-03 13:05:51 -0500  355) if ( ( ($vampsHost ne "vamps") && ($vampsHost ne "vampsdev") ) || (scalar @ARGV > 1) )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  356) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  357)   print "Unrecognized vamps hostname, $vampsHost.  Host name must be either vamps or vampsdev\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  358)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  359)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  360) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  361) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  362) # Correct to full hostname
e71f9464 (annaship 2013-01-03 13:05:51 -0500  363) if ($vampsHost eq "vamps") {$vampsHost = $publicVAMPSHostName;} else {$vampsHost = $privateVAMPSHostName;}
e71f9464 (annaship 2013-01-03 13:05:51 -0500  364) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  365) # Check for valid start
e71f9464 (annaship 2013-01-03 13:05:51 -0500  366) if ( ($start ne "projectdataset") && ($start ne "taxonomy") && ($start ne "sequences") && ($start ne "reads") 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  367)     && ($start ne "keys") && ($start ne "norm_tables") && ($start ne "rename_norm") && ($start ne "add_illumina") 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  368)     && ($start ne "rollback_illumina") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  369) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  370)   print "Please SELECT a valid start option\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  371)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  372)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  373) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  374) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  375) $stop = "norm_tables" if ($start eq "norm_tables");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  376) $stop = "rename_norm" if ($start eq "rename_norm");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  377) $stop = "add_illumina" if ($start eq "add_illumina");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  378) $stop = "rollback_illumina" if ($start eq "rollback_illumina");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  379) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  380) # Check for valid stop
e71f9464 (annaship 2013-01-03 13:05:51 -0500  381) if ( ($stop ne "projectdataset") && ($stop ne "final") && ($stop ne "taxonomy") && ($stop ne "sequences") && ($stop ne "reads") 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  382)     && ($stop ne "keys") && ($stop ne "norm_tables") && ($stop ne "rename_norm") && ($stop ne "add_illumina") && ($stop ne "rollback_illumina"))
e71f9464 (annaship 2013-01-03 13:05:51 -0500  383) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  384)   print "Please SELECT a valid stop option\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  385)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  386)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  387) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  388) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  389) if ( (! $export) && (! $import) && (! $transfer)  )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  390) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  391)   print "SELECT one of -e -i -t or -a to upload data, or
e71f9464 (annaship 2013-01-03 13:05:51 -0500  392)   set start to run phpscripts only (-s phpscripts)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  393)   print $usage;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  394)   exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  395) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  396) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  397) # Check for the subdirectory
e71f9464 (annaship 2013-01-03 13:05:51 -0500  398) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  399) if (! -d $subdir)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  400) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  401)   my $can_mkdir = mkdir $subdir;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  402)   if (! $can_mkdir)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  403)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  404)     print "Unable to locate or create subdirectory, $subdir, for exporting files.\nExiting.\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  405)     exit -1;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  406)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  407) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  408) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  409) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  410) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  411) # Open the LOG file for writing
e71f9464 (annaship 2013-01-03 13:05:51 -0500  412) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  413) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  414) open(LOG, ">>$logFile") or warn "Unable to write to log file: $logFile. (" . (localtime) .")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  415) open(STDERR, ">>$logFile");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  416) print LOG "\n\n" . (localtime) . "\n$commandline\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  417) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  418) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  419) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  420) # Connect to the databases
e71f9464 (annaship 2013-01-03 13:05:51 -0500  421) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  422) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  423) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  424) my $conSource = Conjbpcdb::new($sourceHost, $sourceDB);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  425) my $dbhSource = $conSource->dbh();
e71f9464 (annaship 2013-01-03 13:05:51 -0500  426) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  427) my $conVamps = Conjbpcdb::new($vampsHost, $vampsDB);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  428) my $dbhVamps = $conVamps->dbh();
e71f9464 (annaship 2013-01-03 13:05:51 -0500  429) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  430) $dbhSource->do("set sql_mode=traditional");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  431) $dbhVamps->do("set sql_mode=traditional");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  432) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  433) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  434) # Run the taxonomy tables, the list of datasets and taxonomy and dataset counts
e71f9464 (annaship 2013-01-03 13:05:51 -0500  435) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  436) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  437) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  438) if ($start eq "projectdataset")
e71f9464 (annaship 2013-01-03 13:05:51 -0500  439) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  440) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  441)   #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  442)   #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  443)   # First get read counts for each dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500  444)   #     to be used for adding normalization (percent) for all read counts by dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500  445)   #     and send out to project_dataset_counts
e71f9464 (annaship 2013-01-03 13:05:51 -0500  446)   #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  447)   #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  448) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  449)   if ($export)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  450)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  451)     if (! $skip)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  452)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  453)       # create an auxilary table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  454)       print "PPP1: \$test_only = $test_only\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  455) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  456) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  457)       PrintUpdate("Calculating project / dataset counts\n");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  458)       # create new project_dataset_counts table in env454 (so can be used in joins)  and populate with this query
e71f9464 (annaship 2013-01-03 13:05:51 -0500  459) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  460)       # q 0b)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  461)       my $truncatePDCQuery = "TRUNCATE $final_project_dataset_counts_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  462)       # my $truncatePDCQuery_h = $dbhSource->prepare($truncatePDCQuery) or warn print LOG "Unable to prepare statement: $truncatePDCQuery.  Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  463)       # $truncatePDCQuery_h->execute or warn print LOG "Unable to execute SQL statement: $truncatePDCQuery.  Error:     " . $truncatePDCQuery_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  464)       print "q -1) truncatePDCQuery = $sourceHost.$truncatePDCQuery\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  465)       print LOG "q -1) truncatePDCQuery = $sourceHost.$truncatePDCQuery\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  466)       ExecuteInsert_bpcdb1($truncatePDCQuery);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  467) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  468)       # Insert the regular 454 tag sequence counts
e71f9464 (annaship 2013-01-03 13:05:51 -0500  469)       # q 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  470)       # my $insert_project_datasets =
e71f9464 (annaship 2013-01-03 13:05:51 -0500  471)       #   "INSERT IGNORE INTO $final_project_dataset_counts_table (project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info, project_id, dataset_id, rev_project_name)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  472)       #   SELECT DISTINCT project, dataset, count(read_id) AS dataset_count, 1, date_trimmed, dataset_description AS dataset_info, project_id, dataset_id, rev_project_name
e71f9464 (annaship 2013-01-03 13:05:51 -0500  473)       #     FROM trimseq 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  474)       #     LEFT JOIN chimeras USING(read_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  475)       #     LEFT JOIN $source_tax_table USING(read_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  476)       #     JOIN $source_tax_assignment_table USING(read_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  477)       #     JOIN $source_project_table USING(project_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  478)       #     JOIN $source_dataset_table USING(dataset_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  479)       #     JOIN $source_run_table USING(run_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  480)       #     WHERE ( (chimeric_denovo is NULL) OR (chimeric_ref is NULL) OR (chimeric = 'N') )        
e71f9464 (annaship 2013-01-03 13:05:51 -0500  481)       #     GROUP BY project, dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500  482)       # ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  483) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  484)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500  485)       my $insert_project_datasets =
e71f9464 (annaship 2013-01-03 13:05:51 -0500  486)         "INSERT IGNORE INTO $final_project_dataset_counts_table (project, dataset, dataset_count, has_sequence, dataset_info, project_id, dataset_id, rev_project_name)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  487)         SELECT DISTINCT project, dataset, sum(seq_count) AS dataset_count, 1, dataset_description AS dataset_info, project_id, dataset_id, rev_project_name
e71f9464 (annaship 2013-01-03 13:05:51 -0500  488)           FROM $glob_seq_id_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  489)           join $run_info_ill_table using($run_info_ill_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  490)           JOIN project USING(project_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  491)           JOIN dataset USING(dataset_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  492)           JOIN run USING(run_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  493)           GROUP BY project, dataset;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  494) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  495)       print "q 1) insert_project_datasets = $sourceHost.$insert_project_datasets\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  496)       print LOG "q 1) insert_project_datasets = $sourceHost.$insert_project_datasets\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  497) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  498)       ExecuteInsert_bpcdb1($insert_project_datasets);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  499)       #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  500)       # my $insert_project_datasets_h = $dbhSource->prepare($insert_project_datasets) or warn print LOG "Unable to prepare statement: $insert_project_datasets. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  501)       # $insert_project_datasets_h->execute or warn print LOG "Unable to execute SQL statement: $insert_project_datasets.  Error: " . $insert_project_datasets_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  502) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  503)       # Insert the sequence counts for the additional full length taxonomy (tagtax_longs)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  504)       # q 1a)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  505)       my $insert_project_datasets_a =
e71f9464 (annaship 2013-01-03 13:05:51 -0500  506)         "INSERT IGNORE INTO $final_project_dataset_counts_table (project, dataset, dataset_count,                   has_sequence, date_trimmed, dataset_info,                       project_id, dataset_id, rev_project_name)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  507)                                                  SELECT DISTINCT project, dataset, count(read_id) AS dataset_count, 0,            'unknown',    dataset_description AS dataset_info, project_id, dataset_id, rev_project_name
e71f9464 (annaship 2013-01-03 13:05:51 -0500  508)         FROM $source_longs_tax_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  509)         LEFT JOIN $source_project_table USING(project_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  510)         LEFT JOIN $source_dataset_table USING(dataset_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  511)         GROUP BY project, dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500  512)       ";
dfa847ab (annaship 2014-11-07 11:49:58 -0500  513)         # "INSERT INTO $final_project_dataset_counts_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  514)         # SELECT 0, project, dataset, count(*), 0, 'unknown', dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500  515)         # FROM $source_longs_tax_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  516)         # GROUP BY project, dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  517)       # $insert_project_datasets_h = $dbhSource->prepare($insert_project_datasets) or warn print LOG "Unable to prepare statement: $insert_project_datasets. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  518)       # $insert_project_datasets_h->execute or warn print LOG "Unable to execute SQL statement: $insert_project_datasets.  Error: " . $insert_project_datasets_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  519)       print "q 1a) insert_project_datasets = $sourceHost.$insert_project_datasets_a\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  520)       print LOG "q 1a) insert_project_datasets = $sourceHost.$insert_project_datasets_a\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  521) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  522)       # ExecuteInsert_bpcdb1($insert_project_datasets_a);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  523) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  524)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  525) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  526)     # Dump the table for importing to vamps (SELECT FROM sourceHost)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  527)     # q 2)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  528)     my $select_project_datasets = "SELECT DISTINCT id, project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info FROM $final_project_dataset_counts_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  529)     ExecuteDump($select_project_datasets, $projectDatasetCountsFile);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  530)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  531) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  532)   if ($import)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  533)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  534)     PrintUpdate("Inserting into $tmp_project_dataset_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  535)     CreateEmpty($tmp_project_dataset_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  536)     ExecuteLoad($projectDatasetFile, $tmp_project_dataset_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  537) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  538)     unless($do_not_analyze)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  539)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  540)       PrintUpdate("Analyzing $tmp_project_dataset_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  541)       AnalyzeTable($tmp_project_dataset_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  542)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  543)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  544) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  545)   if ($transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  546)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  547)     PrintUpdate("Swapping $final_project_dataset_table tables");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  548)     SwapNew($tmp_project_dataset_table, $final_project_dataset_table, $previous_project_dataset_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  549)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500  550)     # add code here to update the *NEW* (as of 2012-04-26) vamps_datasets_date table after swapping  -AAV
e71f9464 (annaship 2013-01-03 13:05:51 -0500  551)     my $insert_date_query = "INSERT IGNORE into vamps_datasets_date SELECT 0,project,dataset,curdate() FROM vamps_projects_datasets";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  552)     ExecuteInsert($insert_date_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  553)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  554) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  555) if ($stop eq "projectdataset") {exit 0;}
e71f9464 (annaship 2013-01-03 13:05:51 -0500  556) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  557) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500  558) #
4ab99369 (annaship 2014-11-12 17:42:57 -0500  559) # SELECT count to use in for export
d927c5fa (annaship 2014-11-05 11:46:22 -0500  560) #
d927c5fa (annaship 2014-11-05 11:46:22 -0500  561) #######################################
4ab99369 (annaship 2014-11-12 17:42:57 -0500  562) sub select_cnt_for_limit()
4ab99369 (annaship 2014-11-12 17:42:57 -0500  563) {
4ab99369 (annaship 2014-11-12 17:42:57 -0500  564)   my $table_name = shift;
4ab99369 (annaship 2014-11-12 17:42:57 -0500  565)   my $table_id = $table_name . "_id";
4ab99369 (annaship 2014-11-12 17:42:57 -0500  566)   my $selectCountReads =
4ab99369 (annaship 2014-11-12 17:42:57 -0500  567)   # "select count($glob_seq_id_id) from $glob_seq_id_table;";
4ab99369 (annaship 2014-11-12 17:42:57 -0500  568)     "select count($table_id) from $table_name";
1939a05e (annaship 2014-11-13 16:07:32 -0500  569)   print "q AA) selectCountReads = $sourceHost.$selectCountReads\n";
1939a05e (annaship 2014-11-13 16:07:32 -0500  570)   print LOG "q AA) selectCountReads = $sourceHost.$selectCountReads\n";
1939a05e (annaship 2014-11-13 16:07:32 -0500  571)   my $selectCountReads_h = ExecuteSelect($selectCountReads);
1939a05e (annaship 2014-11-13 16:07:32 -0500  572)   # my $selectCountReads_h = ExecuteSelectTest($selectCountReads);
4ab99369 (annaship 2014-11-12 17:42:57 -0500  573) 
4ab99369 (annaship 2014-11-12 17:42:57 -0500  574)   my ($selectCountReads_int) = $selectCountReads_h->fetchrow_array();  
4ab99369 (annaship 2014-11-12 17:42:57 -0500  575)   print "1) selectCountReads_int = $selectCountReads_int\n";
4ab99369 (annaship 2014-11-12 17:42:57 -0500  576)   print LOG "1) selectCountReads_int = $selectCountReads_int\n";
4ab99369 (annaship 2014-11-12 17:42:57 -0500  577)   return $selectCountReads_int;
4ab99369 (annaship 2014-11-12 17:42:57 -0500  578) }
d927c5fa (annaship 2014-11-05 11:46:22 -0500  579) 
4ab99369 (annaship 2014-11-12 17:42:57 -0500  580) #######################################
4ab99369 (annaship 2014-11-12 17:42:57 -0500  581) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  582) # SELECT count to use for vamps_sequence
4ab99369 (annaship 2014-11-12 17:42:57 -0500  583) #
4ab99369 (annaship 2014-11-12 17:42:57 -0500  584) #######################################
4ab99369 (annaship 2014-11-12 17:42:57 -0500  585) 
4ab99369 (annaship 2014-11-12 17:42:57 -0500  586) my $selectCountProject =
4ab99369 (annaship 2014-11-12 17:42:57 -0500  587) # "select count($glob_seq_id_id) from $glob_seq_id_table;";
aa11e644 (annaship 2014-11-12 17:58:25 -0500  588)   "select count(distinct project_id) from vamps_projects_datasets";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  589)   print "q AA1) selectCountProject = $sourceHost.$selectCountProject\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  590)   print LOG "q AA1) selectCountProject = $sourceHost.$selectCountProject\n";
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  591)   my $selectCountProject_h = ExecuteSelect($selectCountProject);
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  592)   # my $selectCountProject_h = ExecuteSelectTest($selectCountProject);
4ab99369 (annaship 2014-11-12 17:42:57 -0500  593) 
4ab99369 (annaship 2014-11-12 17:42:57 -0500  594) my ($selectCountProject_int) = $selectCountProject_h->fetchrow_array();  
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  595) print "2) selectCountProject_int = $selectCountProject_int\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  596) print LOG "2) selectCountProject_int = $selectCountProject_int\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  597) 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  598) #######################################
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  599) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  600) # SELECT Illumina project_ids to use for vamps_sequence
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  601) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  602) #######################################
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  603) 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  604) my $select_ill_project_ids_q =
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  605)   "select distinct project_id from vamps_projects_datasets";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  606)   &print_query_out("q AA2) selectIllProjectIds", $sourceHost." ".$select_ill_project_ids_q);  
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  607) my @select_ill_project_ids = &prep_exec_fetchrow_array_query($dbhSource, $select_ill_project_ids_q);
4ab99369 (annaship 2014-11-12 17:42:57 -0500  608) 
d927c5fa (annaship 2014-11-05 11:46:22 -0500  609) #######################################
d927c5fa (annaship 2014-11-05 11:46:22 -0500  610) #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  611) # SELECT data for vamps_sequences and taxonomy
e71f9464 (annaship 2013-01-03 13:05:51 -0500  612) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500  613) #######################################
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  614) if ( ($start eq "projectdataset") || ($start eq "sequences") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500  615) {
d927c5fa (annaship 2014-11-05 11:46:22 -0500  616)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500  617)   # ON ENV454
e71f9464 (annaship 2013-01-03 13:05:51 -0500  618)   # 1) increase join_buffer - doesn't work
e71f9464 (annaship 2013-01-03 13:05:51 -0500  619)   # 2) drop vamps_sequences_transfer_temp
d927c5fa (annaship 2014-11-05 11:46:22 -0500  620)   # 3) create vamps_sequences_transfer_temp by chunks
e71f9464 (annaship 2013-01-03 13:05:51 -0500  621)   # 4) decrease join_buffer - doesn't work
e71f9464 (annaship 2013-01-03 13:05:51 -0500  622)   # 5) dump vamps_sequences_transfer_temp on disc
e71f9464 (annaship 2013-01-03 13:05:51 -0500  623)   # change ON VAMPS  
e71f9464 (annaship 2013-01-03 13:05:51 -0500  624)   # 6) drop vamps_sequences_transfer_temp table on VAMPS
e71f9464 (annaship 2013-01-03 13:05:51 -0500  625)   # 7) upload vamps_sequences_transfer_temp to VAMPS  
e71f9464 (annaship 2013-01-03 13:05:51 -0500  626)   # 8) drop transfer table
e71f9464 (annaship 2013-01-03 13:05:51 -0500  627)   # 9) create vamps_sequences_transfer
e71f9464 (annaship 2013-01-03 13:05:51 -0500  628)   # 10) insert data into vamps_sequences_transfer from temp (uncompress and concat)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  629)   my $seq_file_name = $subdir . "vamps_sequences_transfer.sql";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  630)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500  631)   if ($export)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  632)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  633)     PrintUpdate("Dumping data for $final_seqs_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  634) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  635)     # mysql> show global variables like "join_BUFFER_SIZE";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  636)     # +------------------+---------+
e71f9464 (annaship 2013-01-03 13:05:51 -0500  637)     # | Variable_name    | Value   |
e71f9464 (annaship 2013-01-03 13:05:51 -0500  638)     # +------------------+---------+
e71f9464 (annaship 2013-01-03 13:05:51 -0500  639)     # | join_buffer_size | 8388608 |
e71f9464 (annaship 2013-01-03 13:05:51 -0500  640)     my $join_buffer_size_old = 8388608;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  641)     my $join_buffer_size_new = 8388608*1024*1024;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  642)     print "TTT: \$test_only = $test_only\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  643)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500  644)     # # 1) increase join_buffer
e71f9464 (annaship 2013-01-03 13:05:51 -0500  645)     # # q 6-1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  646)     # my $join_buffer_increase_temp = "SET GLOBAL join_buffer_size = $join_buffer_size_new;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  647)     # &print_query_out("q 6-1) join_buffer_increase_temp", $sourceHost." ".$join_buffer_increase_temp);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  648)     # ExecuteInsert_bpcdb1($join_buffer_increase_temp) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  649)     # q 6-2)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  650)     # 2) drop vamps_sequences_transfer table on env454
e71f9464 (annaship 2013-01-03 13:05:51 -0500  651)     my $drop_temp_seq = "DROP table IF EXISTS $sourceDB.vamps_sequences_transfer_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  652)     &print_query_out("q 6-2) drop_temp_seq", $sourceHost." ".$drop_temp_seq);
d927c5fa (annaship 2014-11-05 11:46:22 -0500  653)     # `mysql -h bpcdb1 env454 -e $drop_temp_seq` unless ($test_only == 1);
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  654)     ExecuteInsert_bpcdb1($drop_temp_seq);
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  655)     # ExecuteSelectTest($drop_temp_seq);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  656)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500  657)     # q 6-3)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  658)     # 3) create vamps_sequences_transfer table on env454 (5 h)
7af2a341 (annaship 2014-11-05 11:11:01 -0500  659)     # Tue Nov  4 15:53:28 EST 2014 -"- by chunks
7af2a341 (annaship 2014-11-05 11:11:01 -0500  660)     
7af2a341 (annaship 2014-11-05 11:11:01 -0500  661)     # create the table
7af2a341 (annaship 2014-11-05 11:11:01 -0500  662)     my $create_temp_seq_table_query = "CREATE TABLE IF NOT EXISTS vamps_sequences_transfer_temp (
7af2a341 (annaship 2014-11-05 11:11:01 -0500  663)             id int(11) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
7af2a341 (annaship 2014-11-05 11:11:01 -0500  664)             frequency double NOT NULL DEFAULT 0 COMMENT 'sum seq_count (for this seq/project/dataset across all lines and runs) divided by dataset_count',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  665)             project_dataset varchar(100) NOT NULL DEFAULT '',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  666)             sequence_comp longblob NOT NULL,
7af2a341 (annaship 2014-11-05 11:11:01 -0500  667)             project varchar(32) NOT NULL,
7af2a341 (annaship 2014-11-05 11:11:01 -0500  668)             dataset varchar(64) NOT NULL DEFAULT '',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  669)             taxonomy varchar(300) NOT NULL DEFAULT '',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  670)             refhvr_ids text NOT NULL,
7af2a341 (annaship 2014-11-05 11:11:01 -0500  671)             rank varchar(32) NOT NULL DEFAULT '',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  672)             seq_count int(11) unsigned NOT NULL COMMENT 'sum seq_count for this seq/project/dataset across all lines and runs',
7af2a341 (annaship 2014-11-05 11:11:01 -0500  673)             distance decimal(7,5) DEFAULT NULL COMMENT 'gast_distance AS distance',
a0918830 (annaship 2014-11-18 11:06:04 -0500  674)             rep_id int(10) unsigned NOT NULL COMMENT 'sequence_pdr_info_ill_id AS rep_id',
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  675)             dataset_count mediumint(8) unsigned NOT NULL COMMENT 'number of reads in the dataset',
a0918830 (annaship 2014-11-18 11:06:04 -0500  676)             UNIQUE KEY `rep_id` (`rep_id`)            
7af2a341 (annaship 2014-11-05 11:11:01 -0500  677)           )  ;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  678)     ";
d927c5fa (annaship 2014-11-05 11:46:22 -0500  679)     &print_query_out("q 6-3) create_temp_seq_table_query", $sourceHost." ".$create_temp_seq_table_query);
d927c5fa (annaship 2014-11-05 11:46:22 -0500  680)     # `mysql -h bpcdb1 env454 -e $drop_temp_seq` unless ($test_only == 1);
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  681)     ExecuteInsert_bpcdb1($create_temp_seq_table_query);
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  682)     # ExecuteSelectTest($create_temp_seq_table_query);
7af2a341 (annaship 2014-11-05 11:11:01 -0500  683)     
7af2a341 (annaship 2014-11-05 11:11:01 -0500  684)     # get data and put in the table
7af2a341 (annaship 2014-11-05 11:11:01 -0500  685)     
4ab99369 (annaship 2014-11-12 17:42:57 -0500  686)     my $chunk_size_seqs  = 1;  # dump data to transfer files 1 project records at a time FOR SEQS
7af2a341 (annaship 2014-11-05 11:11:01 -0500  687)     # my $sourceHost = "bpcdb1";
d927c5fa (annaship 2014-11-05 11:46:22 -0500  688) 
4ab99369 (annaship 2014-11-12 17:42:57 -0500  689)     print "2) selectCountProject_int = $selectCountProject_int\n";
4ab99369 (annaship 2014-11-12 17:42:57 -0500  690)     print LOG "2) selectCountProject_int = $selectCountProject_int\n";
7af2a341 (annaship 2014-11-05 11:11:01 -0500  691) 
7af2a341 (annaship 2014-11-05 11:11:01 -0500  692)     my $from_here   = 0;
4ab99369 (annaship 2014-11-12 17:42:57 -0500  693)     my $reads_left  = int($selectCountProject_int);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  694)     
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  695)     # prepare insert_select_chunck_seq w "?"
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  696)     # run in a cycle w no prepare
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  697)     
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  698)     my $insert_select_chunck_seq = "INSERT INTO vamps_sequences_transfer_temp (sequence_comp, project, dataset, taxonomy, refhvr_ids, rank, seq_count, distance, rep_id, dataset_count)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  699)             SELECT sequence_comp, project, dataset, taxonomy, refhvr_ids, rank, sum(seq_count) AS seq_count,
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  700)                   gast_distance AS distance, sequence_pdr_info_ill_id AS rep_id, dataset_count
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  701)                   FROM sequence_ill
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  702)                   JOIN sequence_pdr_info_ill USING(sequence_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  703)                   JOIN run_info_ill USING(run_info_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  704)                   JOIN sequence_uniq_info_ill USING(sequence_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  705)                   JOIN taxonomy USING(taxonomy_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  706)                   JOIN rank USING(rank_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  707)                   JOIN vamps_projects_datasets USING(project_id, dataset_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  708)                   JOIN (
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  709)                       SELECT sequence_pdr_info_ill_id FROM sequence_pdr_info_ill 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  710)                         JOIN run_info_ill USING(run_info_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  711)                         JOIN (
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  712)                           SELECT DISTINCT project_id FROM vamps_projects_datasets ORDER BY project_id
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  713)                           LIMIT ?, ?
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  714)                           ) AS t USING(project_id)          
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  715)                       ) AS t USING(sequence_pdr_info_ill_id)              
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  716)                 GROUP BY sequence_ill_id, project_id, dataset_id
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  717)     ";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  718)     
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  719)     my $insert_select_chunck_seq_h = $dbhSource->prepare($insert_select_chunck_seq) or warn print LOG "Unable to prepare statement: $insert_select_chunck_seq. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
7af2a341 (annaship 2014-11-05 11:11:01 -0500  720) 
a0918830 (annaship 2014-11-18 11:06:04 -0500  721)     while($reads_left > 0)
a0918830 (annaship 2014-11-18 11:06:04 -0500  722)     {
a0918830 (annaship 2014-11-18 11:06:04 -0500  723)       print "START get_reads seq!!!\n";
a0918830 (annaship 2014-11-18 11:06:04 -0500  724)       print LOG "START get_reads seq!!!\n";
a0918830 (annaship 2014-11-18 11:06:04 -0500  725)       
a0918830 (annaship 2014-11-18 11:06:04 -0500  726)       my $start_get_reads_seq = time;
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  727)       # &insert_chunk();
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  728)       # ExecuteInsert_bpcdb1_no_prepare()
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  729)       $insert_select_chunck_seq_h->execute(($from_here, $chunk_size_seqs)) or warn print LOG "Unable to execute SQL statement: $insert_select_chunck_seq.  Error: " . $insert_select_chunck_seq_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  730)       
a0918830 (annaship 2014-11-18 11:06:04 -0500  731)       my $end_get_reads_seq   = time;
a0918830 (annaship 2014-11-18 11:06:04 -0500  732)       print "The total time of insert_chunk is ", $end_get_reads_seq - $start_get_reads_seq, "\n";
a0918830 (annaship 2014-11-18 11:06:04 -0500  733)       print LOG "The total time of insert_chunk is ", $end_get_reads_seq - $start_get_reads_seq, "\n";
a0918830 (annaship 2014-11-18 11:06:04 -0500  734) 
a0918830 (annaship 2014-11-18 11:06:04 -0500  735)       $reads_left -= $chunk_size_seqs;
a0918830 (annaship 2014-11-18 11:06:04 -0500  736)       $from_here += $chunk_size_seqs;
a0918830 (annaship 2014-11-18 11:06:04 -0500  737)     }
a0918830 (annaship 2014-11-18 11:06:04 -0500  738) 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  739)     # sub insert_chunk()
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  740)     # {
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  741)     #   my $insert_select_chunck_seq = "INSERT INTO vamps_sequences_transfer_temp (sequence_comp, project, dataset, taxonomy, refhvr_ids, rank, seq_count, distance, rep_id, dataset_count)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  742)     #           SELECT sequence_comp, project, dataset, taxonomy, refhvr_ids, rank, sum(seq_count) AS seq_count,
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  743)     #                 gast_distance AS distance, sequence_pdr_info_ill_id AS rep_id, dataset_count
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  744)     #                 FROM sequence_ill
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  745)     #                 JOIN sequence_pdr_info_ill USING(sequence_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  746)     #                 JOIN run_info_ill USING(run_info_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  747)     #                 JOIN sequence_uniq_info_ill USING(sequence_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  748)     #                 JOIN taxonomy USING(taxonomy_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  749)     #                 JOIN rank USING(rank_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  750)     #                 JOIN vamps_projects_datasets USING(project_id, dataset_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  751)     #                 JOIN (
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  752)     #                     SELECT sequence_pdr_info_ill_id FROM sequence_pdr_info_ill 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  753)     #                       JOIN run_info_ill USING(run_info_ill_id)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  754)     #                       JOIN (
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  755)     #                         SELECT DISTINCT project_id FROM vamps_projects_datasets ORDER BY project_id
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  756)     #                         LIMIT $from_here, $chunk_size_seqs
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  757)     #                         ) AS t USING(project_id)          
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  758)     #                     ) AS t USING(sequence_pdr_info_ill_id)              
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  759)     #               GROUP BY sequence_ill_id, project_id, dataset_id
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  760)     #   ";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  761)     #   &print_query_out("q 6-4) insert_select_chunck_seq", $sourceHost." ".$insert_select_chunck_seq);      
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  762)     #   my $selectReads_h = ExecuteInsert_bpcdb1($insert_select_chunck_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  763)     #   # my $selectReads_h = ExecuteSelectTest($insert_select_chunck_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  764)     # }
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  765) 
d183bd5c (annaship 2013-12-20 17:59:29 -0500  766)     # q 6-3a)
d183bd5c (annaship 2013-12-20 17:59:29 -0500  767)     # 3) update vamps_sequences_transfer table on env454 - add frequencies
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  768)     
d183bd5c (annaship 2013-12-20 17:59:29 -0500  769)     my $UPDATE_temp_seq = 
d183bd5c (annaship 2013-12-20 17:59:29 -0500  770)     "UPDATE vamps_sequences_transfer_temp
d183bd5c (annaship 2013-12-20 17:59:29 -0500  771)     SET frequency = vamps_sequences_transfer_temp.seq_count / dataset_count
d183bd5c (annaship 2013-12-20 17:59:29 -0500  772)     ";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  773) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  774)     # JOIN vamps_projects_datasets USING(project, dataset)
d183bd5c (annaship 2013-12-20 17:59:29 -0500  775)           
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  776)     &print_query_out("q 6-3a) UPDATE_temp_seq", $sourceHost." ".$UPDATE_temp_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  777)     my $start_time = time;
d183bd5c (annaship 2013-12-20 17:59:29 -0500  778)     ExecuteInsert_bpcdb1($UPDATE_temp_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  779)     my $end_time   = time;
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  780)     print "The total time of UPDATE_temp_seq is ", $end_time - $start_time, "\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  781)     print LOG "The total time of UPDATE_temp_seq is ", $end_time - $start_time, "\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  782) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  783)     # q 6-3b)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  784)     # 3) alter vamps_sequences_transfer table on env454 - add keys; used for taxonomy, see next section
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  785)     my $ALTER_temp_seq = 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  786)     "ALTER TABLE vamps_sequences_transfer_temp
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  787)     ADD KEY comb_key (project, dataset, taxonomy, seq_count)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  788)     ";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  789)     # JOIN vamps_projects_datasets USING(project, dataset)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  790)           
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  791)     &print_query_out("q 6-3b) ALTER_temp_seq", $sourceHost." ".$ALTER_temp_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  792)     $start_time = time;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  793)     ExecuteInsert_bpcdb1($ALTER_temp_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  794)     $end_time   = time;
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  795)     print "The total time of ALTER_temp_seq is ", $end_time - $start_time, "\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  796)     print LOG "The total time of ALTER_temp_seq is ", $end_time - $start_time, "\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  797)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500  798)     # # 4) decrease join_buffer
e71f9464 (annaship 2013-01-03 13:05:51 -0500  799)     # # q 6-4)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  800)     # my $join_buffer_decrease_temp = "SET GLOBAL join_buffer_size = $join_buffer_size_old;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  801)     # &print_query_out("q 6-4) join_buffer_decrease_temp", $sourceHost." ".$join_buffer_decrease_temp);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  802)     # ExecuteInsert_bpcdb1($join_buffer_decrease_temp) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  803)     # 5) dump vamps_sequences_transfer to a disc  
e71f9464 (annaship 2013-01-03 13:05:51 -0500  804)     # q 6-5)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  805)     my $dump_seq = "time mysqldump --skip-opt --disable-keys --lock-tables --extended-insert --quick --insert-ignore --host bpcdb1 env454 vamps_sequences_transfer_temp > $seq_file_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  806)     &print_query_out("q 6-5) dump_seq", $sourceHost." ".$dump_seq);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  807)     unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  808)     {
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  809)       $start_time = time;
e71f9464 (annaship 2013-01-03 13:05:51 -0500  810)       my $dump_sys = system($dump_seq);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  811)       $end_time   = time;
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  812)       print "The total time of dump seq_temp is ", $end_time - $start_time, "\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  813)       print LOG "The total time of dump seq_temp is ", $end_time - $start_time, "\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500  814)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500  815)       if ($dump_sys) {print "Error dumping vamps_sequences_transfer_temp from env454\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500  816)     }    
e71f9464 (annaship 2013-01-03 13:05:51 -0500  817)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  818)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500  819)   if ($import)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  820)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  821)     # -------- change on vamps --------
e71f9464 (annaship 2013-01-03 13:05:51 -0500  822)     # 6) drop vamps_sequences_transfer_temp table on VAMPS
e71f9464 (annaship 2013-01-03 13:05:51 -0500  823)     # q 6-6)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  824)     my $drop_vamps_sequences_transfer_temp = "DROP TABLE IF EXISTS vamps_sequences_transfer_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  825)     &print_query_out("q 6-6) drop_vamps_sequences_transfer_temp", $vampsHost." ".$drop_vamps_sequences_transfer_temp);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  826)     ExecuteInsert($drop_vamps_sequences_transfer_temp);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  827)     # 7) upload vamps_sequences_transfer_temp to VAMPS  
e71f9464 (annaship 2013-01-03 13:05:51 -0500  828)     # q 6-7)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  829)     my $upload_seq = "time mysql -h $vampsHost $vampsDB < $seq_file_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  830)     &print_query_out("q 6-7) upload_seq", $vampsHost." ".$upload_seq);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  831)     unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  832)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  833)       my $upload_sys = system($upload_seq);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  834)       if ($upload_sys) {print "Error uploading vamps_sequences_transfer_temp on VAMPS\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500  835)     }    
e71f9464 (annaship 2013-01-03 13:05:51 -0500  836)     # 8) drop vamps_sequences_transfer table on VAMPS
e71f9464 (annaship 2013-01-03 13:05:51 -0500  837)     # q 6-8)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  838)     my $drop_vamps_sequences_transfer = "DROP TABLE IF EXISTS vamps_sequences_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  839)     &print_query_out("q 6-8) drop_vamps_sequences_transfer", $vampsHost." ".$drop_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  840)     ExecuteInsert($drop_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  841)     # 9) create vamps_sequences_transfer
e71f9464 (annaship 2013-01-03 13:05:51 -0500  842)     # q 6-9)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  843)     my $create_vamps_sequences_transfer = "CREATE TABLE `vamps_sequences_transfer` (
e71f9464 (annaship 2013-01-03 13:05:51 -0500  844)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  845)       `sequence` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  846)       `project` varchar(64) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  847)       `dataset` varchar(64) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  848)       `taxonomy` varchar(255) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  849)       `refhvr_ids` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  850)       `rank` varchar(20) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  851)       `seq_count` int(11) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  852)       `frequency` double NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  853)       `distance` decimal(7,5) DEFAULT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  854)       `rep_id` char(15) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500  855)       `project_dataset` varchar(100) NOT NULL DEFAULT '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500  856)       PRIMARY KEY (`id`),
a0918830 (annaship 2014-11-18 11:06:04 -0500  857)       UNIQUE KEY rep_id (rep_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500  858)       KEY `project_dataset` (`project`,`dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500  859)       KEY `dataset` (`dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500  860)       KEY `sequence` (`sequence`(350)),
e71f9464 (annaship 2013-01-03 13:05:51 -0500  861)       KEY `project_dataset_conc_taxonomy` (`project_dataset`,`taxonomy`)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  862)     ) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1";
e71f9464 (annaship 2013-01-03 13:05:51 -0500  863)     # KEY `project_dataset_conc_seq` (`project_dataset`,`sequence`(350)),
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  864)     # UNIQUE KEY project_dataset_conc_seq (`project_dataset`,`sequence`(550)),
e71f9464 (annaship 2013-01-03 13:05:51 -0500  865) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  866)     &print_query_out("q 6-9) create_vamps_sequences_transfer", $vampsHost." ".$create_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  867)     ExecuteInsert($create_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  868)     # 10) insert data into vamps_sequences_transfer from temp (uncompress and concat)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  869)     # q 6-10)
3f130867 (annaship 2014-11-07 12:03:11 -0500  870)     my $insert_vamps_sequences_transfer = 'INSERT INTO vamps_sequences_transfer (sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, project_dataset)
a0918830 (annaship 2014-11-18 11:06:04 -0500  871)       select uncompress(sequence_comp) as sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, concat(project, "--", dataset) as project_dataset
3fb56f83 (annaship 2014-11-17 15:43:55 -0500  872)       from vamps_sequences_transfer_temp';
e71f9464 (annaship 2013-01-03 13:05:51 -0500  873)     &print_query_out("q 6-10) insert_vamps_sequences_transfer", $vampsHost." ".$insert_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  874)     ExecuteInsert($insert_vamps_sequences_transfer);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  875) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  876)     unless($do_not_analyze)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  877)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  878)       PrintUpdate("Analyzing vamps_sequences_transfer");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  879)       AnalyzeTable("vamps_sequences_transfer");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  880)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  881)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  882) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500  883)   if ($transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500  884)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500  885)     PrintUpdate("Swapping $final_seqs_table tables");
e71f9464 (annaship 2013-01-03 13:05:51 -0500  886)     SwapNew($tmp_seqs_table, $final_seqs_table, $previous_seqs_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500  887)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500  888) } # END start = sequences
e71f9464 (annaship 2013-01-03 13:05:51 -0500  889) if ($stop eq "sequences") {exit 0;}
e71f9464 (annaship 2013-01-03 13:05:51 -0500  890) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  891) ######################################
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  892) #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  893) # SELECT data for vamps_data_cube
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  894) #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  895) #######################################
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  896) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  897) if ( ($start eq "taxonomy") || ($start eq "sequences") || ($start eq "projectdataset") )
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  898) {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  899)   if ($export)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  900)   {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  901) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  902)     PrintUpdate("Selecting data for $final_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  903) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  904)     open(OUTTAX, ">$taxesFile") or warn print LOG "Unable to open SQL file: $taxesFile (". (localtime) . ")\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  905) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  906)     # SELECT the taxonomy and project/dataset information
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  907)     my $selectCube =
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  908)     "
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  909)     SELECT DISTINCT 0, project, dataset, taxonomy, rank, sum(seq_count) AS cnt, 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  910)       sum(seq_count) / dataset_count as frequency, dataset_count, 'GAST'
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  911)       FROM vamps_sequences_transfer_temp
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  912)     GROUP BY project, dataset, taxonomy
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  913)     ";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  914)     
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  915)     print "q 3) selectCube = $sourceHost.$selectCube\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  916)     print LOG "q 3) selectCube = $sourceHost.$selectCube\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  917)     my $selectCube_h = ExecuteSelect($selectCube);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  918) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  919)     #######################################
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  920)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  921)     # Insert the data into the VAMPS "junk" summed data cube table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  922)     # this must be done in perl because the records are edited as they are moved
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  923)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  924)     #######################################
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  925)     PrintUpdate("Exporting data for $final_taxes_table to $taxesFile");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  926) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  927)     # For each row in the SELECT statement, calculate remaining taxa ranks and write to file
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  928)     print OUTTAX join("\t", "id", "project", "dataset", "taxonomy", "superkingdom", "phylum", "class", "orderx", "family", "genus", "species", "strain", "rank", "cnt", "frequency", "dataset_count", "classifier") . "\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  929)     while(my @dataRow = $selectCube_h->fetchrow())
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  930)     {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  931)       # Need to split apart the taxonomy to create separate values for each taxonomic rank
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  932)       my @taxes = split(';', $dataRow[3]);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  933)       my @insertRow = @dataRow;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  934) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  935)       # Double check for empty taxonomy strings -- no agreement at superkingdom
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  936)       # 2010-05-18 changed FROM adding 'NA' table to 'superkinkdom_NA'
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  937)       if ($dataRow[3] eq '') {$dataRow[3] = 'Domain_NA';}
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  938) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  939)       # pop off the these to make room for rank-specific taxa, put on again later
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  940) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  941)       my $classifier = pop(@insertRow);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  942)       my $pdcount = pop(@insertRow);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  943)       my $frequency = pop(@insertRow);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  944)       my $cnt = pop(@insertRow);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  945)       my $rank = pop(@insertRow);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  946) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  947)       # For each rank (superkingdom --> strain) insert NAs for missing taxonomy off the end
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  948)       # 2010-05-18 changed FROM adding 'NA' table to $ranks[$i]."_NA";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  949)       for (my $i = 0; $i <= 7; $i++)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  950)       {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  951)         if ($#taxes < $i) { $taxes[$i] = $ranks[$i] . "_NA"; }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  952)       }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  953) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  954)       # add the taxonomy by ranks and put the count back on the end
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  955)       push @insertRow, @taxes;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  956)       push @insertRow, $rank;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  957)       push @insertRow, $cnt;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  958)       push @insertRow, $frequency;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  959)       push @insertRow, $pdcount;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  960)       push @insertRow, $classifier;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  961) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  962)       # Print to the text file
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  963)       print OUTTAX join("\t", @insertRow) . "\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  964)     }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  965)   }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  966) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  967)   #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  968)   # Load the taxes data
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  969)   #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  970)   if ($import)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  971)   {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  972)     PrintUpdate("Inserting data into $tmp_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  973) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  974)     # vamps_data_cube_transfer
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  975)     CreateEmpty($tmp_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  976)     ExecuteLoad($taxesFile, $tmp_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  977) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  978)     # my $update_new_taxa_name = "INSERT IGNORE INTO ? (?) SELECT distinct superkingdom FROM $tmp_taxes_table";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  979)     # my $update_new_taxa_name_prepered = &prep_query($update_new_taxa_name);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  980)     # foreach my $taxa_name ("superkingdom", "phylum", "class", "orderx", "family", "genus", "species", "strain")
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  981)     # {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  982)     #   my $table_name = "\$".$taxa_name."_table";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  983)     #   $update_new_taxa_name_prepered->execute($table_name, $taxa_name) || die "Unable to execute MySQL statement: $update_new_taxa_name\nError: " . $dbh->errstr . "(" . (localtime) . ")\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  984)     # }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  985) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  986) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  987)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  988)     # Create the summed (junk) data cube FROM the regular data cube
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  989)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  990) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  991)     PrintUpdate("Creating interim summed taxa table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  992)     # vamps_junk_data_cube_transfer
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  993)     CreateEmpty($tmp_summed_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  994) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  995)     # Step through each rank, FROM superkingdom down to strain
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  996)     # NOTE: user uploads is entirely separate FROM the env454 side
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  997)     # junk_data_cube is equivalent to junk_data_cube_pipe
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  998)     # and data_cube is equivalent to data_cube_uploads
81cd4f20 (annaship 2014-11-19 12:25:10 -0500  999)     #for my $source_table ($tmp_taxes_table, $user_uploads_table)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1000)     #{
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1001)     my $source_table = $tmp_taxes_table;
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1002) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1003)     #PrintUpdate("Loading summed taxa FROM $source_table to $tmp_summed_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1004)     PrintUpdate("Loading summed taxa FROM $tmp_taxes_table to $tmp_summed_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1005)     my @ranks_subarray; # array for building the growing list of taxonomic ranks
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1006)     for (my $i = 0; $i <= $#ranks; $i++)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1007)     {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1008)       #print "i: $i\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1009)       # Create the working list of taxonomic ranks
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1010)       push(@ranks_subarray, $ranks[$i]);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1011)       my $ranks_list = join(", ", @ranks_subarray); # i.e., superkingdom, phylum, class
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1012)       print "ranks list: $ranks_list\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1013) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1014)       # Insert statement, to insert integrated counts into the output data cube
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1015)       # Prefer to have only one prepare statement, but can't effectively include the
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1016)       # field names USING the "?" syntax.
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1017)       # q 4)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1018)       my $insertQuery =
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1019)         "INSERT INTO $tmp_summed_taxes_table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1020)         SELECT DISTINCT 0, concat_ws(';', $ranks_list) as taxonomy,
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1021)         sum(knt) as sum_tax_counts, sum(knt) / dataset_count AS frequency, dataset_count,
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1022)         ? AS rank, project, dataset, concat(project,'--',dataset), classifier
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1023)         FROM $source_table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1024)         WHERE taxon_string != ''
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1025)         GROUP BY project, dataset, $ranks_list
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1026)         HAVING length(taxonomy) - length(replace(taxonomy,';','')) >= $i";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1027)         # ORDER BY project, taxonomy";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1028)       print "q 4) insertQuery = dbhVamps.$insertQuery\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1029)       print LOG "q 4) insertQuery = dbhVamps.$insertQuery\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1030) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1031)       # Use the ranks_list and the rank index to execute the query
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1032)       ExecuteInsertPassVar($insertQuery, $i);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1033)     }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1034) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1035)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1036)     # Create Distinct Taxonomy Table (vamps_taxonomy))
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1037)     #
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1038)     PrintUpdate("Creating $tmp_distinct_taxa_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1039)     # vamps_taxonomy_transfer
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1040)     CreateEmpty($tmp_distinct_taxa_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1041)     # q 5)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1042)     my $insertDistinctTaxaQuery =
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1043)       "INSERT INTO $tmp_distinct_taxa_table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1044)       SELECT DISTINCT 0, taxon_string, rank,
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1045)       (CASE WHEN (taxon_string LIKE '%;NA' or taxon_string LIKE '%_NA') OR rank = 7 THEN 0 ELSE 1 END) AS num_kids
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1046)       FROM $tmp_summed_taxes_table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1047)       ";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1048) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1049)       # WHERE taxon_string not LIKE '%;NA;NA' and taxon_string not LIKE '%_NA;%_NA' and taxon_string != 'NA;NA'";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1050) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1051)     #         my $insertDistinctTaxaQuery =
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1052)     #         "INSERT INTO $tmp_distinct_taxa_table SELECT DISTINCT taxon_string, rank,
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1053)     #         (CASE WHEN taxon_string LIKE '%;NA' or rank = 7 THEN 0 ELSE 1 END) as num_kids
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1054)     #         FROM $tmp_summed_taxes_table
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1055)     #         WHERE taxon_string not LIKE '%;NA;NA' and taxon_string != 'NA;NA'";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1056)     print "q 5) insertDistinctTaxaQuery = dbhVamps.$insertDistinctTaxaQuery\n\n\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1057)     print LOG "q 5) insertDistinctTaxaQuery = dbhVamps.$insertDistinctTaxaQuery\n\n\n";
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1058)     ExecuteInsert($insertDistinctTaxaQuery);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1059) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1060)     unless($do_not_analyze)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1061)     {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1062)       PrintUpdate("Analyzing $tmp_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1063)       AnalyzeTable($tmp_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1064) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1065)       PrintUpdate("Analyzing $tmp_summed_taxes_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1066)       AnalyzeTable($tmp_summed_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1067) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1068)       PrintUpdate("Analyzing $tmp_distinct_taxa_table");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1069)       AnalyzeTable($tmp_distinct_taxa_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1070)     }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1071)   }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1072) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1073)   if ($transfer)
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1074)   {
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1075)     PrintUpdate("Swapping $final_taxes_table tables");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1076)     SwapNew($tmp_taxes_table, $final_taxes_table, $previous_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1077) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1078)     PrintUpdate("Swapping $final_summed_taxes_table tables");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1079)     SwapNew($tmp_summed_taxes_table, $final_summed_taxes_table, $previous_summed_taxes_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1080) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1081)     PrintUpdate("Swapping $final_distinct_taxa_table tables");
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1082)     SwapNew($tmp_distinct_taxa_table, $final_distinct_taxa_table, $previous_distinct_taxa_table);
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1083)   }
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1084) } # End start = taxonomy
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1085) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1086) if ($stop eq "taxonomy") {exit 0;}
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1087) 
81cd4f20 (annaship 2014-11-19 12:25:10 -0500 1088) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1089) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1090) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1091) # SELECT data for vamps_exports
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1092) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1093) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1094) if ( ($start eq "projectdataset") || ($start eq "taxonomy") || ($start eq "sequences") || ($start eq "reads") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1095) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1096)   if($export)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1097)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1098)     PrintUpdate("Dumping data for $final_reads_table into $readsFile");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1099) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1100)     unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1101)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1102)       # Clear out the old files, just in case
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1103)       my $rm_err = system("rm $readsFile*");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1104)       if ($rm_err) {print "Error removing old files $readsFile*\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1105)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1106) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1107)     #
00ff1470 (annaship 2014-04-17 10:14:35 -0400 1108)     # SELECT the data for vamps_export_transfer.txt_XX
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1109)     #
aa11e644 (annaship 2014-11-12 17:58:25 -0500 1110)     my $selectCountReads_int = &select_cnt_for_limit("sequence_pdr_info_ill");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1111) 
d927c5fa (annaship 2014-11-05 11:46:22 -0500 1112)     print "3) selectCountReads_int = $selectCountReads_int\n";
d927c5fa (annaship 2014-11-05 11:46:22 -0500 1113)     print LOG "3) selectCountReads_int = $selectCountReads_int\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1114) 
492b7df3 (annaship 2014-04-17 11:26:04 -0400 1115)     my $from_here   = 0;
7af2a341 (annaship 2014-11-05 11:11:01 -0500 1116)     my $reads_left  = int($selectCountReads_int);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1117)     my $file_number = 1;
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1118)     my $out_file    = $readsFile . "_" . $file_number;
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1119)     while($reads_left > 0)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1120)     {
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1121)         # print "URA01) from_here = $from_here\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1122)         # print "URA02) reads_left = $reads_left\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1123)         
b363b108 (annaship 2014-04-17 11:36:31 -0400 1124)         print "START get_reads!!!\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1125)         print LOG "START get_reads!!!\n";
b363b108 (annaship 2014-04-17 11:36:31 -0400 1126)         
a5e01184 (annaship 2014-04-17 13:04:26 -0400 1127)         my $start_get_reads = time;
a5e01184 (annaship 2014-04-17 13:04:26 -0400 1128)         my $selectReads_h   = &get_reads();
a5e01184 (annaship 2014-04-17 13:04:26 -0400 1129)         my $end_get_reads   = time;
4337031c (annaship 2014-04-17 13:06:57 -0400 1130)         print "The total time of get_reads is ", $end_get_reads - $start_get_reads, "\n";
4337031c (annaship 2014-04-17 13:06:57 -0400 1131)         print LOG "The total time of get_reads is ", $end_get_reads - $start_get_reads, "\n";
b363b108 (annaship 2014-04-17 11:36:31 -0400 1132) 
b363b108 (annaship 2014-04-17 11:36:31 -0400 1133)         print "START write_file!!!\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1134)         print LOG "START write_file!!!\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1135)         
7bd54541 (annaship 2014-04-17 11:33:27 -0400 1136)         &write_file($selectReads_h);
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1137)         $reads_left -= $chunk_size_reads;
6df2bab4 (annaship 2014-04-17 11:25:14 -0400 1138)         $from_here += $chunk_size_reads;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1139)         $file_number++;
7bd54541 (annaship 2014-04-17 11:33:27 -0400 1140)         $out_file   = $readsFile . "_" . $file_number;
11319276 (annaship 2014-04-17 11:37:54 -0400 1141)         print "========================\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1142)         print LOG "========================\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1143)         
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1144)     }
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1145)     
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1146)     sub get_reads()
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1147)     {
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1148)         # print "URA get_reads01) from_here  = $from_here\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1149)         # print "URA get_reads02) reads_left = $reads_left\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1150)         # q 7)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1151)         my $selectReads =
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1152)         "
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1153)         SELECT DISTINCT 0, $glob_seq_id_id as read_id, project, dataset,
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1154)           refhvr_ids, gast_distance as distance, taxonomy, uncompress(sequence_comp) as sequence, rank, '0000-00-00'
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1155)           FROM $glob_seq_id_table
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1156)           join $run_info_ill_table using($run_info_ill_id)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1157)           LEFT JOIN $seq_tax_ill_table using($sequence_ill_id)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1158)           JOIN $sequence_ill_table using($sequence_ill_id)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1159)           JOIN taxonomy USING(taxonomy_id)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1160)           JOIN rank USING(rank_id)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1161)           JOIN vamps_projects_datasets USING(project_id, dataset_id)
b2f50216 (annaship 2014-04-19 20:03:10 -0400 1162)           JOIN (
b2f50216 (annaship 2014-04-19 20:03:10 -0400 1163)             SELECT sequence_pdr_info_ill_id FROM sequence_pdr_info_ill ORDER BY sequence_pdr_info_ill_id
b2f50216 (annaship 2014-04-19 20:03:10 -0400 1164)             LIMIT $from_here, $chunk_size_reads
b2f50216 (annaship 2014-04-19 20:03:10 -0400 1165)             ) AS t USING(sequence_pdr_info_ill_id)          
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1166)         ";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1167)         print "q 7) selectReads = $sourceHost.$selectReads\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1168)         print LOG "q 7) selectReads = $sourceHost.$selectReads\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1169)         my $selectReads_h = ExecuteSelect($selectReads);
6df2bab4 (annaship 2014-04-17 11:25:14 -0400 1170)         return $selectReads_h;
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1171)     }
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1172)     
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1173)     sub write_file()
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1174)     {
6434d6bb (annaship 2014-04-17 11:28:30 -0400 1175)         my $selectReads_h = shift;
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1176)         print "write_file out_file = $out_file\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1177)         print LOG "write_file out_file = $out_file\n";
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1178) 
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1179)         # q 7b)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1180)         # step through and export individual pieces
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1181)         open(READS, ">$out_file");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1182)         print READS "id, read_id, project, dataset, refhvr_ids, distance, taxonomy, sequence, rank, date_trimmed\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1183) 
f7a63230 (annaship 2014-04-17 11:48:00 -0400 1184)         # print "URA1) selectReads_h = $sourceHost.$selectReads_h\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1185)         while(my @row = $selectReads_h->fetchrow_array)
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1186)         {
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1187)             print READS join("\t", @row) . "\n";
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1188)         }
1f0be496 (annaship 2014-04-17 11:16:19 -0400 1189)         close(READS);
1939a05e (annaship 2014-11-13 16:07:32 -0500 1190)     }    
6434d6bb (annaship 2014-04-17 11:28:30 -0400 1191)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1192) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1193)   if($import)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1194)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1195)     CreateEmpty($tmp_reads_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1196) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1197)     opendir SUBDIR, $subdir or die "Cannot open subdirectory\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1198) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1199)     my @files = readdir SUBDIR;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1200)     foreach my $out_file (@files)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1201)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1202)       #print "$out_file $readsFile\n";   # $readsFile: exports/vamps_export_transfer.txt
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1203)       # $tmp_reads_table . $fileSuffix
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1204)       my $reads_fileName = $subdir . $out_file;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1205)       if("$reads_fileName" =~ /$readsFile/)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1206)       {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1207)         #print "$reads_fileName\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1208)         ExecuteLoad($reads_fileName, $tmp_reads_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1209)       }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1210)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1211)     close(SUBDIR);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1212) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1213)     unless($do_not_analyze)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1214)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1215)       PrintUpdate("Analyzing $tmp_reads_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1216)       AnalyzeTable($tmp_reads_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1217)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1218)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1219) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1220)   if ($transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1221)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1222)     PrintUpdate("Swapping $final_reads_table tables");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1223)     SwapNew($tmp_reads_table, $final_reads_table, $previous_reads_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1224)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1225) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1226) # END start = reads
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1227) if ($stop eq "reads") {exit 0;}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1228) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1229) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1230) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1231) # SELECT data for vamps_projects_info
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1232) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1233) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1234) if ( ($start eq "projectdataset") || ($start eq "taxonomy") || ($start eq "sequences") || ($start eq "reads") || ($start eq "keys") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1235) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1236)   if ($export)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1237)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1238)     PrintUpdate("Dumping data for $final_project_desc_table into $projectDescFile");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1239)     # q 8)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1240)     # todo: If project_name standard changed - add OR clause!!!
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1241)     my $selectProjects =
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1242)     "SELECT distinctrow 0, project, title, project_description as description, contact, email, institution, env_sample_source_id as env_source_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1243)       FROM $source_project_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1244)       JOIN contact USING(contact_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1245)       WHERE project LIKE '%v%' OR project LIKE '%Bfl%' OR project like '%_ITS';
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1246)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1247)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1248)     print "q 8) selectProjects = $selectProjects\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1249)     print LOG "q 8) selectProjects = $selectProjects\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1250)     ExecuteDump($selectProjects, $projectDescFile);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1251)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1252) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1253)   if ($import)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1254)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1255)     PrintUpdate("Inserting into $vampsHost.$tmp_project_desc_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1256)     CreateEmpty($tmp_project_desc_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1257)     ExecuteLoad($projectDescFile, $tmp_project_desc_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1258) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1259)     unless($do_not_analyze)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1260)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1261)       PrintUpdate("Analyzing $tmp_project_desc_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1262)       AnalyzeTable($tmp_project_desc_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1263)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1264)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1265) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1266)   if ($transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1267)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1268)     PrintUpdate("Swapping $final_project_desc_table tables");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1269)     SwapNew($tmp_project_desc_table, $final_project_desc_table, $previous_project_desc_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1270)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1271) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1272) # END start = keys
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1273) if ($stop eq "keys") {exit 0;}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1274) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1275) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1276) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1277) # Update new tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1278) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1279) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1280) if ( ($start eq "norm_tables") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1281) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1282)   print "HHH1: start norm tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1283) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1284)   # create _transfer copies
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1285)   print "AAA1: create_norm_transfer_tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1286)   &create_norm_transfer_tables();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1287)   &create_norm_tables_ill();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1288)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1289)   print "truncate_norm_transfer_tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1290)   &truncate_norm_transfer();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1291)   # store_previous_count for new tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1292)   print "AAA2: new_tables_count_all\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1293)   %previous_res_count = new_tables_count_all();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1294) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1295)   my $update_new_superkingdom = "INSERT IGNORE INTO $superkingdom_table" . $tblSuffix . " (superkingdom) SELECT DISTINCT superkingdom FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1296)   my $update_new_phylum       = "INSERT IGNORE INTO $phylum_table" . $tblSuffix . " (phylum) SELECT DISTINCT phylum FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1297)   my $update_new_class        = "INSERT IGNORE INTO $class_table" . $tblSuffix . " (class) SELECT DISTINCT class FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1298)   my $update_new_orderx       = "INSERT IGNORE INTO $orderx_table" . $tblSuffix . " (orderx) SELECT DISTINCT orderx FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1299)   my $update_new_family       = "INSERT IGNORE INTO $family_table" . $tblSuffix . " (family) SELECT DISTINCT family FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1300)   my $update_new_genus        = "INSERT IGNORE INTO $genus_table" . $tblSuffix . " (genus) SELECT DISTINCT genus FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1301)   my $update_new_species      = "INSERT IGNORE INTO $species_table" . $tblSuffix . " (species) SELECT DISTINCT species FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1302)   my $update_new_strain       = "INSERT IGNORE INTO $strain_table" . $tblSuffix . " (strain) SELECT DISTINCT strain FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1303)   # update manually???
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1304)   # my $update_new_rank         = "INSERT IGNORE INTO $rank_table (rank) SELECT distinct rank FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1305) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1306)   my $update_new_taxon_string =
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1307)     "INSERT IGNORE INTO $taxon_string_table" . $tblSuffix . " (taxon_string, rank_number)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1308)       SELECT distinct taxon_string, rank_number
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1309)       FROM $tmp_summed_taxes_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1310)       JOIN $rank_number_table on ($tmp_summed_taxes_table.rank = $rank_number_table.rank_number)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1311)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1312) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1313)   my $update_new_user = "INSERT IGNORE INTO $user_table" . $tblSuffix . " (user, passwd, active, security_level)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1314)           SELECT distinct user, passwd, active, security_level
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1315)           FROM $vamps_auth_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1316) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1317)   my $update_new_contact1 = "INSERT IGNORE INTO $contact_table" . $tblSuffix . " (first_name, last_name, email, institution, contact)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1318)     SELECT distinct first_name, last_name, email, institution, concat(first_name, ' ', last_name)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1319)     FROM $vamps_auth_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1320) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1321)   my $update_new_contact2 = "INSERT IGNORE INTO $contact_table" . $tblSuffix . " (email, institution, contact)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1322)     SELECT distinct email, institution, contact FROM $tmp_project_desc_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1323) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1324)   # update new_taxonomy
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1325)   my $update_new_taxonomy = "INSERT IGNORE INTO $taxonomy_table" . $illSuffix . " (taxon_string_id, superkingdom_id, phylum_id, class_id, orderx_id, family_id, genus_id, species_id, strain_id, rank_id, classifier,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1326)                                                                                    taxon_string,    superkingdom,    phylum,    class,    orderx,    family,    genus,    species,    strain,    rank
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1327)     )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1328)     SELECT distinct taxon_string_id, superkingdom_id, phylum_id, class_id, orderx_id, family_id, genus_id, species_id, strain_id, $rank_table.rank_id, classifier,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1329)                     taxon_string,    superkingdom, phylum, class, orderx, family, genus, species, strain, rank
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1330)     FROM $tmp_taxes_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1331)     JOIN $taxon_string_table" . $tblSuffix . " using(taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1332)     JOIN $superkingdom_table" . $tblSuffix . " using(superkingdom)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1333)     JOIN $phylum_table" . $tblSuffix . " using(phylum)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1334)     JOIN $class_table" . $tblSuffix . " using(class)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1335)     JOIN $orderx_table" . $tblSuffix . " using(orderx)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1336)     JOIN $family_table" . $tblSuffix . " using(family)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1337)     JOIN $genus_table" . $tblSuffix . " using(genus)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1338)     JOIN $species_table" . $tblSuffix . " using(species)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1339)     JOIN $strain_table" . $tblSuffix . " using(strain)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1340)     JOIN $rank_table using(rank)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1341)   ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1342) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1343)   my $update_new_summed_data_cube =
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1344)     "INSERT IGNORE INTO $summed_data_cube_table" . $illSuffix . "
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1345)     (taxon_string_id, knt, frequency, dataset_count, rank_number, project_id, dataset_id, project_dataset_id, classifier, taxon_string, project, dataset, project_dataset)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1346)     SELECT distinct
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1347)     taxon_string_id, knt, frequency, dataset_count, $rank_number_table.rank_number, project_id, dataset_id, project_dataset_id, classifier, taxon_string, project, dataset, project_dataset
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1348)     FROM $tmp_summed_taxes_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1349)       JOIN $taxon_string_table" . $tblSuffix . " USING(taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1350)       JOIN $rank_number_table on $tmp_summed_taxes_table.rank = $rank_number_table.rank_number
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1351)       JOIN $project_dataset_table" . $illSuffix . " USING(project_dataset, project, dataset)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1352)       # !!!$project_dataset_table" . $illSuffix
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1353) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1354)   my $update_new_user_contact = "INSERT IGNORE INTO $user_contact_table" . $illSuffix . " (contact_id, user_id, contact, user)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1355)     SELECT distinct contact_id, user_id, contact, user
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1356)     FROM $vamps_auth_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1357)       JOIN $contact_table" . $tblSuffix . " USING(first_name, last_name, email, institution)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1358)       JOIN $user_table" . $tblSuffix . " USING(USER, passwd, active, security_level)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1359)       WHERE contact_id IS NOT null";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1360) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1361)   my $update_new_project1 = "INSERT IGNORE INTO $project_table" . $tblSuffix . " (project, title, project_description, env_sample_source_id, contact_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1362)     SELECT distinct project_name, title, description, env_source_id, contact_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1363)     FROM $tmp_project_desc_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1364)     JOIN $contact_table" . $tblSuffix . " USING(contact, email, institution)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1365) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1366)   my $update_new_project2 = "UPDATE $project_table SET env_sample_source_id = 0 WHERE env_sample_source_id IS NULL";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1367) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1368)   # my $update_new_dataset = "INSERT IGNORE INTO $dataset_table" . $tblSuffix . " (dataset, dataset_description, reads_in_dataset, has_sequence, project_id, date_trimmed)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1369)   #   SELECT distinct dataset, dataset_info, dataset_count, has_sequence, project_id, date_trimmed
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1370)   #   FROM $tmp_project_dataset_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1371)   #   JOIN $project_table" . $tblSuffix . " using(project)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1372)   # my $update_new_dataset = "INSERT IGNORE INTO $dataset_table" . $tblSuffix . " (dataset, dataset_description, reads_in_dataset, has_sequence, project_id, date_trimmed, project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1373)   #   SELECT distinct dataset, dataset_info, dataset_count, has_sequence, project_id, date_trimmed, project
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1374)   #   FROM $tmp_project_dataset_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1375)   #   JOIN $project_table" . $tblSuffix . " using(project)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1376)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1377)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1378)   my $update_new_dataset = "INSERT IGNORE INTO $dataset_table" . $illSuffix . " (dataset, dataset_description, reads_in_dataset, has_sequence, project_id, date_trimmed, project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1379)     SELECT distinct dataset, dataset_info, dataset_count, has_sequence, project_id, date_trimmed, project
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1380)     FROM $tmp_project_dataset_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1381)     JOIN $project_table" . $tblSuffix . " using(project)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1382) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1383)   my $update_new_project_dataset = "INSERT IGNORE INTO $project_dataset_table" . $illSuffix . " (project_dataset, dataset_id, project_id, dataset, project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1384)     SELECT distinct $tmp_summed_taxes_table.project_dataset, dataset_id, pr.project_id, dataset, project
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1385)     FROM $tmp_summed_taxes_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1386)     LEFT JOIN $project_table" . $tblSuffix . " as pr using(project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1387)     LEFT JOIN $dataset_table" . $illSuffix . " using(dataset, project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1388)   ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1389)   # $dataset_table" . $illSuffix
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1390) # too slow!!!
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1391)   # my $update_new_read_id1 = "insert ignore into $read_id_table" . $tblSuffix . " (read_id, project_dataset_id, sequence_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1392)   #   SELECT rep_id, project_dataset_id, sequence_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1393)   #   FROM $tmp_seqs_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1394)   #   left join $project_table using(project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1395)   #   left join $dataset_table using(dataset, project_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1396)   #   left join $project_dataset_table using(project_id, dataset_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1397)   #   left join $sequence_table using(sequence)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1398) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1399)   my $update_new_read_id1 = "insert ignore into $read_id_table" . $tblSuffix . " (read_id, project_dataset_id, sequence_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1400)     SELECT distinct rep_id, project_dataset_id, sequence_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1401)     FROM $tmp_seqs_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1402)     left join $project_dataset_table using(project_dataset)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1403)     left join $sequence_table using(sequence)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1404) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1405)   my $update_new_read_id2 = "insert ignore into $read_id_table" . $tblSuffix . " (read_id, project_dataset_id, sequence_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1406)      SELECT distinct read_id, project_dataset_id, sequence_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1407)      FROM $tmp_reads_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1408)      left join $project_table using(project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1409)      left join $dataset_table using(dataset, project_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1410)      left join $project_dataset_table using(project_id, dataset_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1411)      left join $sequence_table using(sequence)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1412) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1413)   my $update_new_sequence1 = "INSERT IGNORE INTO $sequence_table" . $tblSuffix . " (sequence) SELECT DISTINCT sequence FROM $tmp_seqs_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1414) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1415)   my $update_new_sequence2 = "INSERT IGNORE INTO $sequence_table" . $tblSuffix . " (sequence)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1416)     SELECT distinct sequence FROM $tmp_reads_table WHERE read_id IN
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1417)       ($missed_read_ids_list)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1418)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1419)   # ================
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1420)   # Part I
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1421)   @table_names_update = ($superkingdom_table, $phylum_table, $class_table, $orderx_table, $family_table, $genus_table, $species_table, $strain_table, $taxon_string_table, $user_table, $contact_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1422)   @query_names_exec   = ($update_new_superkingdom, $update_new_phylum, $update_new_class, $update_new_orderx, $update_new_family,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1423)                                $update_new_genus, $update_new_species, $update_new_strain, $update_new_taxon_string, $update_new_user, $update_new_contact1, $update_new_contact2);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1424)   print "AAA3: run_count_and_update\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1425) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1426)   &run_count_and_update(\@query_names_exec, \@table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1427)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1428)   # Part II
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1429)   @table_names_update = ($taxonomy_table, $project_table, $dataset_table, $project_dataset_table, $summed_data_cube_table, $user_contact_table);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1430)   @query_names_exec   = ($update_new_taxonomy, $update_new_project1, $update_new_dataset, $update_new_project_dataset, $update_new_summed_data_cube, $update_new_user_contact, $update_new_project2);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1431) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1432)   print "AAA4: run_count_and_update Part2\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1433)   &run_count_and_update(\@query_names_exec, \@table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1434) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1435)   # todo: add foreign keys if not exists only!
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1436)   print "AAA5: add_foreign_key\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1437)   &add_foreign_key();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1438) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1439)   print "URA555\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1440)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1441)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1442)   # # Part sequence
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1443)   # 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1444)   # my $missed_read_ids_list = &get_missed_read_ids();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1445)   # print "MMM1: missed_read_ids_list = $missed_read_ids_list\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1446)   # # 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1447)   # # my $update_new_sequence2 = "INSERT IGNORE INTO $sequence_table (sequence)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1448)   # #   SELECT sequence FROM $tmp_reads_table WHERE read_id IN
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1449)   # #     ($missed_read_ids_list)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1450)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1451) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1452) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1453) #TODO: change to if ($transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1454) # use for env454 upload
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1455) if ( ($start eq "rename_norm") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1456) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1457)   print "HHH2: start rename norm tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1458)   my $suffix_from = "";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1459)   my $suffix_to   = "";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1460)   # my $tblSuffix = "_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1461)   # my $tblSuffixOld = "_previous";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1462) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1463)   &drop_norm_previous();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1464)   # current -> _previous
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1465)   &rename_tables($suffix_from = "", $suffix_to = $tblSuffixOld);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1466) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1467)   # _transfer -> current
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1468)   &rename_tables($suffix_from = $tblSuffix, $suffix_to = "");  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1469) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1470) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1471) my $last_ids_file_name     = 'last_ids.txt';
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1472) my $new_last_ids_file_name = 'new_last_ids.txt';
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1473) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1474) # use for illumina upload
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1475) if ( ($start eq "add_illumina") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1476) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1477)   my %last_ids  = &get_last_id();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1478)   print "The last ids:\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1479)   while (my ($key, $value) = each %last_ids)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1480)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1481)     print "table name = $key:  max id = $value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1482)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1483)   &write_to_file($last_ids_file_name, \%last_ids);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1484)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1485)   print "HHH3: start to add illumina data to current tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1486)   # add illumina data to current tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1487)   &update_current_from_illumina_transfer();  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1488)   # real  6m46.072s  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1489)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1490)   %last_ids = &get_last_id();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1491)   print "The new last ids:\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1492)   while (my ($key, $value) = each %last_ids)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1493)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1494)     print "table name = $key:  max id = $value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1495)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1496)   &write_to_file($new_last_ids_file_name, \%last_ids);  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1497) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1498) 
57f46ef3 (annaship 2013-02-15 16:15:12 -0500 1499) # use from the previous run directory
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1500) if ( ($start eq "rollback_illumina") )
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1501) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1502)   # TODO: add data from the second file to say "limit"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1503)   my %last_ids_hash = &get_ids_from_file($last_ids_file_name);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1504)   my @del_by_ids_query_names_exec;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1505)   print "LLL: last_ids_hash\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1506)   while (my ($table_name, $value) = each %last_ids_hash)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1507)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1508)     my $id_name = "id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1509)     my $table_name_base = $table_name;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1510)     unless ($table_name =~ /^vamps/)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1511)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1512)       $table_name_base =~ s/new_//;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1513)       $id_name = $table_name_base."_id";                
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1514)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1515)     my $del_query = "DELETE from $table_name where $id_name > $value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1516)     # TODO:
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1517)     # my $del_query = "DELETE from $table_name where $id_name > $value limit $limit";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1518)     # or
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1519)     # SELECT id FROM mytable where $id_name > $value ORDER BY id ASC LIMIT n ;    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1520)     # my $del_query = "DELETE from $table_name where $id_name in (...)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1521)     # or
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1522)     # DELETE FROM table WHERE id NOT IN (SELECT id FROM table ORDER BY id, desc LIMIT 0, 10)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1523)     push (@del_by_ids_query_names_exec, $del_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1524)     # print "last_ids_hash: $del_query\n table name = $table_name:  max id = $value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1525)     print "last_ids_hash: $del_query\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1526)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1527)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1528)   &key_check_no();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1529)   &prep_exec_query_with_time(\@del_by_ids_query_names_exec);    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1530)   &key_check_yes();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1531) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1532) # real  5m11.008s
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1533) # 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1534) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1535) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1536) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1537) # Close the database connections
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1538) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1539) #######################################
dfa847ab (annaship 2014-11-07 11:49:58 -0500 1540) # $dbhSource->disconnect;
dfa847ab (annaship 2014-11-07 11:49:58 -0500 1541) # $dbhVamps->disconnect;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1542) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1543) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1544) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1545) # Done and Exit!
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1546) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1547) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1548) exit 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1549) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1550) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1551) #  ---------- Subroutines ------------
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1552) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1553) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1554) # Prepare, execute query and print out
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1555) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1556) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1557) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1558) sub prep_exec_query_print()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1559) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1560)   my $dbh = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1561)   my $sql = shift || die("Please provide an sql statement");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1562)   my $sql_prep = $dbh->prepare($sql) || die "Unable to prepare query: $sql\nError: " . $dbh->errstr . "\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1563)   # print "Executing: dbh = $dbh;\nsql = $sql;\nsql_prep = $sql_prep\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1564)   print "Executing: sql = $sql\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1565)   unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1566)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1567)     $sql_prep->execute() || die "Unable to execute MySQL statement: $sql\nError: " . $dbh->errstr . "(" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1568)     print "All right!\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1569)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1570) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1571) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1572) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1573) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1574) # Print out updates to screen and log file
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1575) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1576) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1577) sub PrintUpdate
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1578) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1579)   my $msg = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1580) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1581)   print "$msg\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1582)   print LOG "$msg (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1583) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1584) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1585) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1586) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1587) # Create and Truncate Subroutine
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1588) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1589) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1590) sub CreateEmpty
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1591) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1592)   my $tmpTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1593)   my $createQuery;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1594)   my $dropQuery =   "DROP TABLE IF EXISTS $tmpTable" ;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1595) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1596)   if($tmpTable eq 'vamps_projects_datasets_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1597)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1598)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1599)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1600)       `project` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1601)       `dataset` varchar(50) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1602)       `dataset_count` mediumint(8) unsigned NOT NULL COMMENT 'number of reads in the dataset',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1603)       `has_sequence` char(1) NOT NULL COMMENT 'whether the dataset has sequence information for taxonomic counts, fasta, or clusters',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1604)       `date_trimmed` varchar(10) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1605)       `dataset_info` varchar(100) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1606)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1607)       UNIQUE KEY project_dataset (`project`,`dataset`)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1608)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1; ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1609)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1610)   elsif($tmpTable eq 'vamps_export_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1611)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1612)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1613)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1614)       `read_id` varchar(32) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1615)       `project` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1616)       `dataset` varchar(50) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1617)       `refhvr_ids` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1618)       `distance` decimal(8,5) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1619)       `taxonomy` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1620)       `sequence` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1621)       `rank` varchar(20) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1622)       `date_trimmed` date NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1623)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1624)       unique KEY read_id (`read_id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1625)       key dataset (dataset),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1626)       key project_dataset (`project`,`dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1627)       KEY `taxonomy` (`taxonomy`)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1628)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1; ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1629)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1630)   elsif($tmpTable eq 'vamps_junk_data_cube_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1631)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1632)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1633)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1634)       `taxon_string` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1635)       `knt` bigint(20) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1636)       `frequency` double NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1637)       `dataset_count` mediumint(9) unsigned NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1638)       `rank` int(11) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1639)       `project` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1640)       `dataset` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1641)       `project_dataset` varchar(100) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1642)       `classifier` varchar(8) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1643)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1644)       KEY `rank` (`rank`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1645)       KEY `project_dataset` (`project`,`dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1646)       KEY `taxon_string` (`taxon_string`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1647)       UNIQUE KEY `project_dataset_conc_tax` (`project_dataset`, `taxon_string`)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1648)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1649)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1650)   elsif($tmpTable eq 'vamps_data_cube_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1651)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1652)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1653)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1654)       `project` varchar(100) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1655)       `dataset` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1656)       `taxon_string` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1657)       `superkingdom` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1658)       `phylum` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1659)       `class` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1660)       `orderx` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1661)       `family` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1662)       `genus` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1663)       `species` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1664)       `strain` varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1665)       `rank` varchar(16) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1666)       `knt` mediumint(20) unsigned NOT NULL default '0',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1667)       `frequency` double NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1668)       `dataset_count` mediumint(9) unsigned NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1669)       `classifier` varchar(8) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1670)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1671)       KEY taxon_string (taxon_string),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1672)       UNIQUE KEY project_dataset_taxon (project, dataset, taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1673)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1674)       # KEY project_dataset_taxon (`project`,`dataset`,`taxon_string`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1675)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1676)   elsif($tmpTable eq 'vamps_projects_info_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1677)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1678)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1679)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1680)       `project_name` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1681)       `title` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1682)       `description` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1683)       `contact` varchar(32) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1684)       `email` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1685)       `institution` varchar(128) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1686)       `env_source_id` int(8) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1687)       `edits` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1688)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1689)       UNIQUE KEY pr_cont_email_inst (project_name, contact, email, institution),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1690)       KEY cont_email_inst (contact, email, institution)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1691)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1692)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1693)   elsif($tmpTable eq 'vamps_sequences_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1694)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1695)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable like vamps_sequences";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1696) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1697)     # $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1698)     #   `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1699)     #   `sequence` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1700)     #   `project` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1701)     #   `dataset` varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1702)     #   `project_dataset` varchar(100) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1703)     #   `taxonomy` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1704)     #   `refhvr_ids` text NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1705)     #   `rank` varchar(20) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1706)     #   `seq_count` int(11) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1707)     #   `frequency` double NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1708)     #   `distance` decimal(7,5) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1709)     #   `rep_id` varchar(40) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1710)     #   PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1711)     #   KEY `project_dataset` (`project`,`dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1712)     #   KEY project (project),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1713)     #   KEY dataset (dataset),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1714)     #   KEY `sequence` (`sequence`(350)),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1715)     #   KEY `project_dataset_conc` (`project_dataset`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1716)     #   KEY `project_dataset_conc_seq` (`project_dataset`,sequence(350)),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1717)     #   KEY `project_dataset_conc_taxonomy` (`project_dataset`,`taxonomy`)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1718)     #   ) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1719)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1720) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1721)   elsif($tmpTable eq 'vamps_taxonomy_transfer')
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1722)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1723)     $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1724)       `id` int(11) NOT NULL AUTO_INCREMENT,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1725)       `taxon_string` varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1726)       `rank` int(11) NOT NULL default '0',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1727)       `num_kids` bigint(20) NOT NULL default 0,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1728)       PRIMARY KEY (`id`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1729)       KEY taxon_string_rank (`taxon_string`,`rank`),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1730)       UNIQUE KEY taxon_string (taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1731)       ) ENGINE=MyISAM DEFAULT CHARSET=latin1;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1732)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1733) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1734)   ExecuteInsert($dropQuery);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1735)   ExecuteInsert($createQuery);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1736)   my $truncateQuery = "TRUNCATE $tmpTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1737)   ExecuteInsert($truncateQuery);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1738) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1739)   # my $dropQuery_h = $dbhVamps->prepare($dropQuery) or warn print LOG "Unable to prepare statement: $dropQuery. Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1740)   # $dropQuery_h->execute or warn print LOG "Unable to execute SQL statement: $dropQuery.  Error: " . $dropQuery_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1741)   #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1742)   # #my $createQuery = "CREATE TABLE IF NOT EXISTS $tmpTable LIKE $finalTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1743)   # my $createQuery_h = $dbhVamps->prepare($createQuery) or warn print LOG "Unable to prepare statement: $createQuery. Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1744)   # $createQuery_h->execute or warn print LOG "Unable to execute SQL statement: $createQuery.  Error: " . $createQuery_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1745)   #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1746)   # my $truncateQuery = "TRUNCATE $tmpTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1747)   # my $truncateQuery_h = $dbhVamps->prepare($truncateQuery) or warn print LOG "Unable to prepare statement: $truncateQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1748)   # $truncateQuery_h->execute or warn print LOG "Unable to execute SQL statement: $truncateQuery.  Error: " . $truncateQuery_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1749) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1750)  # unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1751) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1752) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1753) # Prepare and Execute SELECT Statements
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1754) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1755) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1756) sub ExecuteSelect
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1757) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1758)   my $selectSQL = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1759) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1760)   # print "$selectSQL\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1761)   my $selectSQL_h = $dbhSource->prepare($selectSQL) or warn print LOG "Unable to prepare statement: $selectSQL. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1762)   $selectSQL_h->execute or warn print LOG "Unable to execute SQL statement: $selectSQL.  Error: " . $selectSQL_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1763) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1764)   return $selectSQL_h;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1765) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1766) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1767) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1768) #
7749e019 (annaship 2014-04-19 13:35:46 -0400 1769) # Prepare and Execute SELECT Statements even on test
7749e019 (annaship 2014-04-19 13:35:46 -0400 1770) #
7749e019 (annaship 2014-04-19 13:35:46 -0400 1771) #######################################
7749e019 (annaship 2014-04-19 13:35:46 -0400 1772) sub ExecuteSelectTest
7749e019 (annaship 2014-04-19 13:35:46 -0400 1773) {
7749e019 (annaship 2014-04-19 13:35:46 -0400 1774)   my $selectSQL = shift;
7749e019 (annaship 2014-04-19 13:35:46 -0400 1775) 
7af2a341 (annaship 2014-11-05 11:11:01 -0500 1776)   print "$selectSQL\n" if ($test_only == 1);
7749e019 (annaship 2014-04-19 13:35:46 -0400 1777)   my $selectSQL_h = $dbhSource->prepare($selectSQL) or warn print LOG "Unable to prepare statement: $selectSQL. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
7749e019 (annaship 2014-04-19 13:35:46 -0400 1778)   $selectSQL_h->execute or warn print LOG "Unable to execute SQL statement: $selectSQL.  Error: " . $selectSQL_h->errstr . " (" . (localtime) . ")\n";
7749e019 (annaship 2014-04-19 13:35:46 -0400 1779) 
7749e019 (annaship 2014-04-19 13:35:46 -0400 1780)   return $selectSQL_h;
7749e019 (annaship 2014-04-19 13:35:46 -0400 1781) }
7749e019 (annaship 2014-04-19 13:35:46 -0400 1782) 
7749e019 (annaship 2014-04-19 13:35:46 -0400 1783) 
7749e019 (annaship 2014-04-19 13:35:46 -0400 1784) #######################################
7749e019 (annaship 2014-04-19 13:35:46 -0400 1785) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1786) # on Vamps
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1787) # Prepare and Execute INSERT, DELETE, ALTER, TRUNCATE or CREATE Statements ("prepare" and "execute" only, no return)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1788) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1789) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1790) sub ExecuteInsert
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1791) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1792)   my $insertSQL = shift;
d927c5fa (annaship 2014-11-05 11:46:22 -0500 1793)   # print "EEE11: I'm in ExecuteInsert\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1794)   # print "$insertSQL\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1795)    # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1796)   my $insertSQL_h = $dbhVamps->prepare($insertSQL) or warn print LOG "Unable to prepare statement: $insertSQL. Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1797)   $insertSQL_h->execute or warn print LOG "Unable to execute SQL statement: $insertSQL.  Error: " . $insertSQL_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1798) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1799) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1800) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1801) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1802) # On bpcdb1
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1803) # Prepare and Execute INSERT, DELETE, ALTER, TRUNCATE or CREATE Statements ("prepare" and "execute" only, no return)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1804) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1805) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1806) sub ExecuteInsert_bpcdb1
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1807) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1808)   my $insertSQL = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1809)   print "EEE12: I'm in ExecuteInsert_bpcdb1\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1810)   # print "$insertSQL\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1811)   # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1812)   my $insertSQL_h = $dbhSource->prepare($insertSQL) or warn print LOG "Unable to prepare statement: $insertSQL. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1813)   $insertSQL_h->execute or warn print LOG "Unable to execute SQL statement: $insertSQL.  Error: " . $insertSQL_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1814) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1815) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1816) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1817) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1818) # On bpcdb1
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1819) # Execute _only_ INSERT, DELETE, ALTER, TRUNCATE or CREATE Statements ("execute" only, no prepare, no return)
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1820) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1821) #######################################
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1822) sub ExecuteInsert_bpcdb1_no_prepare
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1823) {
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1824)   my $insertSQL = shift;
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1825)   print "EEE13: I'm in ExecuteInsert_bpcdb1_no_prepare\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1826)   # print "$insertSQL\n";
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1827)   # if ($test_only == 1);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1828)   $insertSQL_h->execute or warn print LOG "Unable to execute SQL statement: $insertSQL.  Error: " . $insertSQL_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1829) }
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1830) 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1831) 
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1832) #######################################
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1833) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1834) # Turn on and off indexing
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1835) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1836) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1837) sub ToggleKeys
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1838) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1839)   my $table = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1840)   my $toggle = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1841) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1842)   unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1843)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1844)     $dbhVamps->do("ALTER TABLE $table $toggle KEYS");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1845)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1846) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1847) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1848) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1849) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1850) # Prepare and Execute INSERT Statements (with query value)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1851) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1852) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1853) sub ExecuteInsertPassVar
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1854) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1855)   my $insertSQL = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1856)   my $query_val = shift;  #passing a query value
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1857) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1858)   # print "HHH1: inside ExecuteInsertPassVar: query_val = $query_val\ninsertSQL = $insertSQL\n\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1859) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1860)   my $insertSQL_h = $dbhVamps->prepare($insertSQL) or warn print LOG "Unable to prepare statement: $insertSQL. Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1861)   $insertSQL_h->execute($query_val) or warn print LOG "Unable to execute SQL statement: $insertSQL.  Error: " . $insertSQL_h->errstr . " (" . (localtime) . ")\n" unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1862) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1863) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1864) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1865) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1866) # Export selected to file
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1867) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1868) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1869) sub ExecuteDump
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1870) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1871)   my $selectSQL = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1872)   my $transferFilename = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1873)   my $sqlCmd = "mysql --compress -h $sourceHost -D $sourceDB -e \"$selectSQL\" > $transferFilename" ;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1874)   unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1875)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1876)     my $sqlErr = system($sqlCmd);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1877)     if ($sqlErr) {warn print LOG "Unable to execute MySQL statement: $sqlCmd.  Error:  $sqlErr. (" . (localtime) . ")\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1878)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1879) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1880) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1881) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1882) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1883) # Import transfer file
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1884) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1885) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1886) sub ExecuteLoad
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1887) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1888)   my $transferFilename = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1889)   my $transferTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1890)   my $sqlCmd = "$sqlImportCommand -C -v --ignore-lines=1 -L -h $vampsHost -P 3306 $vampsDB $transferFilename; ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1891)   # my $sqlCmd = "mysql -h $vampsHost $vampsDB --show-warnings -e 'LOAD DATA LOCAL INFILE $transferFilename IGNORE INTO TABLE $transferTable'"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1892)   print "Here01: \$sqlCmd = $sqlCmd\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1893) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1894)   # until we have Myisam and locked tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1895)   # my $sqlCmd = "$sqlImportCommand -C -v --ignore-lines=1 -L -h $vampsHost -P 3306 $vampsDB $transferFilename & ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1896)   unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1897)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1898)     my $sqlErr = system($sqlCmd);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1899)     if ($sqlErr) {warn print LOG "Unable to execute MySQL statement: $sqlCmd.  Error:  $sqlErr (" . (localtime) . ")\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1900)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1901) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1902) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1903) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1904) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1905) # Swap in new tables Subroutine
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1906) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1907) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1908) sub SwapNew
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1909) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1910)   my $tmpTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1911)   my $finalTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1912)   my $previousTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1913) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1914)   my $dropQuery = "DROP TABLE IF EXISTS $previousTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1915)   my $dropQuery_h = $dbhVamps->prepare($dropQuery) or warn print LOG "Unable to prepare statement $dropQuery.  Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1916) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1917)   my $renameOldQuery = "RENAME TABLE $finalTable TO $previousTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1918)   my $renameOldQuery_h = $dbhVamps->prepare($renameOldQuery) or warn print LOG "Unable to prepare statement $renameOldQuery.  Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1919) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1920)   my $renameNewQuery = "RENAME TABLE $tmpTable TO $finalTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1921)   my $renameNewQuery_h = $dbhVamps->prepare($renameNewQuery) or warn print LOG "Unable to prepare statement $renameNewQuery. Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1922) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1923)   unless ($test_only == 1)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1924)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1925)     $dropQuery_h->execute() or warn print LOG "Unable to execute statement: $dropQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1926)     #print "$renameOldQuery\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1927)     $renameOldQuery_h->execute() or warn print LOG "Unable to execute statement: $renameOldQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1928)     #print "$renameNewQuery\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1929)     $renameNewQuery_h->execute() or warn print LOG "Unable to execute statement: $renameNewQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1930)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1931) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1932) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1933) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1934) # Analyze temp tables Subroutine
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1935) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1936) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1937) sub AnalyzeTable
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1938) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1939)   my $tmpTable = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1940)   my $analyzeQuery = "ANALYZE TABLE $tmpTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1941)   my $analyzeQuery_h = $dbhVamps->prepare($analyzeQuery) or warn print LOG "Unable to prepare statement $analyzeQuery.  Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1942)   $analyzeQuery_h->execute() or warn print LOG "Unable to execute statement: $analyzeQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n"  unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1943)   my $optimizeQuery = "OPTIMIZE TABLE $tmpTable";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1944)   my $optimizeQuery_h = $dbhVamps->prepare($optimizeQuery) or warn print LOG "Unable to prepare statement $optimizeQuery.  Err: " . $dbhVamps->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1945)   $optimizeQuery_h->execute() or warn print LOG "Unable to execute statement: $optimizeQuery.  Error: " . $dbhVamps->errstr . " (" . (localtime) . ")\n"  unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1946) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1947) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1948) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1949) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1950) #
9e1cba2b (annaship 2014-11-19 18:13:18 -0500 1951) # Printing query to screen and LOG
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1952) # Call with a query_name and query
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1953) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1954) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1955) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1956) sub print_query_out
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1957) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1958)   my $query_name   = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1959)   my $message_part = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1960)   my $message      = "\$query_name = $query_name; $message_part\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1961)   print $message;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1962)   print LOG $message;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1963) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1964) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1965) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1966) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1967) # new_tables_count for new tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1968) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1969) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1970) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1971) sub new_tables_count_all
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1972) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1973)   my %res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1974)   while (my ($key, $value) = each %norm_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1975)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1976)     print "key = $key:  value = $value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1977)      # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1978)     my $id = $key."_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1979)     my $table_name = "$value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1980)     my $table_name_query = "SELECT count($id) FROM $table_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1981)     print "table_name_query = $table_name_query\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1982)     # my $temp_h = $dbhSource->prepare($table_name_query) or warn print LOG "Unable to prepare statement: $table_name_query. Error: " . $dbhSource->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1983)     # $temp_h->execute or warn print LOG "Unable to execute SQL statement: $table_name_query.  Error: " . $temp_h->errstr . " (" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1984)     #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1985)     # if ($table_name eq "new_user_contact")
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1986)     # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1987)     #   $res_count{$user_contact_table} = &prep_exec_fetch_query($dbhVamps, "SELECT count(*) FROM $user_contact_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1988)     #   print "$user_contact_table: ".$res_count{$user_contact_table}."\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1989)     # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1990)     # else
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1991)     # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1992)       $res_count{$table_name} = &prep_exec_fetch_query($dbhVamps, $table_name_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1993)       # print "HEREEE\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1994)       print "table_name = $table_name; res_count = $res_count{$table_name}\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1995)     # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1996) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1997)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1998)   return %res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 1999) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2000) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2001) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2002) sub new_tables_count
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2003) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2004)   my $table_names = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2005)   my %res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2006) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2007)   while (my ($key, $value) = each %norm_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2008)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2009)       if (in_array(\@$table_names, $value))
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2010)       {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2011)         print "key = $key:  value = $value\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2012)         my $id = $key."_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2013)         my $table_name = "$value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2014)         $res_count{$table_name} = &prep_exec_fetch_query($dbhVamps, "SELECT count($id) FROM $table_name" . $tblSuffix);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2015)          # unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2016)         print "$res_count{$table_name}\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2017)       }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2018)     # else
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2019)     # # count all (not transfer)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2020)     # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2021)     #   print "key = $key:  value = $value\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2022)     #   my $id = $key."_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2023)     #   my $table_name = "$value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2024)     #   $res_count{$table_name} = &prep_exec_fetch_query($dbhVamps, "SELECT count($id) FROM $table_name");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2025)     #    # unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2026)     #    print "HEREEE\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2027)     #   print "table_name = $table_name; res_count = $res_count{$table_name}\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2028)     # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2029)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2030) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2031)   # todo: 1) refactor to DRY!
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2032)   # 2) move what's below to the loop
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2033)   # $res_count{$user_contact_table} = &prep_exec_fetch_query($dbhVamps, "SELECT count(*) FROM $user_contact_table");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2034)   # print "$user_contact_table: ".$res_count{$user_contact_table}."\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2035) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2036)   return %res_count;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2037) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2038) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2039) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2040) # create norm transfer tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2041) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2042) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2043) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2044) sub create_norm_transfer_tables()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2045) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2046)   while (my ($key, $value) = each %norm_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2047)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2048)     print "key = $key:  value = $value\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2049)     my $transfer_name = $value."_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2050)     print "transfer_name = $transfer_name\n"  if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2051)     my $copy_query1 = "CREATE TABLE if not exists $transfer_name LIKE $value;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2052)     print "copy_query1 = $copy_query1\n==========\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2053)     &prep_exec_query($dbhVamps, $copy_query1) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2054)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2055) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2056) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2057) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2058) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2059) # copy existing new_tables to transfer by table name
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2060) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2061) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2062) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2063) sub copy_norm_table_to_transfer()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2064) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2065)   my @table_names = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2066) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2067)   foreach my $table_name (@table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2068)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2069)     print "table_name = $table_name\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2070)     my $transfer_name = $table_name."_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2071)     print "transfer_name = $transfer_name\n" if ($test_only == 1);
dfa847ab (annaship 2014-11-07 11:49:58 -0500 2072)     my $copy_query2 = "INSERT INTO $transfer_name SELECT DISTINCT * FROM $table_name;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2073)     print "copy_query2 = $copy_query2\n==========\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2074)     &prep_exec_query($dbhVamps, $copy_query2) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2075)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2076) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2077) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2078) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2079)   # /* 9:37:09 AM  vampsdb */ CREATE TABLE `new_superkingdom_copy` (   `superkingdom_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,   `superkingdom` char(10) NOT NULL DEFAULT '',   PRIMARY KEY (`superkingdom_id`),   UNIQUE KEY `superkingdom` (`superkingdom`) ) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
dfa847ab (annaship 2014-11-07 11:49:58 -0500 2080)   # /* 9:37:10 AM  vampsdb */ INSERT INTO `new_superkingdom_copy` SELECT * FROM `new_superkingdom`;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2081) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2082) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2083) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2084) # execute query, print out time. Provide an array of query names
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2085) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2086) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2087) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2088) sub prep_exec_query_with_time()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2089) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2090)   my $query_names   = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2091)   # foreach my $query_name (@$query_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2092)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2093)   #   print "OOO2: in prep_exec_query_with_time; query_name = $query_name\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2094)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2095) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2096)   foreach my $query_name (@$query_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2097)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2098)     $query_to_norm_number++;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2099)     print "=======================\nQuery #$query_to_norm_number\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2100)     my $start_time = $time{'hhmmss', time()};
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2101)     print "Query started at $start_time (hhmmss)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2102)     &prep_exec_query_print($dbhVamps, $query_name);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2103)     my $warning_str = $dbhVamps->{mysql_info};
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2104)     print "$warning_str\n" if ($warning_str);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2105) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2106)     my $end_time = $time{'hhmmss', time()};
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2107)     my $diff = $end_time - $start_time;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2108)     print "Query ended at $end_time (hhmmss)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2109)     print "Run time for the query: $diff sec\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2110)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2111) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2112) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2113) sub compare_amount()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2114) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2115)   # while (my ($key_new, $value_new) = each %new_res_count)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2116)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2117)   #   print "NNN1: new_res_count: key_new = $key_new; value_new = $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2118)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2119)   # while (my ($key_new, $value_new) = each %previous_res_count)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2120)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2121)   #   print "NNN2: previous_res_count: key_new = $key_new; value_new = $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2122)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2123) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2124)   print "III2: in compare_amount\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2125)   while (my ($key_previous, $value_previous) = each %previous_res_count)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2126)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2127)     # print "KKK01: \$key_previous: = $key_previous; \$value_previous =: $value_previous\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2128)     print "KKK1: key_previous = $key_previous; \$value_previous = $value_previous\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2129)     while (my ($key_new, $value_new) = each %new_res_count)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2130)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2131)       # print "KKK2: \$key_new: = $key_new; \$value_new = $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2132)        # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2133)       if ($key_new eq $key_previous)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2134)       {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2135)         if ($value_new >= $value_previous)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2136)         {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2137)           
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2138)           print "The numbers are good!\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2139)           print "Table name: $key_new".$tblSuffix."; value = $value_new;\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2140)           # $key_new: \$value_previous == \$value_new: $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2141)           print "PPP1: \$key_previous = $key_previous; \$value_previous = $value_previous\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2142)           print "KKK3: \$key_new      = $key_new;      \$value_new      = $value_new\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2143)            # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2144)           
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2145)           # &rename_from_transfer($key_previous, $key_new);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2146)         }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2147)         else
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2148)         {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2149)           print "\$value_previous is less then \$value_new:\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2150)           print "Previous: $key_previous is $value_previous\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2151)           print "New: $key_new".$tblSuffix." is $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2152)           print "Take care of the tables and rerun vamps_upload -norm!\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2153)           # todo: uncommented on production
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2154)           # if ($key_previous ne "new_contact")
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2155)           # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2156)           #   exit;            
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2157)           # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2158)         }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2159) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2160)       }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2161)       # $key_new not eq $key_previous
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2162)       # else {next;} 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2163)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2164)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2165) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2166) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2167) sub in_array {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2168)     my ($arr, $search_for) = @_;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2169)     foreach my $value (@$arr)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2170)     {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2171)         return 1 if $value eq $search_for;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2172)     }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2173)     return 0;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2174) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2175) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2176) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2177) sub rename_from_transfer()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2178) {  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2179)   my $key_previous = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2180)   my $key_new      = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2181)  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2182)   print "HHHHEEERE\nkey_previous = $key_previous; key_new = $key_new\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2183) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2184)   # my $delete_previous = "DROP TABLE IF EXISTS $key_previous"."_previous";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2185)   my $rename1 = "RENAME TABLE $key_previous TO $key_previous"."_previous";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2186)   my $rename2 = "RENAME TABLE $key_new      TO $key_previous";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2187) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2188)   # print "\$delete_previous = $delete_previous\n";# if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2189)   # &prep_exec_query($dbhVamps, $delete_previous) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2190)   print "\$rename1 = $rename1\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2191)   &prep_exec_query($dbhVamps, $rename1) unless ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2192)   print "\$rename2 = $rename2\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2193)   &prep_exec_query($dbhVamps, $rename2) unless ($test_only == 1);  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2194) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2195) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2196) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2197) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2198) # run everethyng for given tables
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2199) #
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2200) #######################################
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2201) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2202) sub run_count_and_update()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2203) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2204)   my $query_names_exec   = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2205)   my $table_names_update = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2206)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2207)   # print "AAA12: copy_norm_table_to_transfer table_names_update\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2208)   # &copy_norm_table_to_transfer(@table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2209) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2210)   # print "AAA13: prep_exec_query_with_time(query_names_exec)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2211)   # my @transfer_table_names = &rename_names_to_transfer($table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2212)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2213)   # foreach my $transfer_table_name (@transfer_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2214)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2215)   #   print "NNN1: transfer_table_name = $transfer_table_name\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2216)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2217)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2218)   # prepare and execute
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2219)   print "AAA10: prep_exec_query_with_time\n";  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2220)   &prep_exec_query_with_time($query_names_exec);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2221)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2222)   # print "AAA14: new_res_count = new_tables_count(table_names_update)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2223)   # %new_res_count = new_tables_count(\@transfer_table_names);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2224)   print "AAA11: new_tables_count\n";  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2225)   %new_res_count = new_tables_count($table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2226)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2227)   # ----------
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2228)   while (my ($key_new, $value_new) = each %new_res_count)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2229)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2230)     print "NNN1: $key_new".$tblSuffix.": $value_new\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2231)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2232)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2233)   # ----------
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2234)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2235)   # compare size with old and exit <
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2236)   print "AAA12: compare_amount\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2237)   &compare_amount();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2238)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2239)   # &update_table_w_file();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2240)   # &copy_norm_table_to_transfer(@table_names_update);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2241) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2242) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2243) sub rename_names_to_transfer()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2244) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2245)   my $table_names = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2246)   my @transfer_table_names;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2247)   foreach my $table_name (@$table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2248)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2249)     $table_name = $table_name . $tblSuffix;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2250)     push (@transfer_table_names, $table_name);    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2251)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2252)   return @transfer_table_names;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2253) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2254) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2255) sub get_missed_read_ids()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2256) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2257)   my $start_time = $time{'hhmmss', time()};
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2258)   print "Query started at $start_time (hhmmss)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2259)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2260)   my $get_missed_read_ids = "SELECT DISTINCT read_id FROM $read_id_table
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2261)     LEFT JOIN $sequence_table using(sequence_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2262)     WHERE $sequence_table.sequence_id IS NULL";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2263)   print "GGG1: get_missed_read_ids = $get_missed_read_ids\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2264)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2265)   my @missed_read_ids      = &prep_exec_fetchrow_array_query($dbhVamps, $get_missed_read_ids);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2266)   my $missed_read_ids_list = join(',', @missed_read_ids);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2267)   print "MMM: $missed_read_ids_list\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2268)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2269)   my $end_time = $time{'hhmmss', time()};
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2270)   my $diff     = $end_time - $start_time;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2271)   print "Query ended at $end_time (hhmmss)\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2272)   print "Run time for the query: $diff sec\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2273)   return $missed_read_ids_list;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2274) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2275) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2276) sub prep_exec_fetchrow_array_query()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2277) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2278)   my @result;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2279)   print "III222: in prep_exec_fetchrow_array_query\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2280)   my $dbh = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2281)   my $sql = shift || die("Please provide an sql statement");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2282)   my $sql_prep = $dbh->prepare_cached($sql) || die "Unable to prepare MySQL statement: $sql\n. Error: " . $dbh->errstr . "\n";    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2283)   $sql_prep->execute() || die "Unable to execute MySQL statement: $sql. Error: " . $dbh->errstr . "\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2284)   # my (@result) = $sql_prep->fetchrow_array();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2285)   while (my @data = $sql_prep->fetchrow_array()) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2286)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2287)     push @result, @data;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2288)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2289)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2290)   return @result;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2291) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2292) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2293) sub update_table_w_file()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2294) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2295)   my $tmp_path = "/usr/local/tmp/";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2296) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2297)   # changed to match mysqlimport requirements, mysql LOAD DATA LOCAL INFILE throws inconsistent errors
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2298)   my ( $temp_aux_fh, $temp_aux_filename )   = tempfile( SUFFIX => '.temp_aux', DIR => $tmp_path );
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2299)   print "FFF1: temp_aux_fh = $temp_aux_fh; temp_aux_filename = $temp_aux_filename\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2300)  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2301)  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2302)   # if ($temp_aux_filename !~ /$outtemp_auxTable/)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2303)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2304)   #     $new_prefix = $tmpDir . $outtemp_auxTable . ".";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2305)   #     $temp_aux_filename =~ s/$tmpDir/$new_prefix/;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2306)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2307)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2308)   my $table = "new_superkingdom";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2309)   my $select_query  = "SELECT DISTINCT * FROM $table;";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2310)   my $write_to_file = system("mysql -h $vampsHost $vampsDB --show-warnings -e \"$select_query\" > $temp_aux_filename");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2311)   print "Executing: write_to_file = mysql -h $vampsHost $vampsDB --show-warnings -e \"$select_query\" > $temp_aux_filename\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2312)   if ($write_to_file) {warn "Error writing into $temp_aux_filename\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2313)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2314)   my $write_to_db   = "LOAD DATA LOCAL INFILE '" . $temp_aux_filename . "' INTO TABLE new_superkingdom_copy IGNORE 1 LINES;";  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2315)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2316)   # my $sql_prep = $dbhVamps->prepare($write_to_file) || die "Unable to prepare query: $write_to_file\nError: " . $dbhVamps->errstr . "\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2317)   # # print "Executing: dbh = $dbhVamps;\nsql = $sql;\nsql_prep = $sql_prep\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2318)   # $sql_prep->execute() || die "Unable to execute MySQL statement: $write_to_file\nError: " . $dbhVamps->errstr . "(" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2319) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2320)   my $sql_prep = $dbhVamps->prepare($write_to_db) || die "Unable to prepare query: $write_to_db\nError: " . $dbhVamps->errstr . "\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2321)   # print "Executing: dbh = $dbhVamps;\nsql = $sql;\nsql_prep = $sql_prep\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2322)   print "Executing: write_to_db = $write_to_db\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2323)   $sql_prep->execute() || die "Unable to execute MySQL statement: $write_to_db\nError: " . $dbhVamps->errstr . "(" . (localtime) . ")\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2324) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2325)   my $remove_temp_file = system("rm $temp_aux_filename");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2326)   if ($remove_temp_file) {warn "Error removing $temp_aux_filename\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2327)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2328)   # my @query_names = ($write_to_file, $write_to_db);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2329)   # &prep_exec_query_with_time(\@query_names);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2330)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2331) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2332) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2333) sub check_foreign_key()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2334) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2335)   my $table_name             = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2336)   my $referenced_table_name  = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2337)   my $referenced_column_name = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2338)   my $table_schema           = $vampsDB;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2339)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2340)   # WHERE TABLE_NAME             = \"$taxon_string_table\"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2341)   my $fk_exists_query = "SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2342)     WHERE TABLE_NAME             = \"$table_name\"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2343)       AND REFERENCED_TABLE_NAME  = \"$referenced_table_name\"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2344)       AND REFERENCED_COLUMN_NAME = \"$referenced_column_name\"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2345)       AND TABLE_SCHEMA           = \"$table_schema\"";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2346)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2347)   my $fk_exists = &prep_exec_fetch_query($dbhVamps, $fk_exists_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2348)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2349)   print "FFFFF: fk_exists = $fk_exists\n$fk_exists_query\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2350)   return $fk_exists;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2351) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2352) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2353) sub add_foreign_key() 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2354) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2355)   my ($fk_exists_query1, $fk_exists_query2, $fk_exists_query3, $fk_exists_query4, $fk_exists_query5, $fk_exists_query6, $fk_exists_query7,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2356)       $add_fk_query1, $add_fk_query2, $add_fk_query3, $add_fk_query4, $add_fk_query5, $add_fk_query6, $add_fk_query7) = "";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2357)   my @query_names_exec = ();
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2358)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2359)   my $fk_exists1 = &check_foreign_key($taxon_string_table.$tblSuffix, $rank_number_table, "rank_number");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2360)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2361)   # my $fk_exists1 = &check_foreign_key($taxon_string_table, $rank_number_table, "rank_number", $vampsDB);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2362)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2363)   $add_fk_query1 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2364)   "ALTER TABLE $taxon_string_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2365)     ADD FOREIGN KEY (rank_number) REFERENCES $rank_number_table (rank_number);";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2366)   push (@query_names_exec, $add_fk_query1) unless ($fk_exists1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2367) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2368)   # if one fk exists we assume that all exist
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2369)   my $fk_exists2 = &check_foreign_key($taxonomy_table.$tblSuffix, $superkingdom_table.$tblSuffix, "superkingdom_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2370) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2371)   $add_fk_query2 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2372)   "ALTER TABLE $taxonomy_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2373)     ADD FOREIGN KEY (superkingdom_id) REFERENCES $superkingdom_table".$tblSuffix." (superkingdom_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2374)     ADD FOREIGN KEY (taxon_string_id) REFERENCES $taxon_string_table".$tblSuffix." (taxon_string_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2375)     ADD FOREIGN KEY (phylum_id) REFERENCES $phylum_table".$tblSuffix." (phylum_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2376)     ADD FOREIGN KEY (class_id) REFERENCES $class_table".$tblSuffix." (class_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2377)     ADD FOREIGN KEY (orderx_id) REFERENCES $orderx_table".$tblSuffix." (orderx_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2378)     ADD FOREIGN KEY (family_id) REFERENCES $family_table".$tblSuffix." (family_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2379)     ADD FOREIGN KEY (genus_id) REFERENCES $genus_table".$tblSuffix." (genus_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2380)     ADD FOREIGN KEY (species_id) REFERENCES $species_table".$tblSuffix." (species_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2381)     ADD FOREIGN KEY (strain_id) REFERENCES $strain_table".$tblSuffix." (strain_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2382)     ADD FOREIGN KEY (rank_id) REFERENCES $rank_table (rank_id);";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2383)   push (@query_names_exec, $add_fk_query2) unless ($fk_exists2);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2384)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2385)   my $fk_exists3 = &check_foreign_key($project_table.$tblSuffix, $contact_table.$tblSuffix, "contact_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2386)   $add_fk_query3 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2387)   "ALTER TABLE $project_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2388)     ADD FOREIGN KEY (contact_id) REFERENCES $contact_table".$tblSuffix." (contact_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2389)     ADD FOREIGN KEY (env_sample_source_id) REFERENCES $env_sample_source_table (env_sample_source_id)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2390)   push (@query_names_exec, $add_fk_query3) unless ($fk_exists3);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2391)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2392)   my $fk_exists4 = &check_foreign_key($dataset_table.$tblSuffix, $project_table.$tblSuffix, "project_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2393)   $add_fk_query4 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2394)   "ALTER TABLE $dataset_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2395)     ADD FOREIGN KEY (project_id) REFERENCES $project_table".$tblSuffix." (project_id)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2396)   push (@query_names_exec, $add_fk_query4) unless ($fk_exists4);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2397)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2398)   my $fk_exists5 = &check_foreign_key($project_dataset_table.$tblSuffix, $project_table.$tblSuffix, "project_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2399)   $add_fk_query5 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2400)   "ALTER TABLE $project_dataset_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2401)     ADD FOREIGN KEY (project_id) REFERENCES $project_table".$tblSuffix." (project_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2402)     ADD FOREIGN KEY (dataset_id) REFERENCES $dataset_table".$tblSuffix." (dataset_id)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2403)   push (@query_names_exec, $add_fk_query5) unless ($fk_exists5);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2404)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2405)   my $fk_exists6 = &check_foreign_key($summed_data_cube_table.$tblSuffix, $taxon_string_table.$tblSuffix, "taxon_string_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2406)   $add_fk_query6 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2407)   "ALTER TABLE $summed_data_cube_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2408)     ADD FOREIGN KEY (taxon_string_id) REFERENCES $taxon_string_table".$tblSuffix." (taxon_string_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2409)     ADD FOREIGN KEY (project_id) REFERENCES $project_table".$tblSuffix." (project_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2410)     ADD FOREIGN KEY (dataset_id) REFERENCES $dataset_table".$tblSuffix." (dataset_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2411)     ADD FOREIGN KEY (project_dataset_id) REFERENCES $project_dataset_table".$tblSuffix." (project_dataset_id)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2412)   push (@query_names_exec, $add_fk_query6) unless ($fk_exists6);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2413)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2414)   my $fk_exists7 = &check_foreign_key($user_contact_table.$tblSuffix, $user_table.$tblSuffix, "user_id");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2415)   $add_fk_query7 = 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2416)   "ALTER TABLE $user_contact_table".$tblSuffix."
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2417)     ADD FOREIGN KEY (user_id) REFERENCES $user_table".$tblSuffix." (user_id),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2418)     ADD FOREIGN KEY (contact_id) REFERENCES $contact_table".$tblSuffix." (contact_id)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2419)   push (@query_names_exec, $add_fk_query7) unless ($fk_exists7);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2420) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2421)     # print "OOO1: add_fk_query2 = $add_fk_query2\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2422)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2423)   # foreach my $a ($add_fk_query1, $add_fk_query2, $add_fk_query3, $add_fk_query4, $add_fk_query5, $add_fk_query6, $add_fk_query7)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2424)   # {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2425)   #   print "OOO1: $a\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2426)   # }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2427)     # @query_names_exec = ($add_fk_query1, $add_fk_query2, $add_fk_query3, $add_fk_query4, $add_fk_query5, $add_fk_query6, $add_fk_query7);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2428)     # foreach my $t (@query_names_exec)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2429)     # {print "TTTTT: $t\n";}
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2430)       
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2431)     &prep_exec_query_with_time(\@query_names_exec);    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2432) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2433) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2434) sub rename_tables()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2435) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2436)   my $suffix_from = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2437)   my $suffix_to   = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2438)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2439)   while (my ($key, $value) = each %norm_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2440)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2441)     print "key = $key:  value = $value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2442)      # if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2443)     my $table_name = "$value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2444)     my $table_name_query    = "RENAME TABLE $table_name" . $suffix_from . " to $table_name" . $suffix_to;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2445)     print "table_name_query = $table_name_query\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2446)     &prep_exec_query($dbhVamps, $table_name_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2447)     # print "HEREEE\n";  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2448)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2449) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2450) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2451) sub drop_norm_previous()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2452) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2453)   # An order is important because of foreign keys
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2454)   my $drop_previous_query = "DROP TABLE IF EXISTS
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2455)   new_user_contact_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2456)   new_summed_data_cube_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2457)   new_project_dataset_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2458)   new_dataset_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2459)   new_project_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2460)   new_taxonomy_previous,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2461)   new_class_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2462)   new_contact_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2463)   new_family_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2464)   new_genus_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2465)   new_orderx_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2466)   new_phylum_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2467)   new_species_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2468)   new_strain_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2469)   new_superkingdom_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2470)   new_taxon_string_previous, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2471)   new_user_previous;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2472)   ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2473) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2474)   &prep_exec_query($dbhVamps, $drop_previous_query);  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2475) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2476) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2477) sub truncate_norm_transfer()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2478) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2479)   # An order is important because of foreign keys
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2480)   # TODO: create as, drop table, rename (instead of truncate)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2481)   my @tables = (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2482)   "new_user_contact_transfer",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2483)   "new_summed_data_cube_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2484)   "new_project_dataset_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2485)   "new_dataset_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2486)   "new_project_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2487)   "new_taxonomy_transfer",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2488)   "new_class_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2489)   "new_contact_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2490)   "new_family_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2491)   "new_genus_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2492)   "new_orderx_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2493)   "new_phylum_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2494)   "new_species_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2495)   "new_strain_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2496)   "new_superkingdom_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2497)   "new_taxon_string_transfer", 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2498)   "new_user_transfer");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2499)   foreach my $table_name (@tables)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2500)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2501)     my $table_name_temp = $table_name."_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2502)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2503)     my $drop_transfer_temp_query = "DROP TABLE IF EXISTS $table_name_temp";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2504)     &prep_exec_query($dbhVamps, $drop_transfer_temp_query);   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2505)     my $duplicate_transfer_query = "CREATE TABLE IF NOT EXISTS $table_name_temp LIKE $table_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2506)     &prep_exec_query($dbhVamps, $duplicate_transfer_query);      
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2507)     my $drop_transfer_query      = "DROP TABLE IF EXISTS $table_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2508)     &prep_exec_query($dbhVamps, $drop_transfer_query);   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2509)     my $rename_transfer_query    = "RENAME TABLE $table_name_temp TO $table_name ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2510)     &prep_exec_query($dbhVamps, $rename_transfer_query);   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2511)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2512) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2513) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2514) sub create_norm_tables_ill()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2515) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2516)   # ill tables: drop, create, alter
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2517)   # to have correct ids we have to send values
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2518)   my @table_names = ("new_taxonomy", "new_dataset", "new_project_dataset", "new_summed_data_cube", "new_user_contact");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2519) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2520)   # drop
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2521)   # An order is important because of foreign keys
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2522)   foreach my $table_name (@table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2523)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2524)     my $table_name_ill = $table_name."_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2525)     
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2526)     my $drop_table_ill_query = "DROP TABLE IF EXISTS $table_name_ill";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2527)     print "$drop_table_ill_query\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2528)     &prep_exec_query($dbhVamps, $drop_table_ill_query);   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2529)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2530)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2531)   # create
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2532)   my $create_new_taxonomy_ill         = "CREATE TABLE `new_taxonomy_ill` LIKE new_taxonomy";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2533)   my $create_new_dataset_ill          = "CREATE TABLE `new_dataset_ill` LIKE new_dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2534)   my $create_new_project_dataset_ill  = "CREATE TABLE `new_project_dataset_ill` LIKE new_project_dataset";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2535)   my $create_new_summed_data_cube_ill = "CREATE TABLE `new_summed_data_cube_ill` LIKE new_summed_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2536)   my $create_new_user_contact_ill     = "CREATE TABLE `new_user_contact_ill` LIKE new_user_contact";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2537)   @query_names_exec = ($create_new_taxonomy_ill, $create_new_dataset_ill, $create_new_project_dataset_ill, $create_new_summed_data_cube_ill, $create_new_user_contact_ill);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2538)   print "QQQ1: create ill tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2539) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2540)   &prep_exec_query_with_time(\@query_names_exec);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2541)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2542)   # alter
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2543)   my $alter_new_taxonomy_ill = "ALTER TABLE `new_taxonomy_ill` 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2544)     add column taxon_string varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2545)     add column superkingdom char(10) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2546)     add column phylum varchar(34) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2547)     add column class varchar(34) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2548)     add column orderx varchar(34) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2549)     add column family varchar(37) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2550)     add column genus varchar(60) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2551)     add column species varchar(37) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2552)     add column strain varchar(34) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2553)     add column rank varchar(12) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2554)     add key taxon_string (taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2555)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2556)  my $alter_new_dataset_ill = "ALTER TABLE `new_dataset_ill` 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2557)     add column project varchar(32) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2558)     add key project (project)    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2559)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2560)  my $alter_new_project_dataset_ill = "ALTER TABLE `new_project_dataset_ill` 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2561)     add column project varchar(32) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2562)     add column dataset varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2563)     add key project (project),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2564)     add key dataset (dataset)    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2565)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2566)  my $alter_new_summed_data_cube_ill = "ALTER TABLE `new_summed_data_cube_ill` 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2567)     add column project varchar(32) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2568)     add column dataset varchar(64) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2569)     add column taxon_string varchar(255) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2570)     add column project_dataset varchar(100) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2571)     add key project (project),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2572)     add key dataset (dataset),    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2573)     add key taxon_string (taxon_string),
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2574)     add key project_dataset (project_dataset)    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2575)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2576)  my $alter_new_user_contact_ill = "ALTER TABLE `new_user_contact_ill` 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2577)     add column user varchar(20) NOT NULL default '',
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2578)     add column contact varchar(64) NOT NULL,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2579)     add key user (user),    
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2580)     add key contact (contact)        
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2581)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2582)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2583)   @query_names_exec = ($alter_new_taxonomy_ill, $alter_new_dataset_ill, $alter_new_project_dataset_ill, $alter_new_summed_data_cube_ill, $alter_new_user_contact_ill);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2584)   print "QQQ2: alter ill tables\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2585) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2586)   &prep_exec_query_with_time(\@query_names_exec);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2587)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2588) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2589) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2590) sub update_current_from_illumina_transfer()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2591) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2592)   my $insert_vamps_data_cube_q         = "INSERT IGNORE INTO $final_taxes_table (project, dataset, taxon_string, superkingdom, phylum, class, orderx, family, genus, species, strain, rank, knt, frequency, dataset_count, classifier) SELECT project, dataset, taxon_string, superkingdom, phylum, class, orderx, family, genus, species, strain, rank, knt, frequency, dataset_count, classifier 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2593)                                           FROM $tmp_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2594)   my $insert_vamps_export_q            = "INSERT IGNORE INTO $final_reads_table (read_id, project, dataset, refhvr_ids, distance, taxonomy, sequence, rank, date_trimmed) SELECT read_id, project, dataset, refhvr_ids, distance, taxonomy, sequence, rank, date_trimmed 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2595)                                           FROM $tmp_reads_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2596)   my $insert_vamps_junk_data_cube_q    = "INSERT IGNORE INTO $final_summed_taxes_table (taxon_string, knt, frequency, dataset_count, rank, project, dataset, project_dataset, classifier) SELECT taxon_string, knt, frequency, dataset_count, rank, project, dataset, project_dataset, classifier 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2597)                                           FROM $tmp_summed_taxes_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2598)   my $insert_vamps_projects_datasets_q = "INSERT IGNORE INTO $final_project_dataset_table (project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info) SELECT project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2599)                                           FROM $tmp_project_dataset_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2600)   my $insert_vamps_projects_info_q     = "INSERT IGNORE INTO $final_project_desc_table (project_name, title, description, contact, email, institution, env_source_id, edits) SELECT project_name, title, description, contact, email, institution, env_source_id, edits 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2601)                                           FROM $tmp_project_desc_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2602)   my $insert_vamps_sequences_q         = "INSERT IGNORE INTO $final_seqs_table (sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, project_dataset) SELECT sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, project_dataset 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2603)                                           FROM $tmp_seqs_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2604)   my $insert_vamps_taxonomy_q          = "INSERT IGNORE INTO $final_distinct_taxa_table (taxon_string, rank, num_kids) SELECT taxon_string, rank, num_kids FROM $tmp_distinct_taxa_table";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2605)   my $insert_new_superkingdom_q        = "INSERT IGNORE INTO $superkingdom_table (superkingdom) SELECT superkingdom FROM new_superkingdom_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2606)   my $insert_new_phylum_q              = "INSERT IGNORE INTO $phylum_table (phylum) SELECT phylum FROM new_phylum_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2607)   my $insert_new_class_q               = "INSERT IGNORE INTO $class_table (class) SELECT class FROM new_class_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2608)   my $insert_new_orderx_q              = "INSERT IGNORE INTO $orderx_table (orderx) SELECT orderx FROM new_orderx_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2609)   my $insert_new_family_q              = "INSERT IGNORE INTO $family_table (family) SELECT family FROM new_family_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2610)   my $insert_new_genus_q               = "INSERT IGNORE INTO $genus_table (genus) SELECT genus FROM new_genus_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2611)   my $insert_new_species_q             = "INSERT IGNORE INTO $species_table (species) SELECT species FROM new_species_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2612)   my $insert_new_strain_q              = "INSERT IGNORE INTO $strain_table (strain) SELECT strain FROM new_strain_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2613)   my $insert_new_taxon_string_q        = "INSERT IGNORE INTO $taxon_string_table (taxon_string, rank_number) SELECT taxon_string, rank_number FROM new_taxon_string_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2614)   my $insert_new_user_q                = "INSERT IGNORE INTO $user_table (user, passwd, active, security_level) SELECT user, passwd, active, security_level FROM new_user_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2615) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2616)   my $insert_new_contact_q             = "INSERT IGNORE INTO $contact_table (first_name, last_name, email, institution, contact) SELECT first_name, last_name, email, institution, contact FROM new_contact_transfer";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2617)   my $insert_new_user_contact_q        = "INSERT IGNORE INTO new_user_contact (contact_id, user_id) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2618)     SELECT new_contact.contact_id, new_user.user_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2619)     FROM new_user_contact_ill
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2620)     join new_user using(user)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2621)     join new_contact using(contact)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2622)   ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2623)   my $insert_new_project_q             = "INSERT IGNORE INTO $project_table (project, title, project_description, funding, env_sample_source_id, contact_id) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2624)     SELECT project, title, project_description, funding, env_sample_source_id, contact_id 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2625)     FROM new_project_transfer
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2626)     JOIN new_contact using(contact_id)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2627)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2628)   my $insert_new_taxonomy_q            = "INSERT IGNORE INTO $taxonomy_table (taxon_string_id, superkingdom_id, phylum_id, class_id, orderx_id, family_id, genus_id, species_id, strain_id, rank_id, classifier) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2629)     SELECT new_taxon_string.taxon_string_id, new_superkingdom.superkingdom_id, new_phylum.phylum_id, new_class.class_id, new_orderx.orderx_id, new_family.family_id, 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2630)       new_genus.genus_id, new_species.species_id, new_strain.strain_id, new_rank.rank_id, classifier
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2631)     FROM new_taxonomy_ill
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2632)       JOIN new_taxon_string USING(taxon_string)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2633)       JOIN new_superkingdom USING(superkingdom)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2634)       JOIN new_phylum USING(phylum)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2635)       JOIN new_class USING(class)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2636)       JOIN new_orderx USING(orderx)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2637)       JOIN new_family USING(family)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2638)       JOIN new_genus USING(genus)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2639)       JOIN new_species USING(species)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2640)       JOIN new_strain USING(strain)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2641)       JOIN new_rank USING(rank)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2642)   my $insert_new_dataset_q             = "INSERT IGNORE INTO $dataset_table (dataset, dataset_description, reads_in_dataset, has_sequence, project_id, date_trimmed) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2643)     SELECT dataset, dataset_description, reads_in_dataset, has_sequence, new_project.project_id, date_trimmed 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2644)     FROM new_dataset_ill
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2645)     join new_project using(project)";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2646) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2647)   my $insert_new_project_dataset_q     = "INSERT IGNORE INTO $project_dataset_table (project_dataset, dataset_id, project_id) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2648)     SELECT project_dataset, new_dataset.dataset_id, new_project.project_id 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2649)     FROM new_project_dataset_ill
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2650)       join new_project using(project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2651)       join new_dataset using(dataset)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2652)       where new_dataset.project_id = new_project.project_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2653)       ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2654)   my $insert_new_summed_data_cube_q    = "INSERT IGNORE INTO $summed_data_cube_table (taxon_string_id, knt, frequency, dataset_count, rank_number, project_id, dataset_id, project_dataset_id, classifier) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2655)     SELECT new_taxon_string.taxon_string_id, knt, frequency, dataset_count, rank_number, new_project.project_id, new_dataset.dataset_id, new_project_dataset.project_dataset_id, classifier 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2656)     FROM new_summed_data_cube_ill
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2657)       join new_project using(project)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2658)       join new_dataset using(dataset)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2659)       join new_taxon_string using(taxon_string, rank_number)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2660)       join new_project_dataset using(project_dataset)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2661)       where new_dataset.project_id = new_project.project_id
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2662)     ";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2663)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2664)     @query_names_exec = (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2665)       $insert_vamps_data_cube_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2666)       $insert_vamps_export_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2667)       $insert_vamps_junk_data_cube_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2668)       $insert_vamps_projects_datasets_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2669)       $insert_vamps_projects_info_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2670)       $insert_vamps_sequences_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2671)       $insert_vamps_taxonomy_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2672)       $insert_new_superkingdom_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2673)       $insert_new_phylum_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2674)       $insert_new_class_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2675)       $insert_new_orderx_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2676)       $insert_new_family_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2677)       $insert_new_genus_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2678)       $insert_new_species_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2679)       $insert_new_strain_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2680)       $insert_new_taxon_string_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2681)       $insert_new_user_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2682)       $insert_new_contact_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2683)       $insert_new_user_contact_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2684)       $insert_new_project_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2685)       $insert_new_taxonomy_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2686)       $insert_new_dataset_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2687)       $insert_new_project_dataset_q,
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2688)       $insert_new_summed_data_cube_q
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2689)     );
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2690)     print "SSS1: insert ill data\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2691) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2692)     &prep_exec_query_with_time(\@query_names_exec);  
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2693) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2694) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2695) sub get_last_id()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2696) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2697)   my %last_ids;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2698)   while (my ($key, $value) = each %norm_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2699)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2700)     print "key = $key:  value = $value\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2701)     my $id = $key."_id";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2702)     my $table_name = "$value";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2703)     my $table_name_query = "SELECT max($id) FROM $table_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2704)     print "table_name_query = $table_name_query\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2705)     $last_ids{$table_name} = &prep_exec_fetch_query($dbhVamps, $table_name_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2706)     print "table_name = $table_name; last_ids = $last_ids{$table_name}\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2707)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2708)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2709)   my $get_last_id_vamps_data_cube_q         = "select max(id) from vamps_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2710)   my $get_last_id_vamps_export_q            = "select max(id) from vamps_export";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2711)   my $get_last_id_vamps_junk_data_cube_q    = "select max(id) from vamps_junk_data_cube";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2712)   my $get_last_id_vamps_projects_datasets_q = "select max(id) from vamps_projects_datasets";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2713)   my $get_last_id_vamps_projects_info_q     = "select max(id) from vamps_projects_info";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2714)   my $get_last_id_vamps_sequences_q         = "select max(id) from vamps_sequences";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2715)   my $get_last_id_vamps_taxonomy_q          = "select max(id) from vamps_taxonomy";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2716)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2717)   my @vamps_table_names = (
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2718)     "vamps_data_cube",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2719)     "vamps_export",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2720)     "vamps_junk_data_cube",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2721)     "vamps_projects_datasets",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2722)     "vamps_projects_info",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2723)     "vamps_sequences",
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2724)     "vamps_taxonomy"
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2725)   );
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2726)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2727)   foreach my $vamps_table_name (@vamps_table_names)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2728)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2729)     my $table_name_query = "SELECT max(id) FROM $vamps_table_name";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2730)     print "table_name_query = $table_name_query\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2731)     $last_ids{$vamps_table_name} = &prep_exec_fetch_query($dbhVamps, $table_name_query);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2732)     print "table_name = $vamps_table_name; last_ids = $last_ids{$vamps_table_name}\n" if ($test_only == 1);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2733)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2734)   return %last_ids;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2735) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2736) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2737) sub write_to_file()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2738) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2739)   my $file_name = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2740)   my $params    = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2741)   my %last_ids  = %$params;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2742)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2743)   # my $out_file = 'last_ids.txt';
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2744)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2745)   open(LAST_IDS, ">$file_name");
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2746) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2747)   while (my ($key, $value) = each %last_ids)
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2748)   {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2749)     print LAST_IDS "$key\t$value\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2750)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2751)   close(LAST_IDS);
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2752) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2753) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2754) sub key_check_no()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2755) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2756)   print "\n=======================\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2757)   &prep_exec_query_print($dbhVamps, 'SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2758)   &prep_exec_query_print($dbhVamps, 'SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2759)   &prep_exec_query_print($dbhVamps, 'SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE="TRADITIONAL";');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2760) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2761) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2762) sub key_check_yes()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2763) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2764)   print "\n=======================\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2765)   &prep_exec_query_print($dbhVamps, 'SET SQL_MODE=@OLD_SQL_MODE');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2766)   &prep_exec_query_print($dbhVamps, 'SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2767)   &prep_exec_query_print($dbhVamps, 'SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS');
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2768)   print "\n=======================\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2769) }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2770)   
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2771) sub get_ids_from_file()
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2772) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2773)   my $file_name = shift;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2774)   open my $fh, '<', $file_name or die $!;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2775) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2776)   my %last_ids_hash;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2777)   # use Data::Dumper;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2778) 
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2779)   while (<$fh>) {
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2780)       chomp;        
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2781)       my @row = split;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2782)       # print "\n====== Dumper row ==\n";
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2783)       # print Dumper @row;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2784)       $last_ids_hash{$row[0]} = $row[1];
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2785)   }
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2786)   close $fh;
e71f9464 (annaship 2013-01-03 13:05:51 -0500 2787)   return %last_ids_hash;
57f46ef3 (annaship 2013-02-15 16:15:12 -0500 2788) }
