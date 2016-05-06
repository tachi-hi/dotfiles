# PATH
export PATH=~/.pyenv/shims:$PATH

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# ls color

if [ "$(uname)" = 'Darwin' ]; then
# a     black
# b     red
# c     green
# d     brown
# e     blue
# f     magenta
# g     cyan
# h     light grey
# A     bold black, usually shows up as dark grey
# B     bold red
# C     bold green
# D     bold brown, usually shows up as yellow
# E     bold blue
# F     bold magenta
# G     bold cyan
# H     bold light grey; looks like bright white
# x     default foreground or background
#    export LSCOLORS=exfxcxdxbxegedabagacad # default
#    export LSCOLORS=Egfxcxdxbxegedabagacad
    export LSCOLORS=HEADcxdxbxegedabagacad
    alias ls='ls -G'
else
    eval `dircolors ~/.colorrc`
    alias ls='ls --color=auto'
fi

# PS1
export PS1="\[\e[33;1m\]\u\[\e[00m\]@\H \[\e[35;1m\]\w/\[\e[00m\]\$ "
