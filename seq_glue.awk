#run as: awk -f seq_glue.awk <input_file
{if ($0 ~ /^>/) {printf "\n%s\n", $0} else {printf "%s",$0}} END {print ""}
