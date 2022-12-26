#!/bin/bash
let flag=1; 
#echo  " $flag" ;
 read -p "enter database engine name: " name
#check if database engine exists
for element in `ls `
do
	if [[ $name == $element ]] ;then
		echo "DataBase already exists you will be in it";
		let flag=0;
		break;
	fi
done

    if [[ $flag == 1 ]];then
       mkdir ./$name;
       echo "done";
    fi
    cd ./$name;