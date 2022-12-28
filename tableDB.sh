#!/bin/bash

function createMetadata(){
    read -p "Enter number of fields: " col;
    while( [[ $col != 0 ]] )
    do
        #echo " $col ";
        colMetadata="";
        read -p "Enter column name: " colName;
        if [[ $name =~ ^[a-zA-Z0-9]+$ && $name =~ ^[a-zA-Z]  ]];then
                colMetadata="$colName";

                read -p "Is it Primary-Key (PK): (y/n)" pk;
                if [[ $pk == "y" || $pk == "Y" ]]; then
                colMetadata="$colMetadata:yes";
                elif [[ $pk == "n" || $pk == "N" ]]; then
                colMetadata="$colMetadata:no";
                fi

                read -p "Choose column's datatype String(s) Number(n): (s/n)" colDataType;
                if [[ $colDataType == "s" || $colDataType == "S" ]]; then
                colMetadata="$colMetadata:string";
                elif [[ $colDataType == "n" || $colDataType == "N" ]]; then
                colMetadata="$colMetadata:number";
                fi
                touch $1.metadata;
                touch $1;
                #put metadata in file
                echo $colMetadata >> $1.metadata;
        else 
            echo "enter name not begin by number and not contain spectial char "     
        fi
       ((col=$col-1))
    done
    . tableDB.sh;
}

function insertdata(){
   
    # read columns info from tableName.metadata into array
    lines=($(awk -F: '{print $1":"$2":"$3}' $1.metadata));
    # new record
    newRecord="";
    errorFlag=0; #true

    # loop over lines array to insert each column
    for i in "${!lines[@]}"
    do
        IFS=':' read -r -a column <<< "${lines[i]}";
        colName=${column[0]};
        colPK=${column[1]};
        colDataType=${column[2]};
        

        #test flags
        dataTypeFlag=0; #true
        pkFlag=0;   #true

        #read new column value from user
        read -p "Enter $colName: " newColValue;
        numRegex='^[0-9]+$'
        strRegex='^[a-zA-Z]+$'
        # validate dataType
        if [[ $colDataType == "number" ]]; then
            if ! [[ $newColValue =~ $numRegex ]]; then
                dataTypeFlag=1; #false
                errorFlag=1; #false
                echo "ERROR: Value must be a number.";
            fi 
        fi
         if [[ $colDataType == "string" ]]; then
            if ! [[ $newColValue =~ $strRegex ]]; then
                dataTypeFlag=1; #false
                errorFlag=1; #false
                echo "ERROR: Value must be a only character.";
            fi 
        fi

        # validate if PK
        if [[ $colPK == "yes" ]]; then
            # get all column data from Data/tableName
            IFS=$'\n' read -d '' -r -a dataLines < "$1"  # all table
            #loop over column data to check pk if unique
            for j in "${!dataLines[@]}";
            do
                IFS=':' read -r -a record <<< "${dataLines[$j]}"; # record(row)
                if [[ ${record[i]} == $newColValue ]]; then
                    pkFlag=1; #false(not-unique)
                    errorFlag=1; #false
                    echo "ERROR: Primary key must be unique.";
                fi
            done
        fi


        #if value valid add it to newRecord string
        if [[ dataTypeFlag==0 && pkFlag==0 ]]; then
            if [[ $i == 0 ]]; then
                newRecord=$newColValue;
            else
                newRecord="$newRecord:$newColValue";
            fi
        else
            echo "In-valid record";
        fi
    done


    # append newRecord in Data/$tableName
    if ! [[ $newRecord == "" ]]; then
        if [[ $errorFlag == 0 ]]; then
            if echo $newRecord >> "$1"; then
                echo "Record stored succesfully.";
            else
                echo "ERROR: Failed to store record.";
            fi
        else
            echo "ERROR: Failed to store record.";
        fi
    else
        echo "ERROR: Record is empty.";
    fi
    . tableDB.sh;
}


function deleterecord(){
    colNames=($(awk -F: '{print $1}' $1.metadata));
    read -p "need delete all table enter y" all;
     if [[ $all == "y" || $all == "Y" ]]; then
        rm $1;
        touch $1;
        else
        colFlag=1  #false
         echo "Enter name column from";
        for i in "${!colNames[@]}"
         do 
           count=$(($i+1));
           echo "$count ${colNames[$i]}"  
        done
        read -p "Enter column name: " colName;
        for i in "${!colNames[@]}"
         do 
        if [[ $colName == "${colNames[$i]}" ]]; then
        colFlag=0   #true
        colNum=$(($i));  #column-Number
        fi   
        done
        if [[ $colFlag == 1 ]];then
         echo "column not found";
         return;
        fi
         
         coltype=($(awk -F: '{print $3}' $1.metadata));
        typeFlag=0 #true
        echo "${coltype[$colNum]}";
        if [[ ${coltype[$colNum]} == "string" ]];then

            typeFlag=1; #false
        fi
         read -p "Enter value check" value;
         select checkchoice in equal  greater smaller
         do
           case $REPLY in
               equal)
                    echo "equal";
                     counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counter=$(($counter+1));
                        if [[ $value == ${columndata[$colNum]} ]];then
                            
                            sed -i "$counter"d $1;  
                            echo "${linesData[$i]} deleted";   
                        fi
                    done
                    . tableDB.sh;
               ;;
               greater)
                 echo "gt";
                 if [[ $typeFlag == 0 ]];then
                  counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counter=$(($counter+1));
                        if [[ $value > ${columndata[$colNum]} ]];then
                            
                            sed -i "$counter"d $1;  
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
                if [[ $typeFlag == 0 ]];then
                 counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$colNum]}  $value";
                         counter=$(($counter+1));
                        if [[ $value < ${columndata[$colNum]} ]];then
                            
                            sed -i "$counter"d $1;  
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
        setcolNum=$(($i));  #column-Number
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
        checkcolNum=$(($j));  #column-Number

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
                     counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$checkcolNum]}  $checkvalue";
                         counter=$(($counter+1));
                        if [[ $checkvalue == ${columndata[$checkcolNum]} ]];then
                            
                            sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                            #${columndata[$setcolNum]}=$setvalue;
                            echo "${linesData[$i]} updated";   
                            
                        fi
                    done
                    . tableDB.sh;
               ;;
               greater)
                 echo "gt";
                 if [[ $typeFlag == 0 ]];then
                  counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$checkcolNum]}  $checkvalue";
                         counter=$(($counter+1));
                        if [[ $checkvalue > ${columndata[$checkcolNum]} ]];then
                            
                            sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                            #${columndata[$setcolNum]}=$setvalue;
                            echo "${linesData[$i]} updated";   
                            
                        fi
                    done
                    else
                    echo "sorry, this check need number";
                fi
                    . tableDB.sh;
               ;;
               smaller)
                echo "lt";
                if [[ $typeFlag == 0 ]];then
                 counter=0;
                    linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                    for i in "${!linesData[@]}"
                    do
                        IFS=':' read -r -a columndata <<< "${linesData[i]}";
                        echo "${columndata[$checkcolNum]}  $checkvalue";
                         counter=$(($counter+1));
                        if [[ $checkvalue < ${columndata[$checkcolNum]} ]];then
                            
                            sed -i -z "s/${columndata[$setcolNum]}/$setvalue/" $1;  
                            #${columndata[$setcolNum]}=$setvalue;
                            echo "${linesData[$i]} updated";   
                            
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
         else
         echo "fix error ";
         fi
        fi
          . tableDB.sh;
}


function seclectfromtable(){
    select selectchoise in all byrow bycol
    do
        case $REPLY in  
            all)
                cat $1;
            ;;
            byrow)
                 colNames=($(awk -F: '{print $1}' $1.metadata));
                echo "Enter name column need update and where from";
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
                read -p "Enter value check" checkvalue;
                select checkchoice in equal  greater smaller
                do
                    case $REPLY in
                        equal)
                            echo "equal";
                           linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read -r -a columndata <<< "${linesData[i]}";
                                echo "select by row is";
                                if [[ $checkvalue == ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                    . tableDB.sh;
               ;;
               greater)
                 echo "gt";
                           linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read -r -a columndata <<< "${linesData[i]}";
                                echo "select by row is";
                                if [[ $checkvalue > ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                    . tableDB.sh;
               ;;
               smaller)
                echo "lt";
                           linesData=($(awk -F: '{print $1":"$2":"$3}' $1));
                           echo "select by row is";
                            for i in "${!linesData[@]}"
                            do
                                IFS=':' read -r -a columndata <<< "${linesData[i]}";
                                
                                if [[ $checkvalue < ${columndata[$checkcolNum]} ]];then
                                    echo "${linesData[$i]}";   
                                fi
                            done
                esac
                done            
            ;;
            bycol)
             echo "ad";
            ;;
            *)
            echo"default";
        esac
    done
    . tableDB.sh;
}

select choice in createtable listtable droptable insert selecttable delete update back
do 
# echo $choice
# echo "Reply " $REPLY #Choice 
    case $REPLY in 
        createtable)
            read -p "Enter Name of table : " name
            if [ -f $name ] ;then
                echo "Already Exits : please enter another name "
            else 
                if [[ $name =~ ^[a-zA-Z0-9]+$ && $name =~ ^[a-zA-Z]  ]];then
                    createMetadata $name;
                else 
                    echo "enter name not begin by number and not contain spectial char "     
                fi
            fi 
        ;;  
        back)
           cd ..;
        ;;
        listtable) 
        echo "ListDB"
          ls -F | grep ".*\.?$"  
        ;;
        insert )
        echo "insert"
              read -p "Enter Name of table : " name
              if [ -f $name ] ; then 
                  insertdata $name;
              else 
               echo "sorry this database not found"
              fi
        ;; 
        droptable)
          read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  rm  $name;
                  rm $name.metadata; 
                  echo " DB dropped : "
              else 
               echo "sorry this table not found"
              fi
        ;; 
        delete)
            read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  deleterecord $name;
                  
              else 
               echo "sorry this table not found"
              fi
        ;;
        update)
            read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  updaterecord $name;
                  
              else 
               echo "sorry this table not found"
              fi
        ;;
        selecttable)
        read -p "Enter Name of table : " name
          if [ -f $name ] ; then 
                  seclectfromtable $name;
                  
              else 
               echo "sorry this table not found"
              fi
        ;;
        *) 
         echo "default"
    esac
done


#insert function using awk
#  error=0;
#     filename=$1;
#     declare -a arr;
#     count=0;
    
#     awk '
# BEGIN{
#     FS=":";
    
# }
# { 
#     arr[count]=$1;
#     print arr[count];
#     count=$count+1;  
# }
# END{
#     print "done";
# }
# '  $filename

#     awk -v $' 
#        BEGIN{FS=":";j=0;newrecord="";filename1=filename;}
#        {
#         colName=$1;
#         colPK=$2;
#         colDataType=$3;
#        print colName colPK colDataType;
#        print "Enter value column : " colName ;
#        getline newColValue < "-";    
#        print colDataType;
#         if ( colDataType == "number" )
#             {
#                 print "it is number";
#                if (!match(newColValue,/^[0-9]+$/))
#                {
#                  print "enter number";
#                 error=1;
#                }
#             }

#         if ( colPK == "yes" )
#         {
#             print "it is primary"
#             for (i = 0; i < length(arr); i++)
#             {
#                 if(arr[i]==newColValue);then
#                 print "arr[i]"
#                 print "key should be unique";
#                 error=1;
#                 fi
#                 print "sd";
#             }
#         }
#           if( j==0 )
#           newrecord=newColValue;
#           else
#            newrecord=newrecord":"newColValue;
#            fi
#            j++;
#            print newrecord  ;
#         }
#         END{
#             print newrecord  ;
#             filename=$1;
#     if  (newrecord != " ")  
#         {
#             if (error == 0 )  
#              {
#                 printf newrecord >> "name";
#                 print "Record stored succesfully.";
           
           
#              }
#              else
#                 print "ERROR error";
#         }
#         else
#                 print "ERROR new record empty";
        
      
#         }
#     ' $filename.metadata