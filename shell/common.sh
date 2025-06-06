#!/bin/bash
# Common shell configuration for both bash and zsh

# PATH management - remove duplicates
_path=""
for _p in $(echo $PATH | tr ':' ' '); do
  case ":${_path}:" in
    *:"${_p}":* )
      ;;
    * )
      if [ "$_path" ]; then
        _path="$_path:$_p"
      else
        _path=$_p
      fi
      ;;
  esac
done
PATH=$_path
unset _p
unset _path

# Add Homebrew paths
PATH=$PATH:/opt/homebrew/bin/
PATH=$PATH:/opt/homebrew/anaconda3/bin/

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# ls color configuration
if [ "$(uname)" = 'Darwin' ]; then
    # macOS - optimized for dark background
    export LSCOLORS=Gxfxcxdxbxegedabagacad
    alias ls='ls -G'
    
    # Use GNU coreutils if available (brew install coreutils)
    if command -v gls > /dev/null; then
        alias ls='gls --color=auto'
    fi
else
    # Linux - use standard colors
    alias ls='ls --color=auto'
fi

# Use dircolors if available for standard color support
if command -v dircolors > /dev/null; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

# Basic aliases
alias sl='ls'
alias sudu='sudo du -h --max-depth=1 .'

# exa (modern ls replacement)
if type exa > /dev/null 2>&1; then
    alias ll='exa'
fi
