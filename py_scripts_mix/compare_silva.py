class MySilva():
    def __init__(self):
        pass
    
    def get_file_content(self, in_filename):
        with open(in_filename, 'rb') as f:
            return f.readlines()

    def parse_tax_content(self, content_name):
        parsed_content = []
        for line in content_name[0:2]:
            print line
            id    = line.split(".")[0].strip(">")
            start = line.split(".")[1]
            end   = line.split(".")[2].split(" ")[0]
            tax   = line.split(" ")[1:]
            print "id = %s; start = %s; end = %s; tax = %s" % (id, start, end, tax)
            parsed_content.append((id, start, end, tax))
        return parsed_content
            

if __name__ == '__main__':
    util = MySilva()
    tax_content_119 = util.get_file_content("refssu_headers_119.txt")
    tax_content_123 = util.get_file_content("refssu_headers_123_1.txt")
    minus_both_content_123 = util.get_file_content("headers123_minus_both.txt")
    
    minus_both_content_123_p = util.parse_tax_content(minus_both_content_123)
    tax_content_119_p = util.parse_tax_content(tax_content_119)


    print "+" * 10
    print minus_both_content_123_p
    
    print "+" * 10
    print tax_content_119_p