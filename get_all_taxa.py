"""
Get more levels from
release11_2_Archaea_unaligned.fa.gz
release11_2_Bacteria_unaligned.fa.gz
and make taxonomy.map

"""
import gzip

class Spingo_Taxonomy():
    def __init__(self):
        # self.arc_filename = "/users/ashipunova/spingo/database/release11_2_Archaea_unaligned.fa.gz"
        # self.bact_filename = "/users/ashipunova/spingo/database/release11_2_Bacteria_unaligned.fa.gz"
        """
        cut -f1 taxonomy.map > mapped_ind.txt
        gzip -dc release11_2_Archaea_unaligned.fa.gz | grep -F -f mapped_ind.txt >mapped_arc_headers.txt
        time gzip -dc release11_2_Bacteria_unaligned.fa.gz | grep -F -f mapped_ind.txt >mapped_bact_headers.txt

        """
        self.tax_map_filename = "/users/ashipunova/spingo/database/taxonomy.map"
        self.arc_filename = "/users/ashipunova/spingo/database/mapped_arc_headers.txt"
        self.bact_filename = "/users/ashipunova/spingo/database/mapped_bact_headers.txt"

        self.tax_map_file_content = []
        self.arc_file_content = []
        self.bact_file_content = []
        self.taxmap_dict = {}
        self.maped_taxonomy_arr = []
        self.new_map_text = []

    def get_file_content(self, in_filename):
        with open(in_filename, 'rb') as f:
            return f.readlines()

    def get_taxmap_dict(self):
        for line in self.tax_map_file_content:
            self.taxmap_dict[line.split("\t")[0]] = line.split("\t")[1:]

    # too slow!
    # def get_maped_taxonomy_arr(self, filename):
    #     maped_taxonomy_arr = []
    #     with gzip.open(filename, 'rb') as f:
    #         for line in f:
    #             if line.startswith(">"):
    #                 for ind, val in self.taxmap_dict.items():
    #                     i1 = ">" + ind
    #                     if line.startswith(i1):
    #                         maped_taxonomy_arr.append(line)
    #     return maped_taxonomy_arr

    # def get_maped_taxonomy_arr(self, filename):
    #     with open(self.filename, 'rb') as f:
    #         for line in f:

    def get_mapped_dict(self, arr):
        m_d = {}
        for line in arr:
            print "line = %s" % line
            l = line.split("\t")
            m_d[l[0].strip(">")] = line.split("\t")[1:]
            print "m_d[l[0].strip(\">\")] = line.split(\"\t\")[1:]\n %s, %s" % (l[0].strip(">"), m_d[l[0].strip(">")])
        return m_d


if __name__ == '__main__':
    spingo_tax = Spingo_Taxonomy()

    spingo_tax.tax_map_file_content = spingo_tax.get_file_content(spingo_tax.tax_map_filename)
    print spingo_tax.tax_map_file_content[0]
    spingo_tax.get_taxmap_dict()
    # arc_maped_taxonomy_arr  = spingo_tax.get_maped_taxonomy_arr(spingo_tax.arc_filename)
    # bact_maped_taxonomy_arr = spingo_tax.get_maped_taxonomy_arr(spingo_tax.bact_filename)

    spingo_tax.arc_file_content  = spingo_tax.get_file_content(spingo_tax.arc_filename)
    spingo_tax.bact_file_content = spingo_tax.get_file_content(spingo_tax.bact_filename)

    print "spingo_tax.bact_file_content[0]"
    print spingo_tax.bact_file_content[0]

    test = spingo_tax.bact_file_content[0:3]
    a = spingo_tax.get_mapped_dict(test)
    
    # print "spingo_tax.get_mapped_dict(test)"
    # print a

    # for k, v in a:
    #     print k, v