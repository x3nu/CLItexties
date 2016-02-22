#!/bin/bash
#
# CLItxties - quickly post something to http://txti.es
#
# Authors:
# https://github.com/x3nu
# https://github.com/parazyd
#
# Link: https://github.com/x3nu/CLItexties
#
# Required: curl, lynx, nano


# create temporary file
TempFile=`date +%s-%N`"-cl_txti.md"
touch /tmp/$TempFile

# get input either interactivly or via arguments
if [ "$1" = "-i" ]; then
	nano /tmp/$TempFile
	content=$(</tmp/$TempFile)
	rm /tmp/$TempFile
	echo -n "Custom URL: "
	read custom_url
	echo -n "Custom Editcode: "
	read custom_edit_code
elif [ "$1" = "-f" ]; then
	content=$(<$2)
	custom_url=$3
	custom_edit_code=$4
fi

# try to post and check if URL already exists
curl -s --data-urlencode "content=$content" \
    --data "&custom_url=$custom_url&custom_edit_code=$custom_edit_code&form_level=2&submit=Save%20and%20done" \
        http://txti.es \
    | lynx -nostatus -stdin -dump -nolist \
    | grep -q "already exists" 

# if URL does already exist, get a new one interactivly or produce random one
if [ "$1" = "-i" ]; then
	while [ $? -eq 0 ]
	do
	   	echo -n "This url (\"$custom_url\") is already in use, please choose a new one: "      
	   	read custom_url
	   	curl -s --data-urlencode "content=$content" --data \
            "&custom_url=$custom_url&custom_edit_code=$custom_edit_code&form_level=2&submit=Save%20and%20done" \
                http://txti.es \
            | lynx -nostatus -stdin -dump -nolist \
            | grep -q "already exists" 

	  	if [ $? -eq 1 ]; then
	  		echo "Your post is online at: http://txti.es/$custom_url"
			echo "Your edit code is: $custom_edit_code"
			echo "You can edit your post at: http://txti.es/$custom_url/edit"
			echo "Save this code, or write it down somewhere, as it can't be recovered"
			break
		fi
	done
elif [ "$1" = "-f" ]; then
	while [ $? -eq 0 ]
	do
	   	rnd_url=$custom_url`date +-%s`
	   	curl -s --data-urlencode "content=$content" --data \
                "&custom_url=$rnd_url&custom_edit_code=$custom_edit_code&form_level=2&submit=Save%20and%20done" \
                http://txti.es \
            | lynx -nostatus -stdin -dump -nolist \
            | grep -q "already exists" 

	  	if [ $? -eq 1 ]; then
	  		echo "http://txti.es/$rnd_url $custom_edit_code"
			break
		fi
	done
elif [ "$*" = "" ]; then
    cat <<EOF
CLItexties - Post to txti.es from the commandline

Usage:
    CLItxties.sh -i (enter content and custom url/editcode interactively)
    CLItxties.sh -f [path-to-file] [custom url] [custom edit code] (post contents of file)

If you used MyCoolPost as customized URL you'll find your post at
http://txti.es/MyCoolPost and the edit link would be http://txti.es/MyCoolPost/edit
EOF

fi
