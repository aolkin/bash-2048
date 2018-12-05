#!/usr/bin/env bash

if [ -z "$BASH_VERSINFO" ]; then
    echo "This game only supports the bash shell."
    exit 1
fi
if [ "$BASH_VERSINFO" -lt 4 ]; then
    echo "This game only supports bash v4 and newer."
    exit 1
fi

declare -A matrix
num_rows=4
num_columns=4
SAVE_FILE=~/.2048

function write_save {
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=0;j<num_columns;j++)) 
	do
            echo -n ${matrix[$i,$j]} " "
	done
	echo ""
    done
}

function read_save {
    i=0
    IFS=$'\n'
    for line in $(cat "$1"); do
	j=0
	IFS=' '
	for val in $line; do
	    matrix[$i,$j]=$val
	    let "j = $j+1"
	done
	let "i = $i+1"
    done
    unset IFS
}

draw () {
    if [ "$1" != "noclear" ]; then
	clear
    fi
    for ((i=0;i<num_rows;i++)) 
    do
	echo ""
	for ((j=0;j<num_columns;j++)) 
	do
	    color="\e[39m"
	    case ${matrix[$i,$j]} in
		2) color="\e[31m" ;;
		4) color="\e[32m" ;;
		8) color="\e[34m" ;;
		16) color="\e[35m" ;;
		32) color="\e[36m" ;;
		64) color="\e[91m" ;;
		128) color="\e[92m" ;;
		256) color="\e[94m" ;;
		512) color="\e[95m" ;;
		1024) color="\e[97m" ;;
		2048) color="\e[37m" ;;
		4098) color="\e[33m" ;;
		8192) color="\e[93m" ;;
	    esac
            echo -ne " $color" ${matrix[$i,$j]} "\t\e[39m"
	done
	echo ""
	echo ""
    done
}

function move_horizontal {
    if [ ${matrix[$1,$2]} = "0" ]; then
	if [ -z "$4" ]; then
	    let "matrix[$1,$2] = ${matrix[$1,$3]}"
	    let "matrix[$1,$3] = 0"
	fi
	return 1
    fi
    if [ "$5" -eq 1 -a ${matrix[$1,$3]} = ${matrix[$1,$2]} ]; then
	if [ -z "$4" ]; then
	    let "matrix[$1,$2] *= 2"
	    let "matrix[$1,$3] = 0"
	fi
	return 2
    fi
    return 0
}

function move_vertical {
    if [ ${matrix[$1,$2]} = "0" ]; then
	if [ -z "$4" ]; then
	    let "matrix[$1,$2] += ${matrix[$3,$2]}"
	    let "matrix[$3,$2] = 0"
	fi
	return 1
    fi
    if [ "$5" -eq 1 -a ${matrix[$3,$2]} = ${matrix[$1,$2]} ]; then
	if [ -z "$4" ]; then
	    let "matrix[$1,$2] *= 2"
	    let "matrix[$3,$2] = 0"
	fi
	return 2
    fi
    return 0
}

move_up () {
    moved=1
    lastmoved=1
    while true; do
	for ((j=0;j<num_columns;j++)) 
	do
	    for ((i=0;i<num_rows;i++)) 
	    do
		for ((k=i;k>=1;k--))
		do
		    if [ ${matrix[$k,$j]} != "0" ]; then
			let "t = $k-1"
			move_vertical $t $j $k "$1" $lastmoved
			case $? in
			    1) moved=0 ;;
			    2) moved=0; break 2 ;;
			esac
		    fi
		done
	    done
	done
	if [ $moved -eq 1 ]; then
	    return $lastmoved
	fi
	lastmoved=$moved
	moved=1
    done
}

move_down () {
    moved=1
    lastmoved=1
    while true; do
	for ((j=0;j<num_columns;j++)) 
	do
	    for ((i=num_rows-1;i>=0;i--)) 
	    do
		for ((k=i;k<num_rows-1;k++))
		do
		    if [ ${matrix[$k,$j]} != "0" ]; then
			old=${matrix[$k,$j]}
			let "t = $k+1"
			move_vertical $t $j $k "$1" $lastmoved
			case $? in
			    0) ;;
			    1) moved=0 ;;
			    2) moved=0; break 2 ;;
			esac
		    fi
		done
	    done
	done
	if [ $moved -eq 1 ]; then
	    return $lastmoved
	fi
	lastmoved=$moved
	moved=1
    done
}

move_right () {
    moved=1
    lastmoved=1
    while true; do
	for ((i=0;i<num_rows;i++)) 
	do
	    for ((j=num_columns-1;j>=0;j--)) 
	    do
		for ((k=j;k<num_columns-1;k++))
		do
		if [ ${matrix[$i,$k]} != "0" ]; then
		    let "t = $k+1"
		    move_horizontal $i $t $k "$1" $lastmoved
		    case $? in
			1) moved=0 ;;
			2) moved=0; break 2 ;;
		    esac
		fi
		done
	    done
	done
	if [ $moved -eq 1 ]; then
	    echo $lastmoved
	    return $lastmoved
	fi
	lastmoved=$moved
	moved=1
    done
}

move_left () {
    moved=1
    lastmoved=1
    while true; do
	for ((i=0;i<num_rows;i++)) 
	do
	    for ((j=0;j<num_columns;j++)) 
	    do
		for ((k=j;k>=1;k--))
		do
		    if [ ${matrix[$i,$k]} != "0" ]; then
			let "t = $k-1"
			move_horizontal $i $t $k "$1" $lastmoved
			case $? in
			    1) moved=0 ;;
			    2) moved=0; break 2 ;;
			esac
		    fi
		done
	    done
	done
	if [ $moved -eq 1 ]; then
	    return $lastmoved
	fi
	lastmoved=$moved
	moved=1
    done
}

function new_board {
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
}

function getinput {
    escape_char=$(printf "\u1b")
    read -rsn1 mode # get 1 character
    if [[ $mode == $escape_char ]]; then
	read -rsn2 -t 0.1 mode # read 2 more chars
	case $mode in
	    '[A') return 1 ;;
	    '[B') return 2 ;;
	    '[C') return 3 ;;
	    '[D') return 4 ;;
	    '') return 9 ;;
	esac
    else
	case $mode in
	    'w') return 1 ;;
	    's') return 2 ;;
	    'd') return 3 ;;
	    'a') return 4 ;;
	    'n') return 8 ;;
	    'q') return 9 ;;
	esac
    fi
    return 0
}

let "insertion_target = (1 << ($num_columns * $num_rows)) - 1"
insert_random () {
    tried=0
    ((i=$RANDOM%$num_rows))
    ((j=$RANDOM%$num_columns))
    while [ ${matrix[$i,$j]} -ne "0" -a $tried -ne $insertion_target ]; do
	let "num = $i * $num_columns + j"
	let "index = 1 << $num"
	let "tried = $tried | $index"
	#echo -e "$num\t$index\t$tried\t$insertion_target"
	((i=$RANDOM%$num_rows))
	((j=$RANDOM%$num_columns))
    done
    ((rand=$RANDOM%4))
    if [ $rand -lt 3 ]; then
	matrix[$i,$j]=2
    else
	matrix[$i,$j]=4
    fi
    let "res = $tried != $insertion_target"
    return $res
}

function check_loss {
    loss=0
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=0;j<num_columns;j++)) 
	do
	    if [ ${matrix[$i,$j]} -eq 0 ]; then    
		loss=1
	    fi
	done
    done
    return $loss
}

function loss {
    echo "  You lose!"
    echo "  (Press any key to start a new game or q to quit)"
    getinput
    if [ $? -eq 9 ]; then
	rm -f $SAVE_FILE
	exit
    fi
    new_board
    draw
}

function save_and_exit {
    write_save > $SAVE_FILE
    exit
}

trap save_and_exit INT

if [ -f $SAVE_FILE ]; then
    read_save $SAVE_FILE
else
    new_board
fi

draw

trials=0
loops=0

while [ true ]
do
    getinput
    dir=$?
    moved=1
    let "loops = $loops + 1"
    case $dir in
	1)
	    move_up; moved=$?
	    if [ $moved -ne 0 ]; then
		let "trials = $trials | 1"
	    fi ;;
	2)
	    move_down; moved=$?
	    if [ $moved -ne 0 ]; then
		let "trials = $trials | 2"
	    fi ;;
	3)
	    move_right; moved=$?
	    if [ $moved -ne 0 ]; then
		let "trials = $trials | 4"
	    fi ;;
	4)
	    move_left; moved=$?
	    if [ $moved -ne 0 ]; then
		let "trials = $trials | 8"
	    fi ;;
	8) new_board ;;
	9) write_save > $SAVE_FILE; exit ;;
    esac
    draw
    if [ $moved -eq 0 ]; then
	trials=0
	loops=0
	if insert_random; then
	    loss "unable to insert"
	else
	    draw
	fi
    fi
    if [ $trials -eq 15 ]; then
	if check_loss; then
	    loss "unable to move"
	else
	    echo "  Something broke?"
	    read -sn 1
	fi
    fi
    if [ $loops -gt 4 ]; then
	echo "  Try moving in a different direction."
	echo "  If you try and fail to move in any direction, you lose."
    fi
done
