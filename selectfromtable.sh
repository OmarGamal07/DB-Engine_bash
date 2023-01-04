 #!/bin/bash

 # 1)if need display all data
 # 2)select row by condition
 # 3)check column exist
 # 4)check if string cant do operation >,<
 # 5)check operation
 # 6)select column 
 function seclectfromtable(){
    select selectchoise in all byrow bycol back
    do
        case $REPLY in  
            all)
                cat $1;
                . selectfromtable.sh;
            ;;
            back)
              . tableDB.sh;
            ;;
            byrow)
                 echo "Enter name column need display";
            colNames=($(awk -F: '{print $1}' $1.metadata));
                 checkcolFlag=1;
                
                for i in "${!colNames[@]}"
                 do 
                    count=$(($i+1));
                    echo "$count ${colNames[$i]}"  
                done

                read -p "Enter check column name: " checkcolName;
     

                for j in "${!colNames[@]}"
                do 

                    if [[ $checkcolName == "${colNames[$j]}" ]]; then
                        checkcolFlag=0   #true
                        checkcolNum=$(($j));  #column-Number
                    fi  
                done
        
       
                if [[ $checkcolFlag == 1 ]];then
                    echo "column not found";
                    return;
                fi
                 #check data type because if it string cant use it in >,< operation
                coltype=($(awk -F: '{print $3}' $1.metadata));
                typeFlag=0 #true
                #echo "${coltype[$checkcolNum]}";
                if [[ ${coltype[$checkcolNum]} == "string" ]];then

                    typeFlag=1; #false
                fi
                
                 if [[ $checkcolFlag == 0 ]];then
                read -p "Enter value check" checkvalue;
                select checkchoice in equal  greater smaller
                do
                    case $REPLY in
                        equal)
                            echo "equal";
                            echo "select by row is";
                           linesData=($(awk -F: '{print $0}' $1));
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read  -a columndata <<< "${linesData[i]}";
                                
                                if [[ $checkvalue == ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                            . selectfromtable.sh;
               ;;
               greater)
                 echo "gt";
                        if [[ $typeFlag == 0 ]];then
                            echo "greater";
                           linesData=($(awk -F: '{print $0}' $1));
                           echo "select by row is";
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read  -a columndata <<< "${linesData[i]}";
                                
                                if [[ $checkvalue > ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                        else
                            echo "sorry, this check need number";
                        fi  
                        . selectfromtable.sh;
               ;;
               smaller)
                echo "lt";
                        if [[ $typeFlag == 0 ]];then
                             echo "smaller";
                           linesData=($(awk -F: '{print $0}' $1));
                           echo "select by row is";
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read  -a columndata <<< "${linesData[i]}";
                                
                                if [[ $checkvalue < ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                        else
                            echo "sorry, this check need number";
                        fi 
                        . selectfromtable.sh;
                esac
                done   
                else
                   echo "sorry, this check need number";
            fi        
            . selectfromtable.sh;
            ;;
            bycol)
                
                 colNames=($(awk -F: '{print $1}' $1.metadata));
                 checkcolFlag=1;
                echo "Enter name column need display ";
                for i in "${!colNames[@]}"
                 do 
                    count=$(($i+1));
                    echo "$count ${colNames[$i]}"  
                done

                read -p "Enter check column name: " checkcolName;
     

                for j in "${!colNames[@]}"
                do 

                    if [[ $checkcolName == "${colNames[$j]}" ]]; then
                        checkcolFlag=0   #true
                        checkcolNum=$(($j+1));  #column-Number
                    fi  
                done
        
       
                if [[ $checkcolFlag == 1 ]];then
                    echo "column not found";
                    return;
                fi

                if [[ $checkcolFlag == 0 ]];then
                    awk -v colcheck="$checkcolNum" -F: '
                    {
                        print $colcheck
                    }
                    ' $1
                else
                   echo "sorry, this check not found";
                fi 
                . selectfromtable.sh;
            ;;
            
            *)
            echo"command not found";
        esac
    done
    . selectfromtable.sh;
}
 
 
 read -p "Enter Name of table : " name
            echo "enter name table"
          if [ -f $name ] ; then 
                  seclectfromtable $name;
                  
              else 
               echo "sorry this table not found"
              fi