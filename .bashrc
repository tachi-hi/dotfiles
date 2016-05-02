# diff -> colordiff                                                                                                                                                                             
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi
