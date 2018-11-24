#!/bin/sh
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
            echo -n " " ${matrix[$i,$j]} " "
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
    for ((j=0;j<num_columns;j++)) 
    do
	for ((i=0;i<num_rows;i++)) 
	do
	    for ((k=i;k>=1;k--))
	    do
		let "t = $k-1"
		if [ ${matrix[$t,$j]} = "0" ]; then
		    let "matrix[$t,$j] += ${matrix[$k,$j]}"
		    let "matrix[$k,$j] = 0"
		else if [ ${matrix[$k,$j]} = ${matrix[$t,$j]} ]; then
		    let "matrix[$t,$j] *= 2"
		    let "matrix[$k,$j] = 0"
		    break
		     fi
		fi
	    done
	done
    done
}

move_right () {
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=num_columns-1;j>=0;j--)) 
	do
	    for ((k=j;k<num_columns-1;k++))
	    do
		let "t = $k+1"
		if [ ${matrix[$i,$t]} = "0" ]; then
		    let "matrix[$i,$t] = ${matrix[$i,$k]}"
		    let "matrix[$i,$k] = 0"
		else if [ ${matrix[$i,$k]} = ${matrix[$i,$t]} ]; then
		    let "matrix[$i,$t] *= 2"
		    let "matrix[$i,$k] = 0"
		    break
		     fi
		fi
	    done
	done
    done
}

move_down () {
    for ((j=0;j<num_columns;j++)) 
    do
	for ((i=num_rows-1;i>=0;i--)) 
	do
	    for ((k=i;k<num_rows-1;k++))
	    do
		let "t = $k+1"
		if [ ${matrix[$t,$j]} = "0" ]; then
		    let "matrix[$t,$j] += ${matrix[$k,$j]}"
		    let "matrix[$k,$j] = 0"
		else if [ ${matrix[$k,$j]} = ${matrix[$t,$j]} ]; then
		    let "matrix[$t,$j] *= 2"
		    let "matrix[$k,$j] = 0"
		    break
		     fi
		fi
	    done
	done
    done
}

move_left () {
    for ((i=0;i<num_rows;i++)) 
    do
	for ((j=0;j<num_columns;j++)) 
	do
	    for ((k=j;k>=1;k--))
	    do
		let "t = $k-1"
		if [ ${matrix[$i,$t]} = "0" ]; then
		    let "matrix[$i,$t] = ${matrix[$i,$k]}"
		    let "matrix[$i,$k] = 0"
		else if [ ${matrix[$i,$k]} = ${matrix[$i,$t]} ]; then
		    let "matrix[$i,$t] *= 2"
		    let "matrix[$i,$k] = 0"
		    break
		     fi
		fi
	    done
	done
    done
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

while [ true ]
do
    draw
    read -n 1 arrow
    if [ $arrow = "w" ]; then
	move_up
	insert_random
    else 
	if [ $arrow = "d" ]; then
	     move_right
	     insert_random
	else
	    if [ $arrow = "s" ]; then
		move_down
		insert_random		
	    else
		if [ $arrow = "a" ]; then
		    move_left
		    insert_random		   
		fi
	    fi
	fi
    fi 
    
done

