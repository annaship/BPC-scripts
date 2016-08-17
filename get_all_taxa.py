"""
Get more levels from
release11_2_Archaea_unaligned.fa.gz
release11_2_Bacteria_unaligned.fa.gz
and make taxonomy.map

S000871964	Acidimicrobium_ferrooxidans	Acidimicrobium	NA
should be
S000871964	Acidimicrobium_ferrooxidans	Acidimicrobium  Acidimicrobiaceae	NA

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
    
    def make_taxonomy_by_rank(self, arr):
        print "arr = %s" % arr
        # print 'arr[0] = %s, type = %s' % (arr[0], type(arr[0]))
        n_a = arr[0].split(";")
        print 'arr[0].split(";") = %s' % n_a
        print len(n_a)
        #     q = r.split(";")
        #     print 'r.split(";") = %s' % (q)
        #     print "len(r.split(\";\")) = %s" % (len(q))
        
        # l = 'Lineage=Root;rootrank;Bacteria;domain;"Actinobacteria";phylum;Actinobacteria;class;Acidimicrobidae;subclass;Acidimicrobiales;order;"Acidimicrobineae";suborder;Acidimicrobiaceae;family;Ferrimicrobium;genus'
        # l_arr = l.split(";")
        # my_dict['S001416053'][l_arr[3]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[5]] = l_arr[4] 
        # my_dict['S001416053'][l_arr[7]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[9]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[3]] = l_arr[2] 

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
            
            # S003805392 Ferrimicrobium acidiphilum; PS130, ['Lineage=Root;rootrank;Bacteria;domain;"Actinobacteria";phylum;Actinobacteria;class;Acidimicrobidae;subclass;Acidimicrobiales;order;"Acidimicrobineae";suborder;Acidimicrobiaceae;family;Ferrimicrobium;genus\n']
            l     = line.split("\t")
            # print "l = %s" % l
            
            first_part = l[0].split(" ")
            ind   = first_part[0].strip(">")
            binom = first_part[1:]
            tax   = l[1:]
            
            # print "ind = %s; binom = %s; tax = %s" % (ind, binom, tax)
            m_d[ind] = (binom, tax)
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
    
    for k, v in a.items():
        print k, v
        
    for k, v in a.items():
        spingo_tax.make_taxonomy_by_rank(v[1])