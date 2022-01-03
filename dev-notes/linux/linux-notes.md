# Linux Notes

## Commands

- `echo [data-to-be-printed]`
  - Eg

    ```bash
    root@a0baacccc8e5:/# echo hello
    hello
    ```

  - Description : Prints the data to the output
- `whoami`
  - Eg

    ```bash
    root@a0baacccc8e5:/# whoami
    root
    ```

  - Description : Prints the current user name
- `echo $0`
  - Eg

    ```bash
    root@a0baacccc8e5:/# echo $0
    /bin/bash
    ```

  - Description : Prints the location of the shell program
- `history`
  - Eg

    ```bash
    1 echo hello
    2 whoami
    3 echo $0
    ```

  - Description : Prints the command history
- `!2`
  - Eg

    ```bash
    root@a0baacccc8e5:/# !2
    whoami
    root
    ```

  - Description : Runs the command from the history which maps to the number
- `apt list`
  - Eg

    ```bash
    root@a0baacccc8e5:/# apt list
    Listing... Done
    adduser/now 3.118ubuntu2 all [installed,local]
    apt/now 2.0.4 amd64 [installed,local]
    base-files/now 11ubuntu5.3 amd64 [installed,local]
    ```

  - Description  : List the all the packages in the package database
- `apt install [package-name]`
  - Eg

    ```bash
    root@a0baacccc8e5:/# apt install nano
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    E: Unable to locate package nano
    ```

    ***Note: if you get the above error run `apt update` first and then `apt install [package-name]`***

    ```bash
    root@a0baacccc8e5:/# apt install nano
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    Suggested packages:
      hunspell
    The following NEW packages will be installed:
      nano
    0 upgraded, 1 newly installed, 0 to remove and 4 not upgraded.
    Need to get 269 kB of archives.
    After this operation, 868 kB of additional disk space will be used.
    Get:1 http://archive.ubuntu.com/ubuntu focal/main amd64 nano amd64 4.8-1ubuntu1 [269 kB]
    Fetched 269 kB in 3s (104 kB/s)
    debconf: delaying package configuration, since apt-utils is not installed
    Selecting previously unselected package nano.
    (Reading database ... 4121 files and directories currently installed.)
    Preparing to unpack .../nano_4.8-1ubuntu1_amd64.deb ...
    Unpacking nano (4.8-1ubuntu1) ...
    Setting up nano (4.8-1ubuntu1) ...
    update-alternatives: using /bin/nano to provide /usr/bin/editor (editor) in auto mode
    update-alternatives: warning: skip creation of /usr/share/man/man1/editor.1.gz because associated file /usr/share/man/man1/nano.1.gz (of link group editor) doesn't exist
    update-alternatives: using /bin/nano to provide /usr/bin/pico (pico) in auto mode
    update-alternatives: warning: skip creation of /usr/share/man/man1/pico.1.gz because associated file /usr/share/man/man1/nano.1.gz (of link group pico) doesn't exist
    ```

  - Description : Install a package
- `apt remove [package-name]`
  - Description : Removes the package
- `pwd`
  - Eg
  
    ```bash
    root@a0baacccc8e5:/# pwd
    /
    ```

  - Description : Print working directory
- `../..`
  - Description : Gets you to the root directory
- `cd ~`
  - Descirption : Gets you to the home directory
- `mkdir [directory-name]`
  - Description : Creates a directory
- `mv [current-name-of-the-file-or-folder-to-be-moved-or-renamed] [new-name-of-the-file-or-folder]`
  - Eg

    ```bash
    root@a0baacccc8e5:/# mv hello.txt /etc
    root@a0baacccc8e5:/# mv hello.txt hello-docker.txt
    ```

  - Description : Move or rename a file or folder
- `touch [name-of-the-file]`
  - Description : Creates a file. It is possible to create more than one file by passing more than one file name with a space between the file names.
- `rm [name-of-the-file]`
  - Eg

    ```bash
    //by file name
    root@a0baacccc8e5:/# rm file1.txt file2.txt

    //using a pattern
    root@a0baacccc8e5:/# rm file*
    ```

  - Description : Removes the files
- `rm -r [name-of-the-directory]`
  - Description : Removes the directory and its content recursively
- `cat [name-of-the-file]`
  - Eg

    ```bash
    root@a0baacccc8e5:/# cat hello-world.py
    print("Hello World")
    ```

  - Discription : Displays the content of the file.
- `more [name-of-the-file]`
  - Eg

    ```bash
    root@a0baacccc8e5:/# more etc/adduser.conf
    # /etc/adduser.conf: `adduser' configuration.
    # See adduser(8) and adduser.conf(5) for full documentation.

    # The DSHELL variable specifies the default login shell on your
    # system.
    DSHELL=/bin/bash

    //removed for brevity

    # If USERGROUPS is "no", then USERS_GID should be the GID of the group
    # `users' (or the equivalent group) on your system.
    --More--(56%)
    ```

  - Discription : Displays the content of the file. With `more` command we can scroll down(we cannot scroll up). Press `Space` key to goto the next page. Press `Enter` key to go one line at a time.
- `less [name-of-the-file]`
  - Discription : Displays the content of the file. With `less` command we can scroll up and down with ⬆ and ⬇ keys. Press `Space` key to goto the next page. Press `Enter` key to go one line at a time. Press `q` key to exit.
- `head -n [number-of-lines] [name-of-the-file]`
  - Discription : Displays the ***first*** few lines of the file.
- `tail -n [number-of-lines] [name-of-the-file]`
  - Discription : Displays the ***last*** few lines of the file.
- `>` (Redirection operator for output)
  - Eg

    ```bash
    root@a0baacccc8e5:/# cat name-of-the-source-file > name-of-the-destination-file
    root@a0baacccc8e5:/# echo hello > hello.txt
    root@a0baacccc8e5:/# ls -l /etc > etc-directory-files.txt
    ```

  - Description : `>` is the redirection operator. It is used to redirect the source file contents to the destination file.
- `<` (Redirection operator for input)
- `ls -a`
  - Eg

    ```bash
    root@d07966a74bb7:~# ls -a
    .  ..  .bashrc  .profile  docker  test
    root@d07966a74bb7:~#
    ```

  - Description : Displays all the files and the folders including the hidden ones.
- `grep` (Global Regular Expression Print)
  - Eg

    ```bash
    root@a0baacccc8e5:~# grep hello hello-world.py
    root@a0baacccc8e5:~# grep -i hello hello-world.py
    print("Hello World")

    //we can search in more thn one file
    root@a0baacccc8e5:~# grep hello file1.txt file2.txt

    //we can search using a pattern
    root@a0baacccc8e5:~# grep hello file*

    //we can search inside a directory recursively
    root@a0baacccc8e5:~# grep -i -r hello .

    //same as above
    root@a0baacccc8e5:~# grep -ir hello .
    ```

    ***Note: Searches are case-sensitive. Add `-i` to remove case sensivity***
- `find`
  - Eg

    ```bash
    root@a0baacccc8e5:~# find
    .
    ./.profile
    ./.bashrc
    ./hello-world.py
    ./etc-directory-files.txt
    ./.local
    ./.local/share
    ./.local/share/nano

    //filter by directories
    root@a0baacccc8e5:~# find -type d
    .
    ./.local
    ./.local/share
    ./.local/share/nano

    //search for files
    root@a0baacccc8e5:~# find -type f
    ./.profile
    ./.bashrc
    ./hello-world.py
    ./etc-directory-files.txt

    //search for files which start with hello
    root@a0baacccc8e5:~# find -type f -name "hello*"
    ./hello-world.py
    ```

  - Description : When executed with out any arguments, displays all the files and directories in the current directory recursively
- Chaining commands
  - Eg

    ```bash
    root@d07966a74bb7:~# mkdir docker; cd docker; echo done
    done
    root@d07966a74bb7:~/docker#

    root@d07966a74bb7:~# mkdir docker && cd docker && echo done
    mkdir: cannot create directory 'docker': File exists
    root@d07966a74bb7:~#

    root@d07966a74bb7:~# mkdir docker || echo "directory already exists"
    mkdir: cannot create directory 'docker': File exists
    directory already exists
    root@d07966a74bb7:~#
    ```

    ***Note: Use `&&` to stop executing the next command if the current command fails. Use `||` operator to execte the next command if the previous command fails.***
- `|`
  - Eg

    ```bash
    root@d07966a74bb7:~# ls -1 /bin | less
    ```
  
  - Description : Use to gets the output from a command and send it to the next command. In the above command, we dont need to pass a argument for the less command because it is pass by the first command.
- `\`
  - Eg

    ```bash
    root@d07966a74bb7:~# mkdir test;\
    > cd test;\
    > echo "done"
    done
    root@d07966a74bb7:~/test#
    ```

  - Description : Breaks a long command in to multiple lines
- `printenv`
  - Eg

    ```bash
    root@d07966a74bb7:~# printenv
    HOSTNAME=d07966a74bb7
    PWD=/root/test
    HOME=/root
    LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
    TERM=xterm
    SHLVL=1
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    _=/usr/bin/printenv
    OLDPWD=/root
    root@d07966a74bb7:~#
    ```

  - Description : Prints the environment variables and their values. By passing the variable name to the command(eg. `printenv PATH`), we can retrieve the value for that variable. Alternatively, we can use the `$` with the `echo` command to view value of an environment variable(eg. `echo $PATH`).
- `export`
  - Eg

    ```bash
    root@d07966a74bb7:~/test# export DB_USER=Dilan
    root@d07966a74bb7:~/test# echo $DB_USER
    Dilan
    root@d07966a74bb7:~/test#
    ```
  
  - Description : Sets an envrionment variable. This variable is only available in the current terminal session. To write permanent variables, goto home directory and add the variable in to the `.bashrc` file(eg. `echo DB_USER=Dilan >> .bashrc`). Enviornment variables in the `.bashrc` files is only available in the next terminal session. You can use the `source` command to reload the `.bashrc` file(eg. `source .bashrc`). We need to execute this from the home directory. If we are not in the home directory we need to give the absolute path(eg. `source ~/.bashrc`).
- `ps`
  - Eg

    ```bash
    root@d07966a74bb7:~# ps
    PID TTY          TIME CMD
      1 pts/0    00:00:00 bash
    280 pts/0    00:00:00 ps
    root@d07966a74bb7:~#
    ```
  
  - Description : Displays all the running processes. Use the `kill [process-id]` to kill a process(eg `kill 280`).
- `useradd`, `usermod` and `userdel`
  - Eg

    ```bash
    //this user will be stored in a config file in the /etc directory
    root@a0baacccc8e5:~# useradd -m john
    root@a0baacccc8e5:~# cat /etc/passwd
    root:x:0:0:root:/root:/bin/bash
    daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
    bin:x:2:2:bin:/bin:/usr/sbin/nologin
    sys:x:3:3:sys:/dev:/usr/sbin/nologin
    sync:x:4:65534:sync:/bin:/bin/sync
    games:x:5:60:games:/usr/games:/usr/sbin/nologin
    man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
    lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
    mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
    news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
    uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
    proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
    www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
    backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
    list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
    irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
    gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
    nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
    _apt:x:100:65534::/nonexistent:/usr/sbin/nologin
    john:x:1000:1000::/home/john:/bin/sh
    ```

    ***Note: `x` in `john:x:1000:1000::/home/john:/bin/sh` means password is stored somewhere else. `1000` is the user id. `/home/john` is the home directory of the user***

    ```bash
    root@a0baacccc8e5:~# usermod -s /bin/bash john
    root@a0baacccc8e5:~# cat /etc/passwd
    root:x:0:0:root:/root:/bin/bash
    daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
    bin:x:2:2:bin:/bin:/usr/sbin/nologin
    sys:x:3:3:sys:/dev:/usr/sbin/nologin
    sync:x:4:65534:sync:/bin:/bin/sync
    games:x:5:60:games:/usr/games:/usr/sbin/nologin
    man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
    lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
    mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
    news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
    uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
    proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
    www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
    backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
    list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
    irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
    gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
    nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
    _apt:x:100:65534::/nonexistent:/usr/sbin/nologin
    john:x:1000:1000::/home/john:/bin/bash
    ```

    ```bash
    //to login to ubuntu as another user in docker
    PS C:\Users\dilan> docker exec -it -u john [container-id] bash
    john@a0baacccc8e5:/$
    ```

  - Description : These commands are used to add modify and delete users. We can also use `adduser` command to add a user(eg. `adduser bob`). This command uses `useradd` command under the hood. `adduser` command is more interactive than the old command.
- `groupadd`, `groupmod` and `groupdel`
  - Description : These commands are used to add modify and delete users groups.
- file permission
  - Eg

    ```bash
    drwxr-xr-x 2 root root 4096 Apr 13 13:28 docker
    -rw-r--r-- 1 root root 4107 Apr 11 07:42 etc-directory-files.txt
    ```

  - First letter `d`(directory) or `-`(file) specify if its a file or a directory.
  - Next 9 characters are divided in to three groups. First group represents the premission for the user who owns the file. Second group represent the permission for the group who owns the file. Third group represents permission for everyone else.
  - USer `chmod u`(user), `chmod g`(group) or `chmod o`(other) commands to modify the permissions(eg. `chmod u+x deploy.sh`). `+` adds a permission. `-` removes a permission.

## Other

- Linux is case sensitive
- Uses `/` to seperate files and directories
- `apt` - Advanced Package Tool
- `Ctrl + l` clears the window
- Linux file system
  - `bin` - Binaries or programes
  - `boot` - All the files related to booting
  - `dev` - Files related to devices
  - `etc` - Contains configuration files
  - `home` - Home directory for users are stored
  - `root` - Home directory of the root user. only the root user can access this directory
  - `lib` - Library files such as software library dependencies
  - `var` - Contains files which are updated frequently such as log files and application data
  - `proc` - Files that represent running processes
- `Ctrl + w` Removes a whole word.

## How to get it started with Docker

- `docker pull ubuntu` and `docker run -it ubuntu` or `docker run -it ubuntu`

## Credits

- [Codewithmosh - The Ultimate Docker Course](https://codewithmosh.com/courses/the-ultimate-docker-course/)