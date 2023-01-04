#!/bin/bash



select choice in createtable listtable droptable insert selecttable delete update back
do  
    case $REPLY in 
        createtable)
            . createMetadata.sh;
        ;;  
        back)
           cd ..;
        ;;
        listtable) 
        echo "ListDB"
          ls  | grep -v ".metadata$"  ;  # invert pattern
        ;;
        insert )
            . insertintotable.sh;
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
           . deletefromtable.sh ;
        ;;
        update)
           . updatefromtable.sh ; 
        ;;
        selecttable)
           . selectfromtable.sh;
       
        ;;
        *) 
         echo "this command not found";
    esac
done


