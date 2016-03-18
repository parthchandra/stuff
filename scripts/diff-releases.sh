#!/bin/bash

base_branch=$1
mapr_branch=$2
apache_branch=$3

work_dir=~/work/drill
diff_dir=~/work/drill-diffs


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
        #echo "$mapr_commit $apache_commit commits match"
        echo $matches
        return
    fi

    #TODO: Find the pattern DRILL-NNNN: and compare 

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
    #nWordDiffPercent= $(( ($nMaprWords - $ndiff) / $nMaprWords))
    nWordMatchPercent=$( echo "scale=2; ($nCommonWords) / $nMaprWords" | bc )
    #echo $nMaprWords $ndiff $nWordMatchPercent
    #if (( $nWordDiffPercent < 5 )); then
    if [ $(echo "scale=2; $nWordMatchPercent > 0.89" | bc) -eq 1 ]; then
        matches=4
        #echo "$mapr_commit $apache_commit comments match"
        git diff --exit-code $mapr_commit $apache_commit >/dev/null
        gitDiff=$?
        if (( ${gitDiff} != 0 )); then
            matches=5
        fi
    fi

    #Do not use this. Takes too much time (several minutes per pair of strings)
    #editDistance=`levenshtein "${mapr_comment}" "${apache_comment}"`
    #echo "${editDistance} ===> ${mapr_commit} ${mapr_comment} ||<==>|| ${apache_commit} ${apache_comment} "

    echo "${matches}"
    return
}

function diffTree(){
echo "Status,Mapr Commit,Author,Mapr Comment,Apache Commit,Apache Comment,Notes"
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
    done < ${diff_dir}/new-${apache_branch}.txt
    if (( $found == 0 )); then
        echo "[NOT FOUND],\"${mapr_commit}\",\"${mapr_author}\",\"${mapr_comment}\",,,No corresponding commit in the Apache branch"
    fi
    if (( $found == 1 )); then
        echo "[COMMITTED],\"${mapr_commit}\",\"${mapr_author}\",\"${mapr_comment}\",\"${apache_commit}\",,Matches in the Apache branch"
    fi
    if (( $found == 4 )); then
        echo "[COMMITTED],\"${mapr_commit}\",\"${mapr_author}\",\"${mapr_comment}\",\"${apache_commit}\",\"${apache_comment}\",Matches commit in the Apache branch"
    fi
    if (( $found == 5 )); then
        echo "[COMMITTED-WITH-DIFFS],\"${mapr_commit}\",\"${mapr_author}\",\"${mapr_comment}\",\"${apache_commit}\",\"${apache_comment}\",Matches commit in the Apache branch (there are differences in the commits)"
    fi
done < ${diff_dir}/new-${mapr_branch}.txt
}

function getChanges(){
    runCmd git log --pretty=format:"%H,%aN,%s" Apache/${apache_branch} ^Apache/${base_branch} --no-merges > ${diff_dir}/new-${apache_branch}.txt
    runCmd git log --pretty=format:"%H,%aN,%s" Mapr/${mapr_branch} ^Apache/${base_branch} --no-merges > ${diff_dir}/new-${mapr_branch}.txt
}

function main(){
   cd ${work_dir}
   getChanges 
   diffTree
}

main 
