# !/bin/bash 
VIM_ROOT=$HOME/.vim
RANDOM_NR=`shuf -i 1000-90000 -n 1`
INSTALL_ROOT=`pwd`

# Backup .vim directory
if [ -d $VIM_ROOT -o -L $VIM_ROOT ]; then
  VIM_NAME=$HOME/.vim_$RANDOM_NR
  echo -e "Backup $VIM_ROOT into $VIM_NAME"
  mv $VIM_ROOT $VIM_NAME
fi 
# Link from vim directory to "~"
cd 
ln -s $INSTALL_ROOT $VIM_ROOT
# Backup .vimrc file
if [ -f $HOME/.vimrc -o -L $HOME/.vimrc ]; then
  VIMRC_NAME=$HOME/.vimrc_$RANDOM_NR
  echo -e "Backup $HOME/.vimrc into $VIMRC_NAME"
  mv $HOME/.vimrc $VIMRC_NAME
fi
ln -s $VIM_ROOT/vimrc $HOME/.vimrc

if [ ! hash yum 2>/dev/null ]; then
  echo -e "Installing vim (Vi Improved) package from repository"
  sudo apt --yes install vim vim-gnome
  echo -e "Installing ctags"
  sudo apt --yes install ctags
  echo -e "Installing cscope"
  sudo apt --yes install cscope
  echo -e "Installing pip for python-based dpeendencies"
  sudo apt --yes install pip
  echo -e "Installing python dependencies"
  sudo pip install pdb pylint
else
  echo -e "Installing vim (Vi Improved) package from repository"
  sudo yum -y install vim vim-X11
  echo -e "Installing ctags"
  sudo yum -y install ctags
  echo -e "Installing cscope"
  sudo yum -y install cscope
fi

cd $VIM_ROOT 
echo -e "Initializing and checking out plugins submodules: "
git submodule init 
git submodule update 
git submodule foreach git checkout master
git submodule foreach git pull origin master
restore all submodules to the commit which is approved by last master commit
git submodule update --recursive 

echo -e "Installing vi_overlay" 
while true; do
  yn=y
  #automatically answer 'yes' when 'y' is passed as first parameter
  if [ "$1" != "y" ]; then 
    read -p "Do you wish to install vi_overlay (sudo priviledges are required)? [y/n]: " yn
  fi 
  case $yn in 
    [Yy]* ) echo -e "Yes selected";
      if [ -f /etc/alternatives/vi ]; then 
        sudo ln -sf /etc/alternatives/vi /usr/bin/vi.default
        echo -e "/usr/bin/vi.default uses now /etc/alternatives/vi..."
      fi
      if [ -f /etc/alternatives/vim ]; then 
        sudo ln -sf /etc/alternatives/vim /usr/bin/vim.default 
        echo -e "/usr/bin/vim.default uses now /etc/alternatives/vim..."
      fi
      if [ -f $HOME/.vim/vimscripts/vi_overlay ]; then 
        echo -e "Using $HOME/.vim/vimscripts/vi_overlay as bin..."
        sudo ln -sf $VIM_ROOT/vimscripts/vi_overlay /usr/bin/vi
        sudo ln -sf $VIM_ROOT/vimscripts/vi_overlay /usr/bin/vim 
        sudo chmod +x $VIM_ROOT/vimscripts/vi_overlay
      else 
        echo -e "WARNING!!! $HOME/.vim/vimscripts/vi_overlay does not exist..."
      fi
      echo -e "vi_overlay installed!!!!";
      break;;
    [Nn]* ) echo -e "No selected"; break;;
    * ) echo -e "Please select yes or no";;
  esac
done

