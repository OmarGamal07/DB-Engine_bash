#!/bin/bash



select choice in createtable listtable droptable insert selecttable delete update back
do  
    case $REPLY in 
        createtable)
            . createMetadata.sh;
            . tableDB.sh
        ;;  
        back)
           cd ..;
           . createDatabase.sh;
        ;;
        listtable) 
        echo "ListDB"
          ls  | grep -v ".metadata$"  ;  # invert pattern
          . tableDB.sh
        ;;
        insert )
            . insertintotable.sh;
            . tableDB.sh
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
              . tableDB.sh
        ;; 
        delete)
           . deletefromtable.sh ;
           . tableDB.sh
        ;;
        update)
           . updatefromtable.sh ; 
           . tableDB.sh
        ;;
        selecttable)
           . selectfromtable.sh;
           . tableDB.sh
       
        ;;
        *) 
         echo "this command not found";
    esac
done


