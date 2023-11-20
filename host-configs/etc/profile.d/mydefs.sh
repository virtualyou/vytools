# vars

# MacOS
#export EDITOR='sublime_text'
#export HISTTIMEFORMAT="%d/%m/%y %T "

# WSL - Windows System Linux (Ubuntu 22.04)
export EDITOR='sublime_text'

# aliases

# erase the current command line, (eg, keeping passwords out of the history)
# Examples:
#   setpass pass123; discreet
#   discreet && setpass pass123
alias discreet='history -d $(($HISTCMD-1))'

# erase the previous command line from history, (and forgetthat itself)
alias forgetthat='history -d $(($HISTCMD-2)) && history -d $(($HISTCMD-1))'

# conveniences
alias ll='cd $PWD; ls -al --color=auto'
alias envs='env|sort'
alias ggrep='grep --color --exclude-dir=.git'

git config --global color.ui auto

if [ $EUID -eq 0 ]; then
    # because having root-owned files in a source tree is a major hassle
    alias git='echo "If you really want to run git as root, use /bin/git"'
fi
