#          to create metadata file
# 1) take nubmer of fields he want
# 2) check this number
# 3) make metadata file and loop number fields
# 4) take column name and check regexs
# 5) take old data from metadata to chek if it is dulicate or not
# 6) if not dublicate check if user want pk and datatype fields




function createMetadata(){
    # 1) take nubmer of fields he want
    read -p "Enter number of fields: " col;
    # 2) check this number
    colnumberflage=1;
    if ! [[ $col =~ ^[0-9]+$   ]];then
    colnumberflage=0
    fi
if [[ $colnumberflage == 1 ]];then
# 3) make metadata file and loop number fields
    touch $1.metadata;  # $1 parameter name file
    while( [[ $col > 0 ]] )
    do
        #echo " $col ";
        colMetadata="";
        # 4) take column name and check regexs
        read -p "Enter column name: " colName;
        if [[ $colName =~ ^[a-zA-Z0-9]+$ && $colName =~ ^[a-zA-Z]  ]];then
                # 5) take old data from metadata to chek if it is dulicate or not
                #$1 inside awk first column
                colNames=($(awk -F: '{print $1}' $1.metadata));   # $1.metadata parameter name file 
                 colFlag=1;  #true
                 for i in "${!colNames[@]}"
                do 

                    if [[ $colName == "${colNames[i]}" ]]; then
                        colFlag=0   #false
                        echo "Dublicated column $colName found before";
                    fi   
                done
                # 6) if not dublicate check if user want pk and datatype fields
                if [[ $colFlag == 1 ]] ;then
                colMetadata="$colName";

                read -p "Is it Primary-Key (PK): (y/n)" pk;
                if [[ $pk == "y" || $pk == "Y" ]]; then
                colMetadata="$colMetadata:yes"; #append yes if want pk
                elif [[ $pk == "n" || $pk == "N" ]]; then
                colMetadata="$colMetadata:no";
                else
                    colMetadata="$colMetadata:no";
                    echo "will be default no";      #defualt if enter any thing else
                fi

                read -p "Choose column's datatype String(s) Number(n): (s/n)" colDataType;
                if [[ $colDataType == "s" || $colDataType == "S" ]]; then
                colMetadata="$colMetadata:string";#append yes if want string
                elif [[ $colDataType == "n" || $colDataType == "N" ]]; then
                colMetadata="$colMetadata:number";
                else
                    colMetadata="$colMetadata:string";
                    echo "will be default string"; #defualt if enter any thing else
                fi
                #make file of data
                touch $1; 
                #put metadata in file
                echo $colMetadata >> $1.metadata;
            else 
                #if this column duplicate ask him if need try another name or skip
                read -p "Enter y if need retry input another field " try;
                if [[ $try == "y" || $try == "Y" ]];then
                    ((col=$col+1));
                else
                    echo "this field not made"
                fi
            fi    
        else 
            echo "enter name not begin by number and not contain spectial char "     
        fi
       ((col=$col-1))
    done
    else
     echo "must be number";
fi
    . tableDB.sh;
}

read -p "Enter Name of table : " name col
            if [ -f $name ] ;then
                echo "Already Exits : please enter another name "
            else 
                if [[ $name =~ ^[a-zA-Z0-9]+$ && $name =~ ^[a-zA-Z]  ]];then
                    createMetadata $name $col 5 "asd"; #call function and pass parameter name file
                else 
                    echo "Enter name not begin by number and not contain spectial char "     
                fi
            fi 