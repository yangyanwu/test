# Set a Bash prompt that includes the exit code of the last executed command.
#
# Setup: paste the content of this file to ~/.bashrc, or source this file from
# ~/.bashrc (make sure ~/.bashrc is sourced by ~/.bash_profile or ~/.profile)
#
#------------------------------------------------------------------------------#
# define some colors
RESET='\[\e[0m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
BOLD_GRAY='\[\e[1;30m\]'
YELLOW="\[\033[0;33m\]"

parse_git_branch() {
	# parse git branch
	PS_BRANCH=''
	if [ -d .svn ]; then
		PS_BRANCH="(svn r$(svn info | awk '/Revision/{print $2}'))"
		return
	elif [ -f _FOSSIL_ -o -f .fslckout ]; then
		PS_BRANCH="(fossil $(fossil status | awk '/tags/{print $2}')) "
		return
	fi
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	PS_BRANCH="(git ${ref#refs/heads/}) "
}

# Command that Bash executes just before displaying a prompt
export PROMPT_COMMAND=set_prompt

set_prompt() {
	local EXIT="$?" # store current exit code

	# longer list of codes here: https://unix.stackexchange.com/a/124408

	local TIMENOW=$(date +"%r")
	if [[ $EXIT -eq 0 ]]; then
		local STATUS="${GREEN}[√] ${TIMENOW}${RESET} "      # Add green for success
	else
		local STATUS="${RED}[${EXIT}] ${TIMENOW}${RESET} " # Add red if exit code non 0
	fi

	parse_git_branch
	PS_GIT="$YELLOW\$PS_BRANCH"	

	# this is the default prompt for 
	PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \w ${PS_GIT} $STATUS\n\$\[\033[00m\] "
}
