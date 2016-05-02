# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# ls color
if [ "$(uname)" = 'Darwin' ]; then
#    export LSCOLORS=exfxcxdxbxegedabagacad # default
    export LSCOLORS=Egfxcxdxbxegedabagacad
    alias ls='ls -G'
else
    eval `dircolors ~/.colorrc`
    alias ls='ls --color=auto'
fi

# PS1
export PS1="[\[\e[33;1m\]\u\[\e[00m\]@\H \[\e[35;1m\]\w/\[\e[00m\]]\$ "
