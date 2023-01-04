 #!/bin/bash

# 1)take column need to update and vaule
# 2)check name column and value
# 3)take condition if update all or not
# 4)if not take column and value should check with them
# 5)check column check exsit
# 6)make operation =,<,>
#append in file



function updaterecord(){
    # read columns info from tableName.metadata into array
    lines=($(awk -F: '{print $1":"$2":"$3}' $1.metadata));
    errorFlag=1; #true
         echo "Enter name column need update and where from";
        for i in "${!lines[@]}"
         do 
           count=$(($i+1));
           echo "$count ${lines[$i]}"  
        done
        setvalue="";
        setcolName="";
         #read new column name and value from user
        read -p "Enter set column name: " setcolName;
        read -p "Enter value set" setvalue;
         #test flags
            nameflag=0 #false
            dataTypeFlag=1; #true
            pkFlag=1;   #true
        # loop over lines array to insert each column
        
       for i in "${!lines[@]}"
        do
            #ifs cut by delimiter
            IFS=':' read  -a column <<< "${lines[i]}"; # take array 
            colName=${column[0]};
            colPK=${column[1]};
            colDataType=${column[2]};

           #check column exsit
        if [[ $colName == $setcolName ]];then
             nameflag=1;  
             setcolNum=$(($i+1)); #numeber of column
        numRegex='^[0-9]+$'
        strRegex='^[a-zA-Z]+$'
        # validate dataType
        if [[ $colDataType == "number" ]]; then
            if ! [[ $setvalue =~ $numRegex ]]; then
                dataTypeFlag=0; #false
                errorFlag=0; #false
                echo "ERROR Value must be a number.";
            fi 
        fi
         if [[ $colDataType == "string" ]]; then
            if ! [[ $setvalue =~ $strRegex ]]; then
                dataTypeFlag=0; #false
                errorFlag=0; #false
                echo "ERROR Value must be a only character.";
            fi 
        fi
        
        
        # validate if PK
        if [[ $colPK == "yes" ]]; then
        echo "sa"
            # get all column data from Data/tableName
            IFS=$'\n' read   -a dataLines < $1  # all table
            #loop over column data to check pk if unique
            for j in "${!dataLines[@]}";
            do
            
                IFS=':' read  -a record <<< "${dataLines[j]}";
                counter=$((setcolNum-1))
                 #echo "${record[$counter]}  $j"
                if [[ ${record[$counter]} == $setvalue ]]; then
                    pkFlag=0; #false(not-unique)
                    errorFlag=0; #false
                    echo "ERROR Primary key must be unique.";
                fi
            done
        fi
            break;
        fi
    done
    # check if var need to set not empty and check all flags 
       if  ! [[ $setvalue == "" ]];then
       if  ! [[ $setcolName == "" ]];then
       
        if [[ $dataTypeFlag==1 && $pkFlag==1 && $errorFlag == 1 && $nameflag == 1 ]]; then
        # if need apdate all like (update table employee set id=1 )
        read -p "update all (all): (y/n)" all;
        if [[ $all == "y"   ]];then
         if [[ $colPK == "no" ]];then # shouldnt be primary because it will not be unique
                    # give awk column number and value need to set and ofs to delimiter  when output
                    alldataAfterUpdate=($(awk -v setcnum="$setcolNum" -v setvmun="$setvalue" -F: '
                    BEGIN{
                            FS=":";
                            OFS=":";
                        }

                        {         
                            
                            $setcnum=setvmun;
                        
   
                          print $0;
                        }
                    ' $1;));
                     rm $1;
                    touch $1;
                    echo "${alldataAfterUpdate[@]}"
                    #put new date in file
                    for j in "${!alldataAfterUpdate[@]}";
                    do
                        echo "${alldataAfterUpdate[j]}" >> $1;
                    done
                            echo "updated";   
                            
                        
                
         else 
         echo "this column is primary cant update all same value";
         fi
                    . tableDB.sh;

         else
        read -p "Enter check column name: " checkcolName;
     
        colNames=($(awk -F: '{print $1}' $1.metadata));
        checkcolFlag=1;
         for j in "${!colNames[@]}"
         do 
        #check if column check exsit
        if [[ $checkcolName == "${colNames[$j]}" ]]; then
        checkcolFlag=0   #true
        checkcolNum=$(($j+1));  #column-Number

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
        if [[ ${coltype[$checkcolNum-1]} == "string" ]];then

            typeFlag=1; #false
        fi
            
         #echo "$checkcolNum  $setcolNum";
         
         read -p "Enter value check" checkvalue;

       
        if [[ $checkcolFlag == 0 ]];then
         select checkchoice in equal  greater smaller
         do
           case $REPLY in
               equal)
                    echo "equal";
                   
                    
                    dataAfterUpdate=($(awk -v checkv="$checkvalue" -v colcheck="$checkcolNum" -v setcnum="$setcolNum" -v setvmun="$setvalue" -F: '
                    BEGIN{
                            FS=":";
                            OFS=":";
                        }

                        {         
                            if( checkv == $colcheck ){
                            $setcnum=setvmun;
                        }
   
                          print $0;
                        }
                    ' $1;));
                     rm $1;
                    touch $1;
                    for j in "${!dataAfterUpdate[@]}";
                    do
                        echo "${dataAfterUpdate[j]}" >> $1;
                    done
                    . tableDB.sh;
               ;;
               greater)
                 echo "gt";
                 if [[ $typeFlag == 0 ]];then
                 echo "greater";
                 dataAfterUpdate=($(awk -v checkv="$checkvalue" -v colcheck="$checkcolNum" -v setcnum="$setcolNum" -v setvmun="$setvalue" -F: '
                    BEGIN{
                            FS=":";
                            OFS=":";
                        }

                        {         
                            if( checkv > $colcheck ){
                            $setcnum=setvmun;
                        }
   
                          print $0;
                        }
                    ' $1;));
                     rm $1;
                    touch $1;
                    for j in "${!dataAfterUpdate[@]}";
                    do
                        echo "${dataAfterUpdate[j]}" >> $1;
                    done
                    else
                   echo "sorry, this check need number";
                fi
                    
              
                    . tableDB.sh;
               ;;
               smaller)
                echo "lt";
                 if [[ $typeFlag == 0 ]];then
                dataAfterUpdate=($(awk -v checkv="$checkvalue" -v colcheck="$checkcolNum" -v setcnum="$setcolNum" -v setvmun="$setvalue" -F: '
                    BEGIN{
                            FS=":";
                            OFS=":";
                        }

                        {         
                            if( checkv < $colcheck ){
                            $setcnum=setvmun;
                        }
   
                          print $0;
                        }
                    ' $1;));
                     rm $1;
                    touch $1;
                    for j in "${!dataAfterUpdate[@]}";
                    do
                        echo "${dataAfterUpdate[j]}" >> $1;
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
         else
         echo "fix error ";
         fi
        fi
        else 
        echo "error flage"
        fi
        else
        echo "empty col"
        fi
        else
        echo "empty set value"
        fi
          . tableDB.sh;
}

read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  updaterecord $name;
                  
              else 
               echo "sorry this table not found"
              fi