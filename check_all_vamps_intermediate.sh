#!/bin/bash
module load mysql/5.6.12; 
rm check_all_vamps_intermediate.log

echo "SELECT * FROM new_class_intermediate a RIGHT JOIN new_class b USING(class) WHERE a.class_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_class_intermediate a RIGHT JOIN new_class b USING(class) WHERE a.class_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_contact_intermediate a RIGHT JOIN new_contact b USING(contact) WHERE a.contact_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_contact_intermediate a RIGHT JOIN new_contact b USING(contact) WHERE a.contact_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_dataset_intermediate a RIGHT JOIN new_dataset b USING(dataset) WHERE a.dataset_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_dataset_intermediate a RIGHT JOIN new_dataset b USING(dataset) WHERE a.dataset_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_family_intermediate a RIGHT JOIN new_family b USING(family) WHERE a.family_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_family_intermediate a RIGHT JOIN new_family b USING(family) WHERE a.family_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_genus_intermediate a RIGHT JOIN new_genus b USING(genus) WHERE a.genus_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_genus_intermediate a RIGHT JOIN new_genus b USING(genus) WHERE a.genus_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_orderx_intermediate a RIGHT JOIN new_orderx b USING(\`order\`) WHERE a.orderx_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_orderx_intermediate a RIGHT JOIN new_orderx b USING(`order`) WHERE a.orderx_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_phylum_intermediate a RIGHT JOIN new_phylum b USING(phylum) WHERE a.phylum_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_phylum_intermediate a RIGHT JOIN new_phylum b USING(phylum) WHERE a.phylum_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_project_dataset_intermediate a RIGHT JOIN new_project_dataset b USING(project_dataset) WHERE a.project_dataset_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_project_dataset_intermediate a RIGHT JOIN new_project_dataset b USING(project_dataset) WHERE a.project_dataset_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_project_intermediate a RIGHT JOIN new_project b USING(project) WHERE a.project_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_project_intermediate a RIGHT JOIN new_project b USING(project) WHERE a.project_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_species_intermediate a RIGHT JOIN new_species b USING(species) WHERE a.species_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_species_intermediate a RIGHT JOIN new_species b USING(species) WHERE a.species_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_strain_intermediate a RIGHT JOIN new_strain b USING(strain) WHERE a.strain_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_strain_intermediate a RIGHT JOIN new_strain b USING(strain) WHERE a.strain_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT count(*) FROM new_summed_data_cube_intermediate a RIGHT JOIN new_summed_data_cube b USING(taxon_string_id,knt,frequency,dataset_count,rank_number,project_id,dataset_id,project_dataset_id,classifier) WHERE a.summed_data_cube_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT count(*) FROM new_summed_data_cube_intermediate a RIGHT JOIN new_summed_data_cube b USING(taxon_string_id,knt,frequency,dataset_count,rank_number,project_id,dataset_id,project_dataset_id,classifier) WHERE a.summed_data_cube_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_superkingdom_intermediate a RIGHT JOIN new_superkingdom b USING(superkingdom) WHERE a.superkingdom_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_superkingdom_intermediate a RIGHT JOIN new_superkingdom b USING(superkingdom) WHERE a.superkingdom_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_taxon_string_intermediate a RIGHT JOIN new_taxon_string b USING(taxon_string) WHERE a.taxon_string_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_taxon_string_intermediate a RIGHT JOIN new_taxon_string b USING(taxon_string) WHERE a.taxon_string_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_taxonomy_intermediate a RIGHT JOIN new_taxonomy b USING(taxon_string_id,superkingdom_id,phylum_id,class_id,orderx_id,family_id,genus_id,species_id,strain_id,rank_id,classifier) WHERE a.taxonomy_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_taxonomy_intermediate a RIGHT JOIN new_taxonomy b USING(taxon_string_id,superkingdom_id,phylum_id,class_id,orderx_id,family_id,genus_id,species_id,strain_id,rank_id,classifier) WHERE a.taxonomy_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_user_contact_intermediate a RIGHT JOIN new_user_contact b USING(contact_id,user_id) WHERE a.user_contact_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_user_contact_intermediate a RIGHT JOIN new_user_contact b USING(contact_id,user_id) WHERE a.user_contact_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM new_user_intermediate a RIGHT JOIN new_user b USING(user) WHERE a.user_id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM new_user_intermediate a RIGHT JOIN new_user b USING(user) WHERE a.user_id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT count(*) FROM vamps_data_cube_intermediate a RIGHT JOIN vamps_data_cube b USING(project,dataset,taxon_string) WHERE a.id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT count(*) FROM vamps_data_cube_intermediate a RIGHT JOIN vamps_data_cube b USING(project,dataset,taxon_string) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT count(*) FROM vamps_junk_data_cube_intermediate a RIGHT JOIN vamps_junk_data_cube b USING(project_dataset,taxon_string) WHERE a.id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT count(*) FROM vamps_junk_data_cube_intermediate a RIGHT JOIN vamps_junk_data_cube b USING(project_dataset,taxon_string) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM vamps_projects_datasets_intermediate a RIGHT JOIN vamps_projects_datasets b USING(project,dataset) WHERE a.id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM vamps_projects_datasets_intermediate a RIGHT JOIN vamps_projects_datasets b USING(project,dataset) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM vamps_projects_info_intermediate a RIGHT JOIN vamps_projects_info b USING(project_name,contact,email,institution) WHERE a.id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM vamps_projects_info_intermediate a RIGHT JOIN vamps_projects_info b USING(project_name,contact,email,institution) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

echo "SELECT * FROM vamps_taxonomy_intermediate a RIGHT JOIN vamps_taxonomy b USING(taxon_string) WHERE a.id IS NULL;"
time mysql -nvv -h vampsdb vamps -e 'SELECT * FROM vamps_taxonomy_intermediate a RIGHT JOIN vamps_taxonomy b USING(taxon_string) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

#too slow
#echo "SELECT count(*) FROM vamps_sequences_intermediate a RIGHT JOIN vamps_sequences b USING(rep_id) WHERE a.id IS NULL;"
#time mysql -nvv -h vampsdb vamps -e 'SELECT count(*) FROM vamps_sequences_intermediate a RIGHT JOIN vamps_sequences b USING(rep_id) WHERE a.id IS NULL;' >> check_all_vamps_intermediate.log 2>&1

