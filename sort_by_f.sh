#!/bin/bash
FILE_TO_SORT="$1"
INDEX_FILE="$2"
TMP_FILE="$1.sorted"

while read -r LINE; do
    grep "$LINE" "$FILE_TO_SORT" >>"$TMP_FILE"
done <"$INDEX_FILE"

# mv -f "$TMP_FILE" tmp.$$

# while read -r LINE; do echo $LINE; grep $LINE $FILE_TO_SORT >>$TMP_FILE; done <$INDEX_FILE ; cat what_to_sort.sorted.txt
