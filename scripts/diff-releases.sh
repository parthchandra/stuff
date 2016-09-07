#!/bin/bash

#
# Example:
# diff-releases.sh 1.6.0 drill-1.6.0-mapr-r1 master  > ~/work/temp/diff_releases__1.6.0__drill-1.6.0-mapr-r1__master.csv 
#



base_branch=$1
mapr_branch=$2
apache_branch=$3
outputType=${4:-"csv"}

work_dir=~/work/drill
diff_dir=~/work/drill-diffs

cwd=`pwd`
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dtstamp=`date +%Y%m%d-%H%M%S`
commit_diff_dir=${diff_dir}/${dtstamp}
mkdir -p ${commit_diff_dir}

function levenshtein {
if [ "$#" -ne "2" ]; then
    echo "Usage: $0 word1 word2" >&2
elif [ "${#1}" -lt "${#2}" ]; then
    levenshtein "$2" "$1"
else
    local str1len=$((${#1}))
    local str2len=$((${#2}))
    local d i j
    for i in $(seq 0 $(((str1len+1)*(str2len+1)))); do
        d[i]=0
    done
    for i in $(seq 0 $((str1len)));	do
        d[$((i+0*str1len))]=$i
    done
    for j in $(seq 0 $((str2len)));	do
        d[$((0+j*(str1len+1)))]=$j
    done

    for j in $(seq 1 $((str2len))); do
        for i in $(seq 1 $((str1len))); do
            [ "${1:i-1:1}" = "${2:j-1:1}" ] && local cost=0 || local cost=1
            local del=$((d[(i-1)+str1len*j]+1))
            local ins=$((d[i+str1len*(j-1)]+1))
            local alt=$((d[(i-1)+str1len*(j-1)]+cost))
            d[i+str1len*j]=$(echo -e "$del\n$ins\n$alt" | sort -n | head -1)
        done
    done
    echo ${d[str1len+str1len*(str2len)]}
fi
}


function runCmd(){
# run the command, send output to out file
"$@" 
if [ $? -ne 0 ]; then
        echo FAILED to run $1 
        exit 1
fi
}

function diffFind(){
    mapr_commit=$1
    mapr_comment=$2
    apache_commit=$3
    apache_comment=$4

    # matches =>
    #    0 if no match
    #    1 if Commit id matches
    #    2 if DRILL JIRA matches. 
    #    3 if DRILL JIRA matches but there are diffs
    #    4 if Comment is similar
    #    5 if Comment is similar but there are diffs
    local matches=0
    
    #git diff ${mapr_commit} ${apache_commit}
    #if [ $? - ne 0 ]; then
    #    echo "${mapr_commit} ${mapr_comment} ||<==>|| ${apache_commit} ${apache_comment} "
    #fi

    #Check if commit id matches
    if [ ${mapr_commit} == ${apache_commit} ]; then
        matches=1
        echo "${matches}"
        return
    fi

    #
    # Compare the comments
    #
    # In the comments, replace space with newline
    # Sort
    # compare and print only those lines (i.e words) that are in both.
    # if more than 90% ofthe words match, then the comments are (nearly) the same

    mapr_comment_words=`tr ' ' '\n' <<< ${mapr_comment} | sort`
    apache_comment_words=`tr ' ' '\n' <<< ${apache_comment} | sort`
    nCommonWords=`comm -12 <(tr ' ' '\n' <<<${mapr_comment} | sort) <( tr ' ' '\n' <<<${apache_comment} | sort ) | wc -l` 
    nMaprWords=`echo ${mapr_comment_words} | wc -w`
    nApacheWords=`echo  ${apache_comment_words} | wc -w`
    nWordMatchPercent=$( echo "scale=2; ($nCommonWords) / $nMaprWords" | bc )
    if [ $(echo "scale=2; $nWordMatchPercent > 0.89" | bc) -eq 1 ]; then
        matches=4
        diff -u <( git show ${apache_commit} ) <( git show ${mapr_commit} ) > ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.txt
        gitDiff=$?
        if (( ${gitDiff} != 0 )); then
            cat ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.txt | diff2html.py > ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.html 
            matches=5
        fi
        echo "${matches}"
        return
    fi

    #Find the pattern DRILL-NNNN: and compare 
    JIRA=""
    mapr_JIRA=" "
    apache_JIRA=""
    if [[ "${mapr_comment}" =~ (DRILL-[0-9]{4}) ]]; then
        mapr_JIRA="${BASH_REMATCH[1]}"
    fi
    if [[ "${apache_comment}" =~ (DRILL-[0-9]{4}) ]]; then
        apache_JIRA="${BASH_REMATCH[1]}"
    fi

    if [ "${mapr_JIRA}" = "${apache_JIRA}" ]; then
        matches=2
        diff -u <( git show ${apache_commit} ) <( git show ${mapr_commit} ) > ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.txt
        gitDiff=$?
        if (( ${gitDiff} != 0 )); then
            matches=3
            cat ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.txt | diff2html.py > ${commit_diff_dir}/diff-${apache_commit}-${mapr_commit}.diff.html 
        fi
        echo "${matches}"
        return
    fi
    #Do not use this. Takes too much time (several minutes per pair of strings)
    #editDistance=`levenshtein "${mapr_comment}" "${apache_comment}"`
    #echo "${editDistance} ===> ${mapr_commit} ${mapr_comment} ||<==>|| ${apache_commit} ${apache_comment} "

    echo "${matches}"
    return
}

function printOut(){
found=$1
mapr_commit=$2
mapr_author=$3
mapr_comment=$4
apache_commit=$5
apache_comment=$6
diff_text=${7:-""}

    if [ "$outputType" = "csv" ]; then
        doc_begin=""
        doc_end=""
        rec_begin=""
        rec_end=""
        sep_begin="\""
        sep_end="\","
    else
        doc_begin=""
        doc_end=""
        rec_begin="<tr>"
        rec_end="</tr>"
        sep_begin="<td>"
        sep_end="</td>"
    fi

case ${found} in 
    0)
        statusStr="NOT_FOUND"
        foundStr="No corresponding commit found in the Apache branch"
        ;;
    1)
        statusStr="COMMITTED"
        foundStr="Commit matches in the Apache branch"
        ;;
    2)
        statusStr="COMMITTED"
        foundStr="Found a commit with the same Drill JIRA in the Apache branch (there are no differences in the commits)"
        ;;
    3)
        statusStr="COMMITTED_WITH_DIFFS"
        foundStr="Found a commit with the same Drill JIRA in the Apache branch (there are differences in the commits)"
        ;;
    4)
        statusStr="COMMITTED"
        foundStr="Found a commit with a matching commit message in the Apache branch (there are no differences in the commits)"
        ;;
    5)
        statusStr="COMMITTED_WITH_DIFFS"
        foundStr="Found a commit with a matching commit message in the Apache branch (there are differences in the commits)"
        ;;
    *)
        statusStr="UNKNOWN"
        foundStr="Unknown status"
        ;;
esac

    if [ "$rec_begin" != "" ]; then
        echo "${rec_begin}"
    fi
        echo \
${sep_begin}${statusStr}${sep_end}\
${sep_begin}${mapr_commit}${sep_end}\
${sep_begin}${mapr_author}${sep_end}\
${sep_begin}${mapr_comment}${sep_end}\
${sep_begin}${apache_commit}${sep_end}\
${sep_begin}${apache_comment}${sep_end}\
${sep_begin}${foundStr}${sep_end}\


    if [ "$rec_end" != "" ]; then
        echo "${rec_end}"
    fi

}

function printHeader(){
if [ "$outputType" = "csv" ]; then
    echo "Status,Mapr Commit,Author,Mapr Comment,Apache Commit,Apache Comment,Notes,Diff"
else
    echo '<!DOCTYPE html>'
    echo '<html>'
    echo '<head>'
    echo '<style>'
    echo 'table {'
    echo '    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;'
    echo '    border-collapse: collapse;'
    echo '    width: 100%;'
    echo '}'
    echo 'td, th {'
    echo '    border: 1px solid #ddd;'
    echo '    text-align: left;'
    echo '    padding: 8px;'
    echo '}'
    echo 'tr:nth-child(even){background-color: #f2f2f2}'
    echo 'tr:hover {background-color: #ddd;}'
    echo 'th {'
    echo '    padding-top: 12px;'
    echo '    padding-bottom: 12px;'
    echo '    background-color: #4CAF50;'
    echo '    color: white;'
    echo '}'
    echo '</style>'
    echo '</head>'
    echo '<body>'

    echo '<table style="width:100%">'
    echo '  <tr>'
    echo '    <th>Status</th>'
    echo '    <th>Mapr Commit</th>		'
    echo '    <th>Author</th>'
    echo '    <th>Mapr Comment</th>'
    echo '    <th>Apache Commit</th>		'
    echo '    <th>Apache Comment</th>'
    echo '    <th>Notes</th>'
    echo '    <th>Diff</th>'
    echo '  </tr>'
fi
}

function printFooter(){
if [ "$outputType" != "csv" ]; then
    echo "</table>"
    echo '</body>'
    echo '</html>'
fi
}

function diffTree(){
    printHeader
    while read p; do
        mapr_commit=`echo $p | cut -c 1-40  ` 
        mapr_author=`echo $p | cut -c 42- |cut -d , -f 1 `
        mapr_comment=`echo $p | cut -c 42- | cut  -d , -f 2- `
        found=0
        #echo $p
        while read q; do
            apache_commit=`echo $q | cut -c 1-40`
            apache_comment=`echo $q | cut -c 42- | cut  -d , -f 2- `
            #diffFind ${mapr_commit} "${mapr_comment}" ${apache_commit} "${apache_comment}"
            found=$(diffFind ${mapr_commit} "${mapr_comment}" ${apache_commit} "${apache_comment}")
            if (( ${found} != 0 )); then
                break
            fi
            apache_commit=""
            apache_comment=""
        done < ${diff_dir}/new-${apache_branch}.txt
        printOut "${found}" "${mapr_commit}" "${mapr_author}" "${mapr_comment}" "${apache_commit}" "${apache_comment}" "${diff_text}"
        mapr_commit=""
        mapr_author=""
        mapr_comment=""
    done < ${diff_dir}/new-${mapr_branch}.txt
    printFooter
}

function getChanges(){
    runCmd git log --pretty=format:"%H,%aN,%s" Mapr/${apache_branch} ^Apache/${base_branch} --no-merges > ${diff_dir}/new-${apache_branch}.txt
    runCmd git log --pretty=format:"%H,%aN,%s" Mapr/${mapr_branch} ^Apache/${base_branch} --no-merges > ${diff_dir}/new-${mapr_branch}.txt
}

function main(){
   cd ${work_dir}
   getChanges 
   diffTree
}

main 
