#!/bin/bash
declare -A matrix
num_rows=4
num_columns=4

draw () {
    clear
    for ((i=0;i<num_rows;i++)) 
    do
	echo ""
	for ((j=0;j<num_columns;j++)) 
	do
	    color="\e[39m"
	    case ${matrix[$i,$j]} in
		2) color="\e[31m" ;;
		4) color="\e[32m" ;;
		8) color="\e[33m" ;;
		16) color="\e[34m" ;;
		32) color="\e[35m" ;;
		64) color="\e[36m" ;;
		128) color="\e[37m" ;;
		256) color="\e[91m" ;;
		512) color="\e[92m" ;;
		1024) color="\e[93m" ;;
		2048) color="\e[94m" ;;
		4098) color="\e[95m" ;;
		8192) color="\e[96m" ;;
	    esac
            echo -ne " $color" ${matrix[$i,$j]} "\t\e[39m"
	done
	echo ""
	echo ""
    done
}

insert_random () {
    ((i=$RANDOM%$num_rows))
    ((j=$RANDOM%$num_columns))
    ((i=2))
    while [ ${matrix[$i,$j]} -ne "0" ]; do
	((i=$RANDOM%$num_rows))
	((j=$RANDOM%$num_columns))
    done
    ((rand=$RANDOM%4))
    if [ $rand -lt 3 ]; then
	matrix[$i,$j]=2
    else
	matrix[$i,$j]=4
    fi
}

move_up () {
    moved=1
    for ((j=0;j<num_columns;j++)) 
    do
	for ((i=0;i<num_rows;i++)) 
	do
	    for ((k=i;k>=1;k--))
	    do
		if [ ${matrix[$k,$j]} != "0" ]; then
		    let "t = $k-1"
		    if [ ${matrix[$t,$j]} = "0" ]; then
			let "matrix[$t,$j] += ${matrix[$k,$j]}"
			let "matrix[$k,$j] = 0"
			moved=0
		    else if [ ${matrix[$k,$j]} = ${matrix[$t,$j]} ]; then
			     let "matrix[$t,$j] *= 2"
			     let "matrix[$k,$j] = 0"
			     moved=0
			     break
			 fi
		    fi
		fi
	    done
	done
    done
    return $moved
}

move_right () {
    moved=1
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=num_columns-1;j>=0;j--)) 
	do
	    for ((k=j;k<num_columns-1;k++))
	    do
		if [ ${matrix[$i,$k]} != "0" ]; then
		    let "t = $k+1"
		    if [ ${matrix[$i,$t]} = "0" ]; then
			let "matrix[$i,$t] = ${matrix[$i,$k]}"
			let "matrix[$i,$k] = 0"
			moved=0
		    else if [ ${matrix[$i,$k]} = ${matrix[$i,$t]} ]; then
			     let "matrix[$i,$t] *= 2"
			     let "matrix[$i,$k] = 0"
			     moved=0
			     break
			 fi
		    fi
		fi
	    done
	done
    done
    return $moved
}

move_down () {
    moved=1
    for ((j=0;j<num_columns;j++)) 
    do
	for ((i=num_rows-1;i>=0;i--)) 
	do
	    for ((k=i;k<num_rows-1;k++))
	    do
		if [ ${matrix[$k,$j]} != "0" ]; then
		    let "t = $k+1"
		    if [ ${matrix[$t,$j]} = "0" ]; then
			let "matrix[$t,$j] += ${matrix[$k,$j]}"
			let "matrix[$k,$j] = 0"
			moved=0
		    else
			if [ ${matrix[$k,$j]} = ${matrix[$t,$j]} ]; then
			    let "matrix[$t,$j] *= 2"
			    let "matrix[$k,$j] = 0"
			    moved=0
			    break
			fi
		    fi
		fi
	    done
	done
    done
    return $moved
}

move_left () {
    moved=1
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=0;j<num_columns;j++)) 
	do
	    for ((k=j;k>=1;k--))
	    do
		if [ ${matrix[$i,$k]} != "0" ]; then
		    let "t = $k-1"
		    if [ ${matrix[$i,$t]} = "0" ]; then
			let "matrix[$i,$t] = ${matrix[$i,$k]}"
			let "matrix[$i,$k] = 0"
			moved=0
		    else if [ ${matrix[$i,$k]} = ${matrix[$i,$t]} ]; then
			     let "matrix[$i,$t] *= 2"
			     let "matrix[$i,$k] = 0"
			     moved=0
			     break
			 fi
		    fi
		fi
	    done
	done
    done
    return $moved
}

for ((i=0;i<num_rows;i++)) 
do
    for ((j=0;j<num_columns;j++)) 
    do
	((rand=$RANDOM%4))
	if [ $rand -lt 2 ]; then    
            matrix[$i,$j]=0
	else
	    if [ $rand -lt 3 ]; then
		matrix[$i,$j]=2
	    else
		matrix[$i,$j]=4
	    fi
	fi
    done
done

function getinput {
    escape_char=$(printf "\u1b")
    read -rsn1 mode # get 1 character
    if [[ $mode == $escape_char ]]; then
	read -rsn2 mode # read 2 more chars
    fi
    case $mode in
	'[A') return 1 ;;
	'w') return 1 ;;
	'[B') return 2 ;;
	's') return 2 ;;
	'[C') return 3 ;;
	'd') return 3 ;;
	'[D') return 4 ;;
	'a') return 4 ;;
	'q') return 9 ;;
    esac
    return 0
}

while [ true ]
do
    draw
    getinput
    dir=$?
    moved=1
    case $dir in
	1) move_up; moved=$? ;;
	2) move_down; moved=$? ;;
	3) move_right; moved=$? ;;
	4) move_left; moved=$? ;;
	9) exit ;;
    esac
    if [ $moved -eq 0 ]; then
	insert_random
    fi 
done

