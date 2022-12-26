select choice in createDB listDB dropDB connectDB 
do 
# echo $choice
# echo "Reply " $REPLY #Choice 
    case $REPLY in 
        createDB)
        echo "CreateDB"
            read -p "Enter Name of Folder : " name
            if [ -e $name ] ;then
                echo "Already Exits : please enter another name "
            else 
                if [[ $name =~ ^[a-zA-Z0-9]+$ && $name =~ ^[a-zA-Z]  ]];then
                     mkdir $name
                else 
                    echo "enter name not begin by number and not contain spectial char "     
                fi
            fi 
        ;;  
        listDB) 
        echo "ListDB"
          ls -F | grep "/"  
        ;;
        connectDB )
        echo "ConnectDB"
              read -p "Enter Name of Folder : " name
              if [ -d $name ] ; then 
                  echo "I connect DB : "
                  cd $name ; 
                  #do any thing and back
                  cd ..;
              else 
               echo "sorry this database not found"
              fi
        ;; 
        dropDB)
          read -p "Enter Name of Folder : " name
          if [ -d $name ] ; then 
                  rm -r $name 
                  echo " DB dropped : "
              else 
               echo "sorry this database not found"
              fi
        ;; 
        *) 
         echo "default"
    esac
done