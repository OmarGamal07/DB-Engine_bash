
function updaterecord(){
    colNames=($(awk -F: '{print $1}' $1.metadata));
    colFlag=1  #false
         echo "Enter name column need update and where from";
        for i in "${!colNames[@]}"
         do 
           count=$(($i+1));
           echo "$count ${colNames[$i]}"  
        done
        read -p "Enter set column name: " setcolName;
        for i in "${!colNames[@]}"
         do 

        if [[ $setcolName == "${colNames[$i]}" ]]; then
        colFlag=0   #true
        setcolNum=$(($i+1));  #column-Number
        fi
        
         
        done
         if [[ $colFlag == 1 ]];then
         echo "column not found";
         return;
        fi

        read -p "Enter value set" setvalue;

         colpk=($(awk -F: '{print $2}' $1.metadata));
        pkFlag=0 #true
        echo "${colpk[$etcolNum]}";
        if [[ ${colpk[$etcolNum]} == "yes" ]];then
        # get all column data from Data/tableName
            IFS=$'\n' read -d '' -r -a dataLines < "$1"  # all table
            #loop over column data to check pk if unique
            for j in "${!dataLines[@]}";
            do
                IFS=':' read -r -a record <<< "${dataLines[$j]}"; # record(row)
               echo "${record[etcolNum]}"
                if [[ ${record[etcolNum]} == $setvalue ]]; then
                    pkFlag=1; #false(not-unique)
                    echo "ERROR: Primary key must be unique.";
                fi
            done
        fi


        
        read -p "update all (all): (y/n)" all;
        if [[ $all == "y"  ]];then
            echo "equal";
                     counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$checkcolNum]}  $checkvalue";
                         counter=$(($counter+1));
                            
                            sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                            #${columndata[$setcolNum]}=$setvalue;
                            echo "${linesData[$i]} updated";   
                            
                        
                    done
                    . tableDB.sh;
         else
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

        coltype=($(awk -F: '{print $3}' $1.metadata));
        typeFlag=0 #true
        echo "${coltype[$checkcolNum]}";
        if [[ ${coltype[$checkcolNum]} == "string" ]];then

            typeFlag=1; #false
        fi
            
         #echo "$checkcolNum  $setcolNum";
         
         read -p "Enter value check" checkvalue;

       
        if [[ $pkFlag == 0 && $colFlag == 0 && $checkcolFlag == 0 ]];then
         select checkchoice in equal  greater smaller
         do
           case $REPLY in
               equal)
                    echo "equal";
                    #  counter=0;
                    # linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    # for i in "${!linesData[@]}"
                    # do
                    #     IFS=':' read -r -a columndata <<< "${linesData[i]}";
                    #     echo "${columndata[$checkcolNum]}  $checkvalue";
                    #      counter=$(($counter+1));
                    #     if [[ $checkvalue == ${columndata[$checkcolNum]} ]];then
                            
                    #         sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                    #         #${columndata[$setcolNum]}=$setvalue;
                    #         echo "${linesData[$i]} updated";   
                            
                    #     fi
                    # done
                    
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
                    
                #  if [[ $typeFlag == 0 ]];then
                #   counter=0;
                #     linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                #     for i in "${!linesData[@]}"
                #     do
                #         IFS=':' read -r -a columndata <<< "${linesData[i]}";
                #         echo "${columndata[$checkcolNum]}  $checkvalue";
                #          counter=$(($counter+1));
                #         if [[ $checkvalue > ${columndata[$checkcolNum]} ]];then
                            
                #             sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                #             #${columndata[$setcolNum]}=$setvalue;
                #             echo "${linesData[$i]} updated";   
                            
                #         fi
                #     done
                #     else
                #     echo "sorry, this check need number";
                # fi
                    . tableDB.sh;
               ;;
               smaller)
                echo "lt";
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
                    
                # if [[ $typeFlag == 0 ]];then
                #  counter=0;
                #     linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                #     for i in "${!linesData[@]}"
                #     do
                #         IFS=':' read -r -a columndata <<< "${linesData[i]}";
                #         echo "${columndata[$checkcolNum]}  $checkvalue";
                #          counter=$(($counter+1));
                #         if [[ $checkvalue < ${columndata[$checkcolNum]} ]];then
                            
                #             sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                #             #${columndata[$setcolNum]}=$setvalue;
                #             echo "${linesData[$i]} updated";   
                            
                #         fi
                #     done
                #      else
                #     echo "sorry, this check need number";
                # fi
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
          . tableDB.sh;
}

read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  updaterecord $name;
                  
              else 
               echo "sorry this table not found"
              fi