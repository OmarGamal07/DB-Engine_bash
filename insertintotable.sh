# 1)  read columns info from tableName.metadata into array
# 2)  loop over lines array to insert each column
# 3)  take column name and pk and type in variables
# 5)  read new column value from user and check regex if it is number or string
# 6)  check it is pk must be unique


function insertdata(){
   
    # read columns info from tableName.metadata into array
    lines=($(awk -F: '{print $1":"$2":"$3}' $1.metadata));
    # new record
    newRecord="";
    errorFlag=1; #true

    # loop over lines array to insert each column
    for i in "${!lines[@]}"
    do
        #ifs cut by delimiter
        IFS=':' read  -a column <<< "${lines[i]}"; # take array 
        colName=${column[0]};
        colPK=${column[1]};
        colDataType=${column[2]};

        #test flags
        dataTypeFlag=1; #true
        pkFlag=1;   #true
    
        #read new column value from user
        read -p "Enter $colName: " newColValue;
        numRegex='^[0-9]+$'
        strRegex='^[a-zA-Z]+$'
        # validate dataType
        if [[ $colDataType == "number" ]]; then
            if ! [[ $newColValue =~ $numRegex ]]; then
                dataTypeFlag=0; #false
                errorFlag=0; #false
                echo "ERROR Value must be a number.";
            fi 
        fi
         if [[ $colDataType == "string" ]]; then
            if ! [[ $newColValue =~ $strRegex ]]; then
                dataTypeFlag=0; #false
                errorFlag=0; #false
                echo "ERROR Value must be a only character.";
            fi 
        fi

        # validate if PK
        if [[ $colPK == "yes" ]]; then
            # get all column data from Data/tableName
            IFS=$'\n' read  dataLines < "$1"  # all table
            #loop over column data to check pk if unique
            for j in "${!dataLines[@]}";
            do
                IFS=':' read   record <<< "${dataLines[$j]}";
                echo "pk ${record[ i ]}  $newColValue"
                if [[ ${record[ $((i)) ]} == $newColValue ]]; then
                    pkFlag=0; #false(not-unique)
                    errorFlag=0; #false
                    echo "ERROR Primary key must be unique.";
                fi
            done
        fi


        #if value valid add it to newRecord string
        if [[ dataTypeFlag==1 && pkFlag==1 ]]; then
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
        if [[ $errorFlag == 1 ]]; then
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



echo "insert"
              read -p "Enter Name of table : " name
              if [ -f $name ] ; then 
                  insertdata $name;
              else 
               echo "sorry this table not found"
              fi


           