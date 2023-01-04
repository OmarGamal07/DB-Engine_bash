 #!/bin/bash

 function deleterecord(){
     # read columns info from tableName.metadata into array
    colNames=($(awk -F: '{print $1}' $1.metadata));
    # check if need all data
    read -p "need delete all table enter y" all;
     if [[ $all == "y" || $all == "Y" ]]; then
        rm $1;
        touch $1;
        else
        colFlag=0  #false
        
         echo "Enter name column from";
        for i in "${!colNames[@]}"
         do 
           count=$(($i+1));
           echo "$count ${colNames[$i]}"  
        done
        #read column name
        read -p "Enter column name: " colName;
        for i in "${!colNames[@]}"
         do 
         #check if exist
        if [[ $colName == "${colNames[$i]}" ]]; then
        colFlag=1   #true
        colNum=$(($i));  #column-Number
        fi   
        done
        if [[ $colFlag == 0 ]];then
         echo "column not found";
         return;
        fi
         #check data type
         coltype=($(awk -F: '{print $3}' $1.metadata));
        typeFlag=1 #true
        echo "${coltype[$colNum]}";
        #if string cant 
        if [[ ${coltype[$colNum]} == "string" ]];then

            typeFlag=0; #false
        fi
         read -p "Enter value check" value;
         select checkchoice in equal  greater smaller
         do
           case $REPLY in
               equal)
                    echo "equal";
                     counterrow=0;
                   linesData=($(awk -F: '{print $0}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counterrow=$(($counterrow+1));
                        if [[ $value == ${columndata[$colNum]} ]];then
                            
                            sed -i "$counterrow"d $1; 
                            counterrow=$(($counterrow-1)); 
                            echo "${linesData[$i]} deleted";   
                        fi
                    done
                    . tableDB.sh;
               ;;
               greater)
                 echo "gt";
                 if [[ $typeFlag == 1 ]];then
                  counterrow=0;
                   linesData=($(awk -F: '{print $0}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counterrow=$(($counterrow+1));
                        if [[ $value > ${columndata[$colNum]} ]];then
                            
                            sed -i "$counterrow"d $1; 
                            counterrow=$(($counterrow-1)); 
                            echo "${linesData[$i]} deleted";   
                        fi
                    done
                    else
                    echo "sorry, this check need number";
                fi
                    . tableDB.sh;
               ;;
               smaller)
                echo "lt";
                if [[ $typeFlag == 1 ]];then
                 counterrow=0;
                   linesData=($(awk -F: '{print $0}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counterrow=$(($counterrow+1));
                        if [[ $value < ${columndata[$colNum]} ]];then
                            
                            sed -i "$counterrow"d $1; 
                            counterrow=$(($counterrow-1)); 
                            echo "${linesData[$i]} deleted";   
                        fi
                    done
                    else
                    echo "sorry, this check need number";
                fi
                    . tableDB.sh;
               ;;
               *)
                echo "operator not found,sorry" ;
           esac
         done 
        
     fi
   . tableDB.sh;
}


 
 read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  deleterecord $name;
                  
              else 
               echo "sorry this table not found"
              fi