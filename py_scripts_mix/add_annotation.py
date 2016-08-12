import csv
import codecs

class CsvTools():

    def __init__(self, args):

      print args

      self.from_file_name  = args.from_file_name
      self.to_file_name    = args.to_file_name
      self.res_file_name   = args.res_file_name
      self.result_content  = []

      self.delimiter = args.delimiter
      self.quotechar = args.quotechar


    def read_from_file(self):
      from_headers, from_reader = self.get_reader(self.from_file_name)
      self.from_file_content    = self.parce_csv(from_reader)

    def read_to_file(self):
      self.to_headers, to_reader = self.get_reader(self.to_file_name)
      self.to_file_content  = self.parce_csv(to_reader)

    def make_res_dict(self):
      for o_row in self.to_file_content:
        combined_row = o_row
        combined_row['Annotation'] = ""

        for i_row in self.from_file_content:
          if i_row['Query'] == o_row['Name']:
            combined_row['Annotation'] = i_row['Annotation']
        self.result_content.append(combined_row)

    def write_to_res_file(self):
      self.make_res_dict()
      ordered_fieldnames = self.to_headers
      ordered_fieldnames.append('Annotation')
      with open(self.res_file_name, 'wb') as fou:
        dw = csv.DictWriter(fou, delimiter=self.delimiter, fieldnames=ordered_fieldnames)
        dw.writeheader()
        for item in self.result_content:
          dw.writerow(item)

    def get_reader(self, file_name):
        try:
            infile  = open(file_name, mode = 'r')
            reader  = csv.DictReader(codecs.EncodedFile(infile, "utf-8"), delimiter = self.delimiter, quotechar = self.quotechar)
            headers = reader.fieldnames
            return headers, reader
        except csv.Error as e:
            self.errors.append('%s is not a valid CSV file: %s' % (infile, e))
        except:
            raise

    def parce_csv(self, reader):
      # file_content = []
      # for row in reader:
      #   file_content.append(row)
      # return file_content
      return [row for row in reader]


if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser(description = 'Adds a column from one csv file to another. Two files should have a common column (a common key).',     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("-f", "--from_file_name",
                required = True, action = "store", dest = "from_file_name", default = "in_file.csv",
                help = "From CSV file name")

    parser.add_argument("-t", "--to_file_name",
                required = True, action = "store", dest = "to_file_name", default = "to_file.csv",
                help = "Destination CSV file name")

    parser.add_argument("-r", "--res_file_name",
                required = False, action = "store", dest = "res_file_name", default = 'result_file.csv',
                help = "Result CSV file name")


    parser.add_argument("-d", "--delimiter",
                required = False, action = "store", dest = "delimiter", default = ',',
                help = "CSV delimeter: comma, tab, space etc")

    parser.add_argument("-q", "--quotechar",
                required = False, action = "store", dest = "quotechar", default = '"',
                help = "CSV quote character: single or double quote")

# TODO: add key names args

    args = parser.parse_args()

    csv_tools = CsvTools(args)
    csv_tools.read_from_file()
    csv_tools.read_to_file()
    csv_tools.write_to_res_file()


  # TODO preserve headers order