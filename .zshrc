_THEME_READY=1
PLUGIN_BASE_DIR="$HOME/.zsh"

current_pretty_dir="%(4~.%-1~/…/%2~.%3~)"

git_include(){
  mkdir -p "$PLUGIN_BASE_DIR" > /dev/null 2>&1
  GIT_URL=$1
  FOLDER=$2
  SCRIPT=$3
  EXECUTE_FILE="$PLUGIN_BASE_DIR/$FOLDER/$SCRIPT"
  if [ -d "$PLUGIN_BASE_DIR/$FOLDER" ]; then
    [[ $AUTOUPDATE -eq 1 ]] && echo "Updating $FOLDER" && git -C "$PLUGIN_BASE_DIR/$FOLDER" pull
  else
    git clone "$GIT_URL" "$PLUGIN_BASE_DIR/$FOLDER"
  fi
}
# Plugins

if command -v fzf &> /dev/null; then
  git_include "https://github.com/Aloxaf/fzf-tab" "fzf-tab" "fzf-tab.plugin.zsh"
  git_include "https://github.com/unixorn/fzf-zsh-plugin.git" "fzf-zsh-plugin" "fzf-zsh-plugin.plugin.zsh"
fi

git_include "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"
git_include "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions" "zsh-autosuggestions.zsh"
git_include "https://github.com/zsh-users/zsh-completions.git" "zsh-completions" ""

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


alias history="history 0"

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

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

# Defined shortcut keys: [Esc] [Esc]
zle -N sudo-command-line
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac



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

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'
    alias vi='vim'

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

if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias)
 fi

if command -v eza &> /dev/null; then
    # general use
    #
    alias ls='eza'                                                          # ls
    alias lS='eza -1'                                                              # one column, just names
    alias lt='eza --tree --level=2'                                         # tree

    eza --git > /dev/null 2>&1

    if [ $? -eq 0 ]; then
      alias l='eza -lbF --git'                                                # list, size, type, git
      alias ll='eza -lbGF --git'                                             # long list
      alias llm='eza -lbGd --git --sort=modified'                            # long list, modified date sort
      alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
      alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
    else
      # e.g. kali
      alias l='eza -lbF'                                                # list, size, type, git
      alias ll='eza -lbGF'                                             # long list
      alias llm='eza -lbGd --sort=modified'                            # long list, modified date sort
      alias la='eza -lbhHigUmuSa --time-style=long-iso --color-scale'  # all list
      alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --color-scale' # all + extended list
    fi

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

alias commit="git commit -a -m"
alias todo="grep 'TODO\:\|REVIEW\:\|BUG\:\|NOTE\:\|FIXME\:\|XXX\:\|HACK\:\|UX\:' * -nri"

open(){
  if [[ -z "$@" ]]; then
    xdg-open .
  else
    xdg-open "$@"
  fi
}

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

_theme_set_term_title(){
  local str_ready=
  [ $_THEME_READY -eq 0 ] && str_ready="⧗ "

  if [[ SHOW_HOST_INFO -eq 1 ]]; then
    #echo "SSH!"
    TERM_TITLE=$'\e]0;@%m:$str_ready$current_pretty_dir\a'
  else
    TERM_TITLE=$'\e]0;$str_ready$current_pretty_dir\a'
  fi

  print -Pnr -- "$TERM_TITLE"
}
_theme_set_term_title

preexec() {
  # exec timer
  timer=$(($(date +%s%0N)/1000000))
  _THEME_READY=0
  _theme_set_term_title
}

precmd() {
    # Print the previously configured title
    _theme_set_term_title
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
    _THEME_READY=1
    _theme_set_term_title
}

eval "$(starship init zsh)"
