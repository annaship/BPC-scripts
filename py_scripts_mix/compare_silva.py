from collections import namedtuple

class MySilva():
    def __init__(self):
        self.content_line = namedtuple('content_line', 'id start end tax')
    
    def get_file_content(self, in_filename):
        with open(in_filename, 'rb') as f:
            return f.readlines()

    def parse_tax_content(self, content_name):
        parsed_content = []
        for line in content_name:
            # print line
            id    = line.split(".")[0].strip(">")
            start = line.split(".")[1]
            end   = line.split(".")[2].split(" ")[0]
            tax   = " ".join(line.split(" ")[1:])
            # print "id = %s; start = %s; end = %s; tax = %s" % (id, start, end, tax)
            parsed_content.append((id, start, end, tax))
        return parsed_content
        
    def get_diff_tax_only(self, cont_n119, cont_n123):
        for t1 in minus_both_content_123_p:
            for t2 in tax_content_119_p:
                if ((t1[0:2] == t2[0:2]) and (t1[3] != t2[3])):
                    print "119 = %s\n123 = %s" % (t2, t1)


    def get_diff_stop_only(self, cont_n119, cont_n123):
        for t1 in minus_both_content_123_p:
            for t2 in tax_content_119_p:
                if ((t1[0] == t2[0]) and (t1[2] == t2[2]) and (t1[3] == t2[3])):
                    print "119 = %s\n123 = %s" % (t2, t1)



        

if __name__ == '__main__':
    util = MySilva()
    tax_content_119 = util.get_file_content("refssu_headers_119.txt")
    tax_content_123 = util.get_file_content("refssu_headers_123_1.txt")
    minus_both_content_123 = util.get_file_content("headers123_minus_both.txt")
    
    minus_both_content_123_p = util.parse_tax_content(minus_both_content_123)
    tax_content_119_p = util.parse_tax_content(tax_content_119)

    for t1 in minus_both_content_123_p:
        for t2 in tax_content_119_p:
            if ((t1[0:2] == t2[0:2]) and (t1[3] != t2[3])):
                print "119 = %s\n123 = %s" % (t2, t1)
    # 
    # print "+" * 10
    # print minus_both_content_123_p
    # 
    # print "+" * 10
    # print tax_content_119_p