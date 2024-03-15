# PATH
export PATH=~/.pyenv/shims:$PATH
export PATH=~/.pyenv/bin:$PATH

# CUDA
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
export CUDA_HOME=/usr/local/cuda

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
    # PS1
    export PS1="\[\e[33;1m\]\u\[\e[00m\]@\H \[\e[35;1m\]\w/\[\e[00m\]\$ "
else
    # eval `dircolors ~/.colorrc`
    alias ls='ls --color=auto'
fi



# colied from http://qiita.com/key-amb/items/ce39b0c85b30888e1e3b
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

# alias
alias sl='ls'

if type exa > /dev/null; then
    echo 'using exa'
    alias ll='exa'
fi

PATH=$PATH:/opt/homebrew/bin/

alias sudu='sudo du -h --max-depth=1 .'