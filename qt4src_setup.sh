#!/bin/sh

# fix for error message from Vagrant, but it may still show up
if `tty -s`; then
 mesg n
fi

# set xtuple source directory
XTUPLE_DIR=/home/vagrant/dev/xtuple/

# handy little function from install_script
cdir() {
  echo "Changing directory to $1"
  cd $1
}

die() {
  local RESULT=63
  if [ $# -gt 0 -a $(( $1 + 0 )) -ne 0 ] ; then
    RESULT=$1
    shift
  fi
  [ $# -gt 0 ] && echo $*
  exit $RESULT
}

usage() {
  echo $PROG -h
  echo $PROG [ -p postgresversion ] [ -d qtversion ]
}

while getopts "hp:q:" OPT ; do
  case $OPT in
    h) usage
       exit 0
       ;;
    p) PGVER=$OPTARG
       ;;
    q) QTVER=$OPTARG
       ;;
  esac
done

# install git
echo "Installing Git"
sudo apt-get install git -y

# this is a temporary fix for the problem where Windows
# cannot translate the symlinks in the repository
echo "Creating symlink to lib folder"
cdir /home/vagrant/dev/xtuple/lib/                      || die
rm module                                               || die
ln -s ../node_modules/ module                           || die
git update-index --assume-unchanged module              || die

echo "Creating symlink to application folder"
cdir /home/vagrant/dev/xtuple/enyo-client/application   || die
rm lib                                                  || die
ln -s ../../lib/ lib                                    || die
git update-index --assume-unchanged lib                 || die

cdir $XTUPLE_DIR                                        || die
echo "Beginning install script"                         || die
bash scripts/install_xtuple.sh -d $PGVER                || die

echo "Adding Vagrant PostgreSQL Access Rule"
for PGDIR in /etc/postgresql/* ; do
  echo "host all all  0.0.0.0/0 trust" | sudo tee -a $PGDIR/main/pg_hba.conf
done

echo "Restarting Postgres Database"
sudo service postgresql restart

##begin qtdev wizardry
cdir /home/vagrant/dev
sudo apt-get install -q -y libfontconfig1-dev libkrb5-dev libfreetype6-dev    \
               libx11-dev libxcursor-dev libxext-dev libxfixes-dev libxft-dev \
               libxi-dev libxrandr-dev libxrender-dev gcc make
sudo apt-get install -q -y --no-install-recommends \
              ubuntu-desktop unity-lens-applications unity-lens-files \
              gnome-panel firefox firefox-gnome-support

wget http://download.qt-project.org/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz
tar xvf qt-everywhere-opensource-src-4.8.6.tar.gz
cdir qt-everywhere-opensource-src-4.8.6
echo "Configuring Qt"
./configure -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg \
            -plugin-sql-psql -plugin-sql-odbc -plugin-sql-sqlite   \
            -I /usr/local/pgsql/include -L /usr/local/pgsql/lib    \
            -lkrb5 -webkit -nomake examples -nomake demos          \
            -confirm-license -fontconfig -opensource -continue
echo "Building Qt 4.8.6--GO GET SOME COFFEE IT'S GOING TO BE A WHILE"
make -j4                                || die 1 "Qt didn't build"

echo "Installing Qt 4.8.6--Get another cup"
sudo make -j1 install                   || die 1 "Qt didn't install"

echo "Compiling OPENRPT dependency"
cdir /home/vagrant/dev/qt-client/openrpt
/usr/local/Trolltech/Qt-4.8.6/bin/qmake || die 1 "openrpt didn't qmake"
make -j4                                || die 1 "openrpt didn't build"
echo "Compiling CSVIMP dependency"
cdir ../csvimp
/usr/local/Trolltech/Qt-4.8.6/bin/qmake || die 1 "csvimp didn't qmake"
make -j4                                || die 1 "csvimp didn't build"
echo "Compiling qt-client itself"
cdir ..
/usr/local/Trolltech/Qt-4.8.6/bin/qmake || die 1 "qt-client didn't qmake"
make -j4                                || die 1 "qt-client didn't build"

cdir /home/vagrant
for STARTUPFILE in .profile .bashrc ; do
  echo '[[ "$PATH" =~ Qt-4.8.6 ]] || export PATH=/usr/local/Trolltech/Qt-4.8.6/bin:$PATH' >> $STARTUPFILE
done

echo "Qt development environment finished!"
echo "To get started cd /home/vagrant/dev/qt-client qmake then make to build xTuple desktop!"
##end qtdev wizardry

echo "The xTuple Server install script is done!"

cdir /home/vagrant
for STARTUPFILE in .profile .bashrc ; do
  echo '[[ "$PATH" =~ Qt-4.8.6 ]] || export PATH=/usr/local/Trolltech/Qt-4.8.6/bin:$PATH' >> $STARTUPFILE
done

echo "Qt development environment finished!"
echo "To get started cd /home/vagrant/dev/qt-client qmake then make to build xTuple desktop!"
##end qtdev wizardry

echo "The xTuple Server install script is done!"
