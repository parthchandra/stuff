#!/bin/bash

mkdir work
cd work
git clone https://github.com/parthchandra/stuff.git
ln -s ~/work/stuff/
ln -s ~/work/stuff/intellij intellij
ln -s ~/work/stuff/drill-conf .
cd ~
ln -s ~/work/stuff/vim/.vimrc .
ln -s ~/work/stuff/vim/.vim/colors/biogoo ./.vim/colors/biogoo
ln -s ~/work/stuff/vim/.vim/cvim.zip ./.vim/cvim.zip

