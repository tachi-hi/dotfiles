# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# ls color
autoload -Uz colors
colors
if [ "$(uname)" = 'Darwin' ]; then
    alias ls='ls -G'
    PS1='%n@%m %~$ '
    PROMPT="%{$fg[yellow]%}%n@"
    PROMPT+="%{$fg[blue]%}%m "
    PROMPT+="%{$fg[magenta]%}%~ "
    PROMPT+="%{$reset_color%}$ "
else
    alias ls='ls --color=auto'
fi

# language
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


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
PATH=$PATH:/opt/homebrew/anaconda3/bin/

homedir=~
eval homedir=$homedir
venv=$homedir/.venv
PATH=$PATH:$venv
#python3.11 -m venv $venv
source $venv/bin/activate