#!/bin/bash
select choice in createDB listDB dropDB connectDB 
do 
    case $REPLY in 
    # choice create database 
        createDB)
        echo "CreateDB"
        # take name database from user
            read -p "Enter Name of Database : " name
            #check if this name already exist
            if [ -e $name ] ;then
                echo "Already Exits : please enter another name "
            else 
            #check regexs   contain character,number only  and start by character
                if [[ $name =~ ^[a-zA-Z0-9]+$ && $name =~ ^[a-zA-Z]  ]];then
                     mkdir $name
                     echo "database created";
                else 
                    echo "Enter name not begin by number and not contain spectial char "     
                fi
            fi 
            . createDatabase.sh
        ;;  
        listDB) 
        echo "ListDB"
          ls -F | grep "/"  ; #list dirctory database end by /
          . createDatabase.sh
        ;;
        connectDB )
        echo "ConnectDB"
           #take name database which user need connect
              read -p "Enter Name of Folder : " name
              #check exist
              if [ -d $name ] ; then 
                  echo "I connect DB : "
                  cd $name ; 
                  #if exist go to tables select
                  . tableDB.sh;
                  cd ..;
              else 
               echo "sorry this database not found"
              fi
              . createDatabase.sh
        ;; 
        dropDB)
        #take name database which user need delete
          read -p "Enter Name of database : " name
          if [ -d $name ] ; then 
                  rm -r $name 
                  echo " DB dropped : "
              else 
               echo "sorry this database not found"
              fi
              . createDatabase.sh
        ;; 
        *) 
         echo "command not found"
    esac
    . createDatabase.sh
done