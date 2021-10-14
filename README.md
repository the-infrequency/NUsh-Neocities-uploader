# Neocities Uploader Script (NU.sh)

**Current version:** v.1

A bash script for uploading files to your [Neocities](https://www.neocities.org) site.

Project logo modified from [A book of cheerful cats](https://www.oldbookillustrations.com/illustrations/catnip-ball/) (1892) via [Old Book Illustrations](https://www.oldbookillustrations.com/).

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)


## Setup

**1. Get a copy of the script**    
Either use git, or just download the script file directly. Place a copy of the script in a directory (see the **issues** section of this readme, there are some limitations with using multiple scripts). Note that it can be any directory, it does not need to be the same dir as the files or subdir you want to upload (do not put the script in the same directory as the files you will upload, or it will upload a copy of itself). 

**2. Make it executeable**  
Use `chmod +x NU.sh` to make the script executeable, then run it with `./nu.sh`. Note that due to the way it creates its persistent file storage you can only use one copy of the script. If you have multiple sites you would like to upload this way, you'll have to wait until the multi-script feature is implemented.

**3. Configure**  
The first time the script is run it will automatically run the config option so you can enter all the data it needs to do it's thing (see the useage section of this readme for info about how to invoke the config option yourself later). 

**4. (optional) Update hashlist**  
If you already have a directory of files that have been uploaded to Neocities you might want to run `./NU.sh update`. This will create a hashlist of the existing files, so it will only upload modified/new files the next time you invoke the upload option in the script.  

## Useage

Run with `bash NU.sh [single option]` or `./NU.sh [single option]`

```
OPTIONS:
	config  - configure the script.  
	help    - display this help message.  
	update  - updated hash list, without uploading.  
	upload  - upload all files in the local directory (setup in config) to your Neocities site.  
	reset	- deletes the ~/.config/NUsh directory (for a fresh start).  
	license - copy of the license for this script (GPL v3).
```

## Known issues

- [ ] multiple scripts : at the moment, due to the way the `scrip_data_directory` variable is defined, you can only have one copy of the script in any given directory. So if you have multiple sites you are updating with copies of the script the script file for each site must be kept in separate directories. << could have a uid var the user can define in the script itself (the physical file) which will add that to the end of the dir name... that way you can have as many copies of the script as you want in the same dir without issue... just have a default value so if the thing isn't used it isn't a problem scriptwise??>>

- [ ] **!! SECURITY ISSUE !!** : If choosing the option to automate the upload (no need to enter password) the password will be stored in plain text in a file restricted to your user (chmod 600). This means anyone with root access or access to your login will be able to see the password!


## To do / planned features

The following is an unordered list of features and fixes I aim to add to the script. Feel free to reach out if you have any ideas or wishes. Please note that this is a hobby project though, so I may be a bit slow on responding. :)

**TO BE DONE:**

- [ ] option to define patterns of files to be ignored when uploading the site (ex. do not count files starting with 'DRAFT.*.md')
- [ ] ability to put the script in the same directory as the files to be uploaded, without uploading the script itself.

- [ ] backup, creating a single tar file containing the script, config file, hash file and (optionally) the files from the local directory. Making it a lot easier to move it all to a new computer, or restore it should there be some kind of issue.

- [ ] ability to have multiple copies of the script in the same directory (to update different sites) without it causing issues with the persistent file storage (alternatively be able to upload different sites with the same script).  

- [ ] multithreading hash calculation to handle much larger sites (shouldn't be an issue, but a fun feature none the less).  
- [ ] automatic speed test to decide on multithreading model (if enabled).  
- [ ] option to use [openSSL](https://www.openssl.org/) for hasing, should it provide a speed advantage over `sha1sum`.  

- [ ] mirror local and server files -- if you delete or move a file in the local directory, it is deleted/moved in the server directory.  

- [ ] add support for using api key in place of password (write access to site, but won't allow anyone to login as you via the web interface).  
- [ ] add support for securing the password/api key with [openSSL](https://www.openssl.org/).  
- [ ] add support for securing the password/api key with [GnuPG](https://gnupg.org/).  
- [ ] add support for securing the password/api key with [pass](https://www.passwordstore.org/).  

**DONE:**

- [x] only upload modified/new files, so you don't upload every single file each time, saving on upload time and lessening the Neocities bandwith useage. (Done with a sha1 file list).

- [x] option to store password in file, allowing the script to be run automatically (ex. via [cron](https://en.wikipedia.org/wiki/Cron)) without the need for user interaction.


## Contributing

Open for suggestions and ideas. Please note that this is a hobby project though, so may be slow to respond.


## Contact 

Homepage..: [https://the-infrequency.neocities.org](https://the-infrequency.neocities.org)  
Email.....: the-infrequency@protonmail.com  
Twitter...: [@TheInfrequency](twitter.com/TheInfrequency)  
Matrix....: [chatroom](https://matrix.to/#/!aUKWxiALHdUvpdVmhR:matrix.org)  
GitLab....: https://gitlab.com/the-infrequency/neocities-uploader-script  


## License
NUsh  Copyright (C) 2021  Cornelius K. of the-infrequency.neocities.org. 
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions.
See the [![GPL v3 License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0) for further details.


## Project status

**ongoing** -- this is a hobby project, so it'll be slow. There is a reason for "The Infrequency" being named what it is.

