#!/

for f in `find -mindepth 1 -prune -type f -name '.*'`;
do
    echo ${f}
    HERE=`pwd`
    if [ -e ~/${f} ]; then
        if [[ -L ~/${f} ]]; then
            echo "found a symbolic link"
            # do nothing if it is symbolic
        else
            echo "file ${f} exists; append the content of ${f}"
            cp ~/${f} ~/${f}.bak
            echo "## AUTOMATICALLY APPENDED BY SCRIPT: (FROM MY DOTFILES)" >> ~/${f}
            cat ${f} >> ~/${f}
        fi
    else
        ln -sfn ${HERE}/${f} ~/${f}
        echo "created symbolic link ${f}"
    fi
done
