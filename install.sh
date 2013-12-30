#/bin/sh
pushd .
cd ~
rm .bashrc
ln -s ~/repo/dotfiles/bashrc .bashrc
rm .bash_profile
ln -s ~/repo/dotfiles/bash_profile .bash_profile
popd

