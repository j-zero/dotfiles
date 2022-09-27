# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# config
#
ENABLE_BATTERY=0
ENABLE_BATTERY_ON_CHARGE=0
ENABLE_CLOCK=1
ENABLE_GIT_INFO=1

ENABLE_PRETTY_PATH=1
ENABLE_PRETTY_PATH_GIT_DIR=1

ENABLE_EXEC_TIME=1

# always show hostname, not in ssh sessions alone
ENABLE_HOST_ALWAYS=0

TWO_LINE_PROMPT_CHAR=
ONE_LINE_PROMPT_CHAR="%F{blue}➜%f "

PROMPT_ALTERNATIVE=oneline
NEWLINE_BEFORE_PROMPT=yes

DIR_CHAR="%F{cyan}/%f"
MAX_FOLDER_DEPTH=255

#HOME_SYMBOL=🏠
HOME_SYMBOL="~"

prompt_user="$(whoami)"
# logo for users
[[ "$(whoami)" == "ringej" || "$(whoami)" == "johannes" ]] && prompt_user=Ɽ

# Skull emoji for root terminal
[ "$EUID" -eq 0 ] && prompt_user=💀

[ -f $HOME/.zshrc.settings ] && . $HOME/.zshrc.settings

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# timer variable
elapsed=0

SHOW_INFO=1

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action
#
# Defined shortcut keys: [Esc] [Esc]
zle -N sudo-command-line
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

zle -N toggle_prompt_info
bindkey ^H toggle_prompt_info

zle -N toggle_pretty_dir
bindkey ^G toggle_pretty_dir


# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

configure_prompt() {

  # Right-side prompt with exit codes and background processes
  RPROMPT=$'%(?.%F{green}✓%f. %? %F{red}%B⨯%b%f)%(1j. %j %F{yellow}%B⚙%b%f.) %F{cyan}$(exec_time)%f'

  case "$PROMPT_ALTERNATIVE" in
      twoline)
        PROMPT=$'%F{%(#.red.green)}┌─%F{%(#.red.green)}[ $(clock)$(battery_info)$(host_info)$(git_info)%F{%(#.red.green)} ]%f $(directory)\n%F{%(#.red.green)}└─%(#.%F{red}.%F{blue})'$prompt_user'%b%f $TWO_LINE_PROMPT_CHAR'
          ;;
      oneline)
        PROMPT=$'%F{%(#.red.green)}[ $(clock)$(battery_info)$(host_info)$(git_info)%F{%(#.red.green)} ]%f %(#.%F{red}$prompt_user.%F{blue}$prompt_user)%b%f $(directory) $ONE_LINE_PROMPT_CHAR'
          ;;
    esac
    unset prompt_symbol
}

TMOUT=1

TRAPALRM() {
    zle reset-prompt
}


if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    configure_prompt

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=white,underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}$prompt_user: %~\a'
    ;;
*)
    ;;
esac

function preexec() {
  # exec timer
  timer=$(($(date +%s%0N)/1000000))
}

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi

    # exec timer
    if [ $timer ]; then
    now=$(($(date +%s%0N)/1000000))
    elapsed=$(($now-$timer))

    unset timer
  fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    #alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

if command -v exa &> /dev/null; then
    # general use
    alias ls='exa'                                                          # ls
    alias l='exa -lbF --git'                                                # list, size, type, git
    alias ll='exa -lbGF --git'                                             # long list
    alias llm='exa -lbGd --git --sort=modified'                            # long list, modified date sort
    alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
    alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
    # specialty views
    alias lS='exa -1'                                                              # one column, just names
    alias lt='exa --tree --level=2'                                         # tree
fi


if command -v bat &> /dev/null; then
  alias less='bat'
  alias more='bat'
  alias cat='bat --paging=never'
fi
# Kali
if command -v batcat &> /dev/null; then
  alias less='batcat'
  alias more='batcat'
  alias cat='batcat --paging=never'
fi


alias todo="grep 'TODO\:\|REVIEW\:\|BUG\:\|NOTE\:\|FIXME\:\|XXX\:\|HACK\:\|UX\:' * -nri"


# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi


### HELPER FUNCTIONS

directory(){
  # shorten after 6 folders
 #echo "%F{white}%(6~.%-1~/…/%4~.%5~)%f"
 #get_pretty_path
  if [[ $ENABLE_PRETTY_PATH -eq 1 ]]; then
    get_pretty_path;
  else
    echo "%F{white}%(6~.%-1~/…/%4~.%5~)%f"
  fi
}
exec_time(){
  if [[ $ENABLE_EXEC_TIME -eq 1 ]]; then
    local MS=$(($elapsed%1000))
    local T=$(($elapsed/1000))

    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))

    (( $D > 0 )) && echo -n "%F{cyan}$D%F{white}d%f"
    (( $H > 0 )) && echo -n "%F{cyan}$H%F{white}h%f"
    (( $M > 0 )) && echo -n "%F{cyan}$M%F{white}m%f"
    #(( $D > 0 || $H > 0 || $M > 0 )) && echo ""
    echo -n "%F{cyan}$S%F{white}.%F{cyan}$(printf '%03d' $MS)%F{white}s%f"
  fi
}
toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}

toggle_prompt_info(){
    if [[ $SHOW_INFO -eq 1 ]]; then
      SHOW_INFO=0
    else
      SHOW_INFO=1
    fi
    #configure_prompt
    zle reset-prompt
}

toggle_pretty_dir(){
    if [[ $ENABLE_PRETTY_PATH_GIT_DIR -eq 1 ]]; then
      ENABLE_PRETTY_PATH_GIT_DIR=0
    else
      ENABLE_PRETTY_PATH_GIT_DIR=1
    fi
    #configure_prompt
    zle reset-prompt
}

battery_info() {
    if [[ $SHOW_INFO -eq 1 && $ENABLE_BATTERY -eq 1 ]]; then

      local battery_percent=$(upower -i $(upower -e | grep '/battery') | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)
      local battery_state=$(upower -i $(upower -e | grep '/battery') | grep --color=never -E state|xargs|cut -d' ' -f2|sed s/%//)

      [ -z $battery_state ] && return

      if [[ $battery_percent -gt 50 ]]; then
        battery_color="green"
      elif [[ $battery_percent -lt 15 ]]; then
        battery_color="red"
      else
        battery_color="yellow"
      fi

      if [[ $battery_state == "charging" || $battery_state == "fully-charged" ]]; then
        if [[ $ENABLE_BATTERY_ON_CHARGE -eq 1 ]]; then
          BAT_STATE_STR="🔌%F{$battery_color}$battery_percent%f%%"
          echo " $BAT_STATE_STR%f"
        fi
      else
          BAT_STATE_STR="🔋%F{$battery_color}$battery_percent%f%%"
          echo " $BAT_STATE_STR%f"
      fi
    fi
}
host_info(){
  if  [[ $SHOW_INFO -eq 1 ]]; then
   if [[ -n "$SSH_CLIENT" ]] || [ -n "$SSH_TTY" ] || [[ $ENABLE_HOST_ALWAYS -eq 1 ]]; then
     echo "%F{237} | %F{blue}@%F{white}%m%f"
   fi
  fi
}
function clock(){
  if [[ $ENABLE_CLOCK -eq 1 ]]; then
    echo "%f%D{%H:%M:%S}"
  fi
}

git_info() {
  # based on https://joshdick.net/2017/06/08/my_git_prompt_for_zsh_revisited.html
  if [[ $SHOW_INFO -eq 1 && $ENABLE_GIT_INFO -eq 1 ]]; then
    # Exit if not inside a Git repository
    ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

    # Git branch/tag, or name-rev if on detached head
    local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

    local AHEAD="%F{red}⇡NUM%f"
    local BEHIND="%F{cyan}⇣NUM%f"
    local MERGING="%F{magenta}⚡︎%f"
    local UNTRACKED="%F{red}●%f"
    local MODIFIED="%F{yellow}●%f"
    local STAGED="%F{green}●%f"

    local -a DIVERGENCES
    local -a FLAGS

    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
      DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
    fi

    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
      DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
    fi

    local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
      FLAGS+=( "$MERGING" )
    fi

    if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
      FLAGS+=( "$UNTRACKED" )
    fi

    if ! git diff --quiet 2> /dev/null; then
      FLAGS+=( "$MODIFIED" )
    fi

    if ! git diff --cached --quiet 2> /dev/null; then
      FLAGS+=( "$STAGED" )
    fi

    local -a GIT_INFO
    GIT_INFO+=( " %F{240} $GIT_LOCATION" )
    [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
    [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
    [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
    #GIT_INFO+=( "" )
    echo "${(j: :)GIT_INFO}%f"
  fi

}

# ------------------------------------------------------------------------------
# Description
# -----------
#
# sudo or sudo -e (replacement for sudoedit) will be inserted before the command
#
# ------------------------------------------------------------------------------
# Authors
# -------
#
# * Dongweiming <ciici123@gmail.com>
# * Subhaditya Nath <github.com/subnut>
# * Marc Cornellà <github.com/mcornella>
# * Carlo Sala <carlosalag@protonmail.com>
#
# ------------------------------------------------------------------------------

__sudo-replace-buffer() {
  local old=$1 new=$2 space=${2:+ }

  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

sudo-command-line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi

  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
        sudo\ *) __sudo-replace-buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      __sudo-replace-buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) __sudo-replace-buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
  }
}
function get_rel_git_path(){
    local targetFolder=$(git rev-parse --show-toplevel)
    local git_workdir=$(basename $targetFolder)
    local currentFolder=$(pwd)
    local result=

    while [ "$currentFolder" != "$targetFolder" ];do
      if [ -z $result ]; then
        result="%F{white}$(basename $currentFolder)%f" # no ending slash
      else
        result="$(basename $currentFolder)$DIR_CHAR$result"
      fi
      currentFolder=$(dirname $currentFolder)
    done

    echo "%F{237}%B%F{cyan}$git_workdir%f%b$DIR_CHAR$result"
}
function get_pretty_path(){

    # git stuff
    local git_dir=
    local is_in_git=0
    git rev-parse --is-inside-work-tree > /dev/null 2>&1 && is_in_git=1

    local counter=0
    local is_named_folder=0
    local depth=${#${PWD//[!\/]}} # path depth
    
    if [[ $is_in_git -eq 1 && $ENABLE_PRETTY_PATH_GIT_DIR -eq 1 ]]; then
      get_rel_git_path
      return
    fi

    [[ $is_in_git -eq 1 ]] && git_dir=$(git rev-parse --show-toplevel)

    #echo "DEBUG git: $is_in_git"
    #echo "DEBUG git_dir: $git_dir"
    #echo "DEBUG HOME: $HOME"
    #echo "DEBUG depth: $depth"

    local targetFolder=/
    local currentFolder=$(pwd)
    local result=
    local is_shortening=0

    while [ "$currentFolder" != "$targetFolder" ];do

    #echo $counter
    #echo "DEBUG currentFolder: $currentFolder"
    local folderName=$(basename $currentFolder)
      if [ "$currentFolder" = "$HOME" ]; then # is current git directory
        #echo "DEBUG HOME!!"
        if [ -z $result ]; then
            result="$HOME_SYMBOL"
        else
            result="$HOME_SYMBOL$DIR_CHAR$result"
        fi
        currentFolder=$(dirname "$HOME")
        is_named_folder=1
      elif [ ! -z $git_dir ] && [ "$currentFolder" = "$git_dir" ]; then # is current git directory
        result="%F{237}%B%F{cyan}$folderName%b%f$DIR_CHAR$result"
      elif [ -z $result ]; then
        result="%F{white}$folderName%f" # current dir no ending slash

      else
        if [ $depth -ne $MAX_FOLDER_DEPTH ] && [ $counter -lt $MAX_FOLDER_DEPTH ]; then
            result="$folderName$DIR_CHAR$result"
        else
            result="${folderName:0:1}…$DIR_CHAR$result"
            #result="$counter... $folderName$DIR_CHAR$result"
            #result="...$DIR_CHAR$result"
            is_shortening=1
            #currentFolder=$(dirname $currentFolder)
        fi
    fi
      currentFolder=$(dirname $currentFolder)
      ((counter++))
    done

    [[ "$is_named_folder" -eq 0 ]] && echo -n "$DIR_CHAR"
    echo "$result"
}


