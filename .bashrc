# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

if [ "$(uname)" = 'Darwin' ]; then
#    export LSCOLORS=exfxcxdxbxegedabagacad # default
    export LSCOLORS=Egfxcxdxbxegedabagacad
    alias ls='ls -G'
else
    eval `dircolors ~/.colorrc`
    alias ls='ls --color=auto'
fi
