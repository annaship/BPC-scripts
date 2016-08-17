"""
Get more levels from
release11_2_Archaea_unaligned.fa.gz
release11_2_Bacteria_unaligned.fa.gz
and make taxonomy.map

"""
import gzip

class Spingo_Taxonomy():
    def __init__(self):
        self.arc_filename = "/users/ashipunova/spingo/database/release11_2_Archaea_unaligned.fa.gz"
        self.bact_filename = "/users/ashipunova/spingo/database/release11_2_Bacteria_unaligned.fa.gz"
        self.tax_map_filename = "/users/ashipunova/spingo/database/taxonomy.map"
        self.tax_map_file_content = []

    def get_tax_map_file_content(self):
        with open(self.tax_map_filename, 'rb') as f:
            self.tax_map_file_content = f.readlines()

if __name__ == '__main__':
    spingo_tax = Spingo_Taxonomy()
    spingo_tax.get_tax_map_file_content()
    print spingo_tax.tax_map_file_content[0]
