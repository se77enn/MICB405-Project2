export KO_DIR=/projects/micb405/project1/Team4/project2/ko-files
for ko_file in $KO_DIR/*.txt; do
    s=${ko_file##*/}
    FILENAME=${s%.txt*}
    grep '\sK' $ko_file > "${FILENAME}.cleaned.txt"
done
