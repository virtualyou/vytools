# command line prompt
# @ prompt: rc, user, partial-path (easily seen colors)
# in PuTTY title bar: user, host, full-path, git-branch-name when relevant
# optionally set VM_MONIKER

prompt_command() {
    local RC=$?
    # preserve set -x
    [[ "${-/x}" != "$-" ]] && local isX=true || local isX=false
    set +x

    local RESET="\[\033[0;39m\]"
    local GREEN="\[\033[0;32m\]"
    local CYAN="\[\033[0;36m\]"
    local BCYAN="\[\033[1;36m\]"
    local BLUE="\[\033[0;34m\]"
    local GRAY="\[\033[0;37m\]"
    local DKGRAY="\[\033[1;30m\]"
    local WHITE="\[\033[1;37m\]"
    local RED="\[\033[0;31m\]"
    local ORANGE="\[\033[0;36m\]"
    #local RED="\[\033[0;36m\]"

    # show only the last 2 parts of the working directory
    local WHO_WHERE=${SHLVL}:\\u
    if [ ! -z "$VM_MONIKER" ]; then
        WHO_WHERE+="@${VM_MONIKER}"
    fi
    local PWD_TAIL=$PWD
    if [ "$PWD" = "$HOME" ]; then
        PWD_TAIL='~'
    else
        local z="${PWD##*/}"       # last element
        local left="${PWD/\/$z/}"  # left of that
        local y="${left##*/}"      # second-to-last
        left="${PWD/$y$z/}"        # left of that
        if [ ! "$PWD" = "/$y/$z" ]; then
            PWD_TAIL="$y/$z"
        fi
    fi

    # distinguish root vs regular user
    local symbol=$
    if [[ $EUID -eq 0 ]]; then
        local symbol=#
    fi

    # omit domain from HOSTNAME here
    local TITLEBAR='\[\e]2;`printf "${USER}@${HOSTNAME%%.*}: ${PWD} $(git_branch)"`\a'

    unset BLAMO
    [[ $RC != 0 ]] && local BLAMO=$'!!!!!!!!!!!!!!!!!!!!\n'
    export PS1="\[${TITLEBAR}\]\
${ORANGE}\
${BLAMO}\
$RC\
${CYAN}[\
${BCYAN}${WHO_WHERE}\
${WHITE}:${PWD_TAIL}\
${BCYAN}:$(git_branch)\
${CYAN}]\
${RESET}$symbol "
    # restore set -x
    [[ $isX == true ]] && set -x
}

git_branch() {
    if [ -d .git ]; then # if we're in a Git repo, determine the current branch
        #/bin/echo "($(/usr/bin/sed 's|ref: refs/heads/||' .git/HEAD))"
        git symbolic-ref HEAD --short
    fi
}

if [ "$TERM" == 'xterm' ]; then # okay to use xterm ESC sequences
    if [ -x /etc/atis/_functions-prompt ]; then # not on a pipe
        PROMPT_COMMAND=prompt_command
        # pre-command
        trap 'printf "\033]0;%s@%s: %s #%s\007" "$USER" "$HOSTNAME" "$PWD$(git_branch)" "$BASH_COMMAND"' DEBUG
    fi
fi
