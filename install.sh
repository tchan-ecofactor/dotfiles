#/bin/sh
pushd . >& /dev/null
EXCLUDED_FILENAMES_DELIMITED_BY_DOUBLE_UNDERSCORES="__install.sh__"
DOTFILES=~/repo/dotfiles
cd ${DOTFILES}
for f in *
do
  FILENAME_WRAPPED_BY_DOUBLE_UNDERSCORES="__${f}__"
  if [ "${EXCLUDED_FILENAMES_DELIMITED_BY_DOUBLE_UNDERSCORES/$FILENAME_WRAPPED_BY_DOUBLE_UNDERSCORES}" = "${EXCLUDED_FILENAMES_DELIMITED_BY_DOUBLE_UNDERSCORES}" ]; then
  	echo Linking .${f}
    rm -f ~/.${f}
    ln -s ${DOTFILES}/${f} ~/.${f}
  fi
done
echo Done
popd >& /dev/null
