import csv
import codecs

class CsvTools():

    def __init__(self):
      self.input_file_dict = {}
      self.in_file_name = ""
      self.csv_content = []


    def import_from_file(self, csvfile):
        print "csvfile"
        print csvfile
        self.csvfile = csvfile

        self.get_reader()
        print "LLL self.reader"
        print self.reader

        self.csv_headers, self.csv_content = self.parce_csv()
        
        print "=" * 10        
        print self.csv_headers
        print "=" * 10        
        
        print "SSS self.csv_content: "
        for x in self.csv_content:
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
        # print row
        print(row['Name'], row['Annotation'])
      
      
      # for y_index, row in enumerate(self.reader):


          # print "parce_csv row"
          # print row

          # if y_index == 0:
          #     self.csv_headers = [header_name.lower() for header_name in row if header_name]
          #     # continue
          # else:
          #     self.csv_content.append(row)
                       
      return self.csv_headers, self.csv_content



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

