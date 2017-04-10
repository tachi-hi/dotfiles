#!/

for f in `find . -mindepth 1 -prune -type f -name '.*'`;
do
    echo ${f}
    HERE=`pwd`
    if [ -e ~/${f} ]; then
        if [[ -L ~/${f} ]]; then
            echo "found a symbolic link"
            # do nothing if it is symbolic
        else
            echo "file ${f} exists; append the content of ${f}"
            sed -n '/## AUTOMATICALLY APPENDED BY SCRIPT: (FROM MY DOTFILES)/q;p' ~/${f} > ~/${f}.bak
            cp ~/${f}.bak ~/${f}
            echo "## AUTOMATICALLY APPENDED BY SCRIPT: (FROM MY DOTFILES)" >> ~/${f}
            echo "#######################################################" >> ~/${f}
            echo "## CAUTION!!! DO NOT MANUALLY EDIT ANYTHING AFTER THIS LINE (MAY BE DELETED AUTOMATICALLY BY A SCRIPT)" >> ~/${f}
            cat ${f} >> ~/${f}
            echo "## CAUTION!!! DO NOT APPEND ANYTHING AFTER THIS LINE (MAY BE DELETED AUTOMATICALLY BY A SCRIPT)" >> ~/${f}
        fi
    else
        ln -sfn ${HERE}/${f} ~/${f}
        echo "created symbolic link ${f}"
    fi
done
