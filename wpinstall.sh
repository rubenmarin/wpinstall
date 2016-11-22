#!/bin/bash

CURRENT_PATH=$(pwd)
WPZIPFILE="latest.zip"
WPLOAD="wp-load.php"

if [ "$1" = "-v" ];
	then
	if [ -z "$2" ];
		then
		WPZIPFILE="latest.zip"
	else
		WPZIPFILE="wordpress-"$2".zip"
		echo "installing version: "$2
	fi
fi

WPZIP=${CURRENT_PATH}"/"${WPZIPFILE}

WPCHECK=${CURRENT_PATH}"/"${WPLOAD}

# check if WordPress is installed
if [ -f "$WPCHECK" ];
then
	if [ "$1" = "wpconfig" ];
		then
		echo ""
	else
		echo 'WordPress is already installed'
	fi
	
else

	echo 'installing WordPress...'

	rm $WPZIP

	#get latest
	curl -O "https://wordpress.org/"$WPZIPFILE

	#unzip
	unzip $WPZIP

	#move
	mv wordpress wp_temp

	cd 'wp_temp'

	#pwd

	mv * ../
 	
 	cd ../

	#remove temp
	if [ -f "$WPCHECK" ];
	then
		echo 'removing temp files...'
			rmdir ${CURRENT_PATH}"/wp_temp"
			rm $WPZIP
	fi

	## create config
	cp ${CURRENT_PATH}"/wp-config-sample.php" ${CURRENT_PATH}"/wp-config.php"
	echo "file created: wp-config.php"
	
	## create .htaccess
	touch ${CURRENT_PATH}'/.htaccess'
	echo "file created: .htaccess"

	## create uploads path
	mkdir ${CURRENT_PATH}"/wp-content/uploads"
	echo "path created: "${CURRENT_PATH}"/wp-content/uploads"

	## create uploads/video
	mkdir ${CURRENT_PATH}"/wp-content/uploads/video"
	echo "path created: "${CURRENT_PATH}"/wp-content/uploads/video"
	

	#permissions
	find . -type f -print0 | xargs -I {} -0 chmod 0644 {} ;
	echo 'file permissions: done'
	
	find ${CURRENT_PATH} -type d -exec chmod 755 {} \;
	echo 'folder permissions: done'

	chmod 775 ${CURRENT_PATH}'/.htaccess'
	echo '.htaccess permissions: done'

	chmod -R 775 ${CURRENT_PATH}"/wp-content/uploads/"
	echo 'upload path permissions: done'
	
	echo "-----------------------------"
		#echo "running the following command to update wp-config.php:"
		echo "running 'sh wpinstall.sh wpconfig' to update 'wp-config.php'"

	echo "-----------------------------"
	
	sh wpinstall.sh wpconfig

fi

if [ "$1" = "wpconfig" ];
	then

	echo "*****************************"
	echo "         [ WPCONFIG ]        "
	echo "*****************************"
	echo ""
	echo "UPDATE wp-config.php? y/n [ENTER]"
	echo "[y] you'll be asked for DB_NAME , DB_USER , DB_PASSWORD"
	echo "[n] nothing follows"

	read DO_WPCONFIG

	if [ "$DO_WPCONFIG" = 'y' ];
	then
		echo "-----------------------------"
		echo "DB_NAME?[ENTER]"
			read DATABASE_NAME
		echo "-----------------------------"	
		echo "DB_USER?[ENTER]"
			read DATABASE_USER
		echo "-----------------------------"	
		echo "DB_PASSWORD?[ENTER]"
			read DATABASE_PW

		if [ -z "$DATABASE_NAME" -o -z "$DATABASE_USER" -o -z "$DATABASE_PW" ];
			then
			echo 'try again >> sh wpinstall.sh wpconfig'
		else
			
			echo "-----------------------------"
			echo "-----------------------------"

			echo "DB_NAME     : '"$DATABASE_NAME"'"
			echo "DB_USER     : '"$DATABASE_USER"'" 
			echo "DB_PASSWORD : '"$DATABASE_PW"'" 

			echo "-----------------------------"
			echo "-----------------------------"

			echo "Is this correct? y / n [ENTER]"

			read DO_WPCONFIG_WRITE
			if [ "$DO_WPCONFIG_WRITE" = 'y' ];
				then
				echo 'updating wp-config.php ...'

				rm wp-config.php
				
				sed "s/database_name_here/${DATABASE_NAME}/g; s/username_here/${DATABASE_USER}/g; s/password_here/${DATABASE_PW}/g" wp-config-sample.php > wp-config.php

				echo 'done :)'
			else
				echo 'try again >> sh wpinstall.sh wpconfig'
			fi
		fi
	fi
fi
