#!/usr/bin/env bash

# A simple bash script for uploading files to your Neocities site. Keeps track and only uploads modified/new files.

# NU.sh is Copyright (C) 2021 Cornelius K of the-infrequency.neocities.org. 
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Homepage: https://the-infrequency.neocities.org
# Email: the-infrequency@protonmail.com
# Twitter: TheInfrequency
# GitLab: https://gitlab.com/the-infrequency/neocities-uploader-script



# !!!!! when giving options to encrypt password/api key, include a [already installed/not installed] tag next to each option.
#	eg. using GnuPG2 [not installed]  /  using openssl [already installed] ...

function config_edit() {
	if [[ ! -d $HOME/.config/NUsh ]]; then
		mkdir $HOME/.config/NUsh
		echo "new" > $HOME/.config/NUsh/hashList
	fi
	if [[ ! -f "$HOME/.config/NUsh/config" ]]; then
		printf "c_localDir=NA\n" >> $HOME/.config/NUsh/config
		printf "c_userName=NA\n" >> $HOME/.config/NUsh/config
		printf "c_authMethod=NA\n" >> $HOME/.config/NUsh/config
	fi
	# load config file
	source $HOME/.config/NUsh/config
	# config edit infinite loop
	while true 
	do
		printf "== NUsh config ==\n\n"
		printf "1) Local directory......: ${c_localDir}\n"
		printf "2) Password entry method: ${c_authMethod}\n"
		printf "3) Neocities username...: https://${c_userName}.neocities.org\n"
		printf "\n"
		printf "Q) Quit\n"
		printf "\n"

		read -p "option> " m_answer
		case ${m_answer,,} in
			q)
				clear
				break
				;;
			1)
				read -p "Path to the directory to be uploaded (full absolute path only): " c_localDir
				clear
				;;
			2)
				printf "Password entry method:\n"
				printf "1) Ask for password every time you upload.\n"
				printf "2) Store password for non-interactive automatic upload.\n"
				read -p "> " c_authMethod
				if [[ $c_authMethod == '1' ]]; then
					c_authMethod='ask'
					echo $RANDOM | sha512sum > $HOME/.config/NUsh/p # empty file
					printf "" > $HOME/.config/NUsh/p
				elif [[ $c_authMethod == '2' ]]; then
					c_authMethod='file'
					read -p "The password file will now be opened in NANO. Please enter your password, save, then exit the document. <press return>"
					nano $HOME/.config/NUsh/p
					printf "You will need to enter your password, as the password file with be restricted (sudo chown 600) to add a tiny bit of password security.\n"
					sudo chown 600 $HOME/.config/NUsh/p
				else
					read -p "You have not entered a valid option, defaulting to option 1 (ask for each upload). <press return>"
					c_authMethod='ask'
				fi
				clear
				;;
			3)
				read -p "Neocities user name (https://<only this part>.neocities.org): " c_userName
				clear
				;;
			*)
				clear
				;;
		esac
	done
	# store configuration options in the config file again
	printf "c_localDir=${c_localDir}\nc_uploadKey='~/.config/NUsh/p'\nc_userName=${c_userName}\nc_authMethod=${c_authMethod}" > $HOME/.config/NUsh/config
}

function upload_files() {
	# make sure the local directory exists
	if [[ ! -d $c_localDir ]]; then
		printf "ERROR :: Could not locate directory (${c_localDir})\n"
		exit 1
	fi
	# ensure hashList file exists
	printf "generating hash list..."
	if [[ ! -f "$HOME/.config/NUsh/hashList" ]]; then
		echo "new" > "$HOME/.config/NUsh/hashList"
	fi
	tmpdir=$(mktemp -d /tmp/NUsh.XXXXXXXX) # create temporary directory
	find "${c_localDir}" -type f > "${tmpdir}/filelist"
	# sha1 calculation
	while IFS= read -r line; do # sha1sum each file found
		sha1sum "${line}" >> "${tmpdir}/newhashlist"
		printf "."
	done < "${tmpdir}/filelist"
	printf "done\n"
	# compare hashes and make a list of files to be uploaded
	printf "attempting to upload..."
	while IFS= read -r line; do
		# if the line is not found in the existing hash file, the file must be uploaded
		if [[ ! $(grep -qw "$line" "${HOME}/.config/NUsh/hashList") ]]; then
			line="${line:42}" # strip out the hash portion of the line
			printf -- "-F \"${line:${#c_localDir}}=@${line}\" " "-$1" >> "${tmpdir}/tobeuploaded"
		fi
	done < ${tmpdir}/newhashlist
	source $HOME/.config/NUsh/config 
	# if password IN FILE
	if [[ "$c_authMethod" == "file" ]]; then
		cmd="curl "$(cat ${tmpdir}/tobeuploaded)"\"https://${c_userName}:$(head -n1 $HOME/.config/NUsh/p | tr -d '\n')@neocities.org/api/upload\" > ${tmpdir}/uploadresult"
	# if password ASK ON UPLOAD
	elif [[ "$c_authMethod" == "ask" ]]; then 
		cmd="curl -u \"$c_userName\" "$(cat ${tmpdir}/tobeuploaded)"\"https://neocities.org/api/upload\" > ${tmpdir}/uploadresult"
	fi
	eval "$cmd"
	#check if the upload completed without issues
	# cleanup
	rm $(find "$tmpdir" -type f | tr '\n' ' ')
	rmdir "$tmpdir"
}

function update_hash() {
	tmpdir=$(mktemp -d /tmp/NUsh.XXXXXXXX) # create temporary directory
	find "${c_localDir}" -type f > "${tmpdir}/filelist"
	# sha1 calculation
	printf "Updating existing hash list without uploading..."
	while IFS= read -r line; do # sha1sum each file found
		sha1sum "${line}" >> "${tmpdir}/newhashlist"
		printf "."
	done < "${tmpdir}/filelist"
	cat "${tmpdir}/newhashlist" > "$HOME/.config/NUsh/hashList"
	printf "done!\n"
}


# Check dependencies
dependencies=("curl" "sha1sum")
flag1=0
for item in ${dependencies[@]}; do
	if [[ ! $(which $item) ]]; then
		flag1=1
	fi
done
if [[ $flag1 -eq 1 ]]; then
	printf "ERROR! Please make sure that all of these are installed: ${dependencies[*]}\n"
	exit 1
fi

# Ensure everyhing is setup correctly before beginning
if [[ ! -d $HOME/.config/NUsh ]]; then
	printf "Running first time setup.\nCreating ~/.config/NUsh/ directory and files.\n"
	config_edit # edit the config so it works
else
	source $HOME/.config/NUsh/config # load config file
fi

case ${1,,} in
	config)
		clear
		config_edit
		;;
	update)
		clear
		update_hash
		;;
	upload)
		upload_files
		;;
	reset)
		read -p "WARNING! you are about to delete the content of $HOME/.config/NUsh/ are you sure you want to do this? [y/n] " warning_ans
		if [[ ${warning_ans,,} == "y" ]]; then
			echo "$RANDOM" | sha512sum > $HOME/.config/NUsh/p
			rm -f $HOME/.config/NUsh/*
			rmdir $HOME/.config/NUsh
		fi
		;;
	license)
		printf '''NU.sh is Copyright (C) 2021 Cornelius K of the-infrequency.neocities.org. 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
'''
		;;
	help|*)
		printf "Neocities Uploader script (v.1)\n\n"
		printf "run with \"bash NU.sh [single option]\" or \"./NU.sh [single option]\"\n\n"
		printf "OPTIONS:\n"
		printf "	config  - configure the script.\n"
		printf "	help    - display this help message.\n"
		printf "	update  - updated hash list, without uploading.\n"
		printf "	upload  - upload all files in the local directory (setup in config) to your Neocities site.\n"
		printf "	reset	- deletes the ~/.config/NUsh directory (for a fresh start).\n"
		printf "	license - copy of the license for this script (GPL v3).\n\n"
		printf "For updates and a list of planend features: https://gitlab.com/..... \n"
		;;
esac