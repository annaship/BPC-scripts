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
from itertools import izip
from collections import defaultdict

class Spingo_Taxonomy():
    def __init__(self):
        # self.arc_filename = "/users/ashipunova/spingo/database/release11_2_Archaea_unaligned.fa.gz"
        # self.bact_filename = "/users/ashipunova/spingo/database/release11_2_Bacteria_unaligned.fa.gz"
        """
        cut -f1 taxonomy.map > mapped_ind.txt
        gzip -dc release11_2_Archaea_unaligned.fa.gz | grep -F -f mapped_ind.txt >mapped_arc_headers.txt
        time gzip -dc release11_2_Bacteria_unaligned.fa.gz | grep -F -f mapped_ind.txt >mapped_bact_headers.txt

        """
        self.tax_map_filename = "/users/ashipunova/spingo/database/taxonomy.map_orig"
        self.arc_filename = "/users/ashipunova/spingo/database/mapped_arc_headers.txt"
        self.bact_filename = "/users/ashipunova/spingo/database/mapped_bact_headers.txt"

        self.tax_map_file_content = []
        self.arc_file_content = []
        self.bact_file_content = []
        self.taxmap_dict = {}
        self.new_map_arr = []
        
        # self.my_dict = defaultdict()

        

    def get_file_content(self, in_filename):
        with open(in_filename, 'rb') as f:
            return f.readlines()

    def get_taxmap_dict(self):
        for line in self.tax_map_file_content:
            self.taxmap_dict[line.split("\t")[0]] = line.split("\t")[1:]


    def pairwise(self, iterable):
        tax_array = iterable[0].strip().split(";")
        "s -> (s0,s1), (s1,s2), (s2, s3), ..."
        # print "tax_array = %s" % (tax_array)
        a = iter(tax_array)
        return izip(a, a)
        
    def make_taxonomy_by_rank(self, i_dict):
        tax_w_rank_dict = defaultdict()
        for k, v in i_dict.items():
            # print "=" * 10            
            # print k
            tax_w_rank_dict[k] = {}
            for x, y in spingo_tax.pairwise(v[1]):
               # print "%s: %s" % (y, x)
               if not y.startswith("rootrank"):
                   try:
                       tax_w_rank_dict[k][y] = x
                   except KeyError:
                       pass
                   except:
                       raise
        
        return tax_w_rank_dict

        # l = 'Lineage=Root;rootrank;Bacteria;domain;"Actinobacteria";phylum;Actinobacteria;class;Acidimicrobidae;subclass;Acidimicrobiales;order;"Acidimicrobineae";suborder;Acidimicrobiaceae;family;Ferrimicrobium;genus'
        # l_arr = l.split(";")
        # my_dict['S001416053'][l_arr[3]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[5]] = l_arr[4] 
        # my_dict['S001416053'][l_arr[7]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[9]] = l_arr[2] 
        # my_dict['S001416053'][l_arr[3]] = l_arr[2] 

    def get_mapped_dict(self, arr):
        m_d = {}
        for line in arr:
            # print "line = %s" % line
            
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


    def print_new_tax_map(self, tax_w_rank_dict):
        # for k1, v1 in self.taxmap_dict.items():
        #     print "self.taxmap_dict k1 = %s, v1 = %s" % (k1, v1)
        
        for k, v in tax_w_rank_dict.items():
            # print ":" * 8
            # print "k =  %s, v = %s" % (k, v)
            for k1, v1 in self.taxmap_dict.items():
                if k1 == k:
                    # print "k1 = %s" % k1
                    orig_string = "\t".join(v1).strip()
                    try:
                        print "%s\t%s\t%s" % (k, orig_string, v["family"])
                    except KeyError:
                        print "%s\t%s\t%s" % (k, orig_string, "")
                    except:
                        raise

    def make_current_string(k, v, v1):
        orig_string = "\t".join(v1).strip()
        try:
            return "%s\t%s\t%s" % (k, orig_string, v["family"])
        except KeyError:
            return "%s\t%s\t%s" % (k, orig_string, "")
        except:
            raise

    def make_new_tax_map(self, tax_w_rank_dict):
        for k, v in tax_w_rank_dict.items():
            for k1, v1 in self.taxmap_dict.items():
                if k1 == k:
                    # cur_str = make_current_string(k, v, v1)
                    # print "k1 = %s" % k1
                    self.new_map_arr.append(make_current_string(k, v, v1))

    def write_to_file(self):
        pass
                     
        


if __name__ == '__main__':
    spingo_tax = Spingo_Taxonomy()

    spingo_tax.tax_map_file_content = spingo_tax.get_file_content(spingo_tax.tax_map_filename)
    # print spingo_tax.tax_map_file_content[0]
    spingo_tax.get_taxmap_dict()
    # arc_maped_taxonomy_arr  = spingo_tax.get_maped_taxonomy_arr(spingo_tax.arc_filename)
    # bact_maped_taxonomy_arr = spingo_tax.get_maped_taxonomy_arr(spingo_tax.bact_filename)

    spingo_tax.arc_file_content  = spingo_tax.get_file_content(spingo_tax.arc_filename)
    spingo_tax.bact_file_content = spingo_tax.get_file_content(spingo_tax.bact_filename)

    # print "spingo_tax.bact_file_content[0]"
    # print spingo_tax.bact_file_content[0]

    test = spingo_tax.bact_file_content[0:3]
    # a = spingo_tax.get_mapped_dict(spingo_tax.bact_file_content)
    a = spingo_tax.get_mapped_dict(spingo_tax.bact_file_content)
    tax_w_rank_dict = spingo_tax.make_taxonomy_by_rank(a)
    # for k, v in a.items():
    #     print k, v
        
    # for k, v in a.items():
    #     # spingo_tax.make_taxonomy_by_rank(v[1])
    #     # print v[1]
    #     for x, y in spingo_tax.pairwise(v[1]):
    #        print "%s: %s" % (y, x)
    #     
    
    # for k, v in tax_w_rank_dict.items():
    #     print ":" * 8
    #     print "k =  %s, v = %s" % (k, v)
        # k =  S000871964, v = {'domain': 'Bacteria', 'family': 'Acidimicrobiaceae', 'subclass': 'Acidimicrobidae', 'order': 'Acidimicrobiales', 'phylum': '"Actinobacteria"', 'suborder': '"Acidimicrobineae"', 'genus': 'Acidimicrobium', 'class': 'Actinobacteria'}


    spingo_tax.print_new_tax_map(tax_w_rank_dict)
    