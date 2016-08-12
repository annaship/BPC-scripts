import csv
import codecs

class CsvTools():

    def __init__(self):
      input_file_dict
      
    def import_from_file(self, csvfile):
        print "csvfile"
        print csvfile
        self.csvfile = csvfile
        
        with open(csvfile, 'rb') as csvfile:
            spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
            for row in spamreader:
                print ', '.join(row)
        
        # dialect = self.get_dialect()
        # print "dialect = "
        # print dialect
        #
        # self.get_reader(dialect)
        # print "LLL self.reader"
        # print self.reader
        #
        # self.csv_headers, self.csv_content = self.parce_csv()
        #
        # self.check_headers_presence()
        #
        # self.get_csv_by_header_uniqued()
        #

    def get_dialect(self):
        try:
            # dialect = csv.Sniffer().sniff(self.csvfile.read(1024), delimiters=";,")
            # dialect = csv.Sniffer().sniff(self.csvfile.read(1024), ",")
            # dialect = csv.Sniffer().sniff(self.csvfile.read(1024), delimiters=";,")

            dialect = csv.Sniffer().sniff(codecs.EncodedFile(self.csvfile, "utf-8").read(1024), delimiters=',')
            self.csvfile.seek(0)
            print "dialect.delimiter"
            print dialect.delimiter
            return dialect
        except csv.Error as e:
            self.errors.append('Warning for %s: %s' % (self.csvfile, e))
        except:
            raise

    def get_reader(self, dialect):
        try:
            self.csvfile.open()
            self.reader = csv.reader(codecs.EncodedFile(self.csvfile, "utf-8"), delimiter=',', dialect=dialect)
        except csv.Error as e:
            self.errors.append('%s is not a valid CSV file: %s' % (self.csvfile, e))
        except:
            raise
        


if __name__ == '__main__':
  
    import argparse
    parser = argparse.ArgumentParser(description = 'Adds a column from one csv file to another. Two files should have a common column (a common key).')
    
    parser.add_argument("-f", "--from_file_name",
                required = True,  action = "store", dest = "from_file_name", default = "",
                help = "From file_name")

    parser.add_argument("-t", "--to_file_name",
                required = True,  action = "store", dest = "to_file_name", default = "",
                help = "Destination file_name")

    args = parser.parse_args()
    print args
    
    
    csv_tools = CsvTools()
    csv_tools.import_from_file(args.from_file_name)

#
#
# from_file_name = '/Users/ashipunova/Dropbox/mix/today_ch/linda_script/from_Annotated_Solumitrus_reads.csv'
#
#     # seqs_file_lines = list(csv.reader(open(args.seqs_file, 'rb'), delimiter=','))[1:]
#
# with open(from_file_name, 'rb') as csvfile:
#     from_reader = csv.reader(csvfile, delimiter=',', quotechar='"')
#     for row in from_reader:
#         print ', '.join(row)


# import os
# import sys
# import itertools
#
# from_table =
#
# #modify the second column of the non-metazoa OTU file to have a second column that is jsut 1-n.
# # reads in file of GenBank numbers and taxonomy
# table=open('Ev9_good_all_notmets.csv','r')
# #opens GenBank output for each sequence
# data=open('Final_Eukarya.06.otus.lter.with_unknowns_nomets_sorted.csv','r')
# #output file created
# out=open('test_Ev9_nomets_4_SPADE.txt','w')
# #If data has a header that you want to replicate on output file, you would use these commands
# header=data.readline()
# out.write(header)
#
# #creates dictionary called reference
# reference={}
# #for every entry in the lookup table a dictionary key is created = GenBank number and
# #a dictionary value associated with the GenBank number = taxonomy
#
# for i in table:
#   reference[i[:i.index(",")]]=i[i.index(",")+1:-1]
# #for every row in the GenBank file, GenBank number is looked for in the dictionary of keys(GenBank
# #number) and if the GenBank number corresponding to one on the lookup table is found
# #the entire line of the GenBank file and its taxonomy is printed to the output file
# for j in data:
#   if reference.has_key(j[:j.index(",")]):
#     out.write(j[:])
# out.close
#
#
#
#
#
#
#
