import csv
import codecs

class CsvTools():

    def __init__(self):
      self.input_file_content = []
      self.otput_file_content = []
      self.in_file_name = ""
      self.csv_content = []


    def import_from_file(self, csvfile):
        print "csvfile"
        print csvfile
        self.csvfile = csvfile

        self.get_reader()
        # print "LLL self.reader"
        # print self.reader

        # self.csv_headers, self.csv_content =
        self.parce_csv()
        
        # print "=" * 10
        # print self.csv_headers
        # print "=" * 10
        
        print "SSS self.csv_content: "
        print self.input_file_content
        print "=" * 10        
        
        for x in self.input_file_content:
            print "for x in self.input_file_content:"
            print (x)
        #
        # self.check_headers_presence()
        #
        # self.get_csv_by_header_uniqued()


    def get_reader(self):
        try:
            infile = open(self.csvfile, mode='r')
            self.reader = csv.DictReader(codecs.EncodedFile(infile, "utf-8"), delimiter=',', quotechar='"')
        except csv.Error as e:
            self.errors.append('%s is not a valid CSV file: %s' % (infile, e))
        except:
            raise


    def parce_csv(self):
      
      # reader = csv.DictReader(csvfile)
      for row in self.reader:
        self.input_file_content.append(row)
        print row
        """
        {'Min Sequence Length': '', 'Hit end': '448855', 'Ref Seq Name': '', 'Molecule Type': 'DNA', 'Query end': '507', 'dash': '-', 'strain': 'NEG-M', '# Nucleotide Sequences With Mates': '', 'Genetic Code': 'Standard', 'Query start': '40', 'E Value': '2.52E-144', 'Ref Seq Length': '', 'Description': 'Naegleria gruberi strain NEG-M genomic NAEGRscaffold_22, whole genome shotgun sequence', 'Bit-Score': '323.188', 'SequenceListOrderingRevisionNumber': '', 'db_xref': 'taxon:744533', '# Nucleotide Sequences With Quality': '0', '% Pairwise Identity': '', 'Annotation': '26S proteasome CDS', 'Hit start': '449322', 'Topology': 'linear', 'Sequence Length': '156', 'Query coverage': '50.16%', 'Name': 'NW_003163305', 'Database': 'Naegleria gruberi NZ ACER00000000', 'Max Sequence Length': '', 'URN': 'urn:local:.:gak-6gx1c49', 'Modified': 'Mon Mar 29 00:00:00 EDT 2010', 'Created Date': 'Wed Aug 10 09:40:22 EDT 2016', '# Sequences': '', 'GID': '290990065', 'Organism': 'Naegleria gruberi strain NEG-M', '% Identical Sites': '', 'Sequence': 'GGGGMQGDQPLPDTAETVTISSLALLKMLKHGRAGVPMEVMGLMLGEFIDDYTVRCIDVFAMPQSGTGVSVEAVDPVFQTKMLELLKQTGRPEMVVGWYHSHPGFGCWLSSVDINTQQSFESLTKRSVAVVVDPIQSVKGKVVIDAFRTINPQLAM', 'Grade': '67.70%', 'Taxonomy': 'Eukaryota; Heterolobosea; Schizopyrenida; Vahlkampfiidae; Naegleria', 'Mean Coverage': '', 'Ref Seq Index': '', 'Accession': 'NW_003163305', 'Free end gaps': '', '# Nucleotides': '', 'country': 'USA', 'Query': '55387_Solumitrus_QUALITY_PASSED_R1_paired_contig_1705_7110_8043f', 'Original Query Frame': '1', 'Size': '8 KB'}
        
        """
        # print(row['Name'], row['Annotation'])
      
      
      # for y_index, row in enumerate(self.reader):


          # print "parce_csv row"
          # print row

          # if y_index == 0:
          #     self.csv_headers = [header_name.lower() for header_name in row if header_name]
          #     # continue
          # else:
          #     self.csv_content.append(row)
                       
      # return self.csv_headers, self.csv_content



if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser(description = 'Adds a column from one csv file to another. Two files should have a common column (a common key).',     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("-f", "--from_file_name",
                required = True, action = "store", dest = "from_file_name", default = "in_file.csv",
                help = "From CSV file name")

    parser.add_argument("-t", "--to_file_name",
                required = True, action = "store", dest = "to_file_name", default = "out_file.csv",
                help = "Destination CSV file name")
                
    parser.add_argument("-d", "--delimiter",
                required = False, action = "store", dest = "delim", default = ',',
                help = "CSV delimeter: comma, tab, space etc")
                
    parser.add_argument("-q", "--quotechar",
                required = False, action = "store", dest = "quotechar", default = '"',
                help = "CSV quote character: single or double quote")                

    args = parser.parse_args()
    print args

    csv_tools = CsvTools()
    csv_tools.import_from_file(args.from_file_name)

