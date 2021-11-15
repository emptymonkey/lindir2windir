# lindir2windir

lindir2windir is a super simple POSIX shell script to use in WSL for translating path names from one environment to the other. 

## lindir2windir.sh
Examples:
```
➤ lindir2windir.sh '/mnt/c/Program Files (x86)/WindowsPowerShell'
C:/Program Files (x86)/WindowsPowerShell

➤ lindir2windir.sh -e '/mnt/c/Program Files (x86)/WindowsPowerShell'
C:/Program\ Files\ \(x86\)/WindowsPowerShell

➤ lindir2windir.sh .
C:/Program Files (x86)/WindowsPowerShell
```
## windir2lindir.sh
If you call the script by the name windir2lindir.sh then it will translate the other direction. To do this, setup a soft link:
```
➤ ln -s lindir2windir.sh windir2lindir.sh
```
Examples:
```
➤ windir2lindir.sh 'C:\Program Files\PowerShell'
/mnt/c/Program\ Files/PowerShell
```
