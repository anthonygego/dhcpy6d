#!/bin/sh
#
#
# simple build script for dhcpy6d
#
#

OS=unknown

function get_os {
    if [ -f /etc/debian_version ]
        then
            OS=debian
    elif [ -f /etc/redhat-release ]
        then
            OS=redhat
    fi
}

function create_manpages {
    if ! which rst2man
        then
            if [ "$OS" == "redhat" ]
                then
                    sudo yum -y install python-docutils
            fi
        fi

    echo "Creating manapages form RST files"
    rst2man doc/dhcpy6d.rst man/man8/dhcpy6d.8
    rst2man doc/dhcpy6d.conf.rst man/man5/dhcpy6d.conf.5
    rst2man doc/dhcpy6d-clients.conf.rst man/man5/dhcpy6d-clients.conf.5

}

# find out where script runs at
get_os

if [ "$OS" == "debian" ]
	then
		echo "Building .deb package"

        create_manpages

        debuild clean
		debuild binary-indep

elif [ "$OS" == "redhat" ]
	then
		echo "Building .rpm package"

        create_manpages


        if ! which rpmbuild
            then
                sudo yum -y install rpm-build
        fi


        TOPDIR=$HOME/dhcpy6d.$$
        SPEC=redhat/dhcpy6d.spec

		# create source folder for rpmbuild
		mkdir -p $TOPDIR/SOURCES
	
        # init needed in TOPDIR/SOURCES
        cp -pf redhat/init.d/dhcpy6d $TOPDIR/SOURCES

		# use setup.py sdist build output to get package name
		FILE=`python setup.py sdist --dist-dir $TOPDIR/SOURCES | grep "creating dhcpy6d-" | head -n1 | cut -d" " -f2`
		echo Source file: $FILE.tar.gz

        # version
        VERSION=`echo $FILE | cut -d"-" -f 2`

        # replace version in the spec file
        sed -i "s|Version:.*|Version: $VERSION|" $SPEC

		# finally build binary rpm
		rpmbuild -bb --define "_topdir $TOPDIR" $SPEC

		# get rpm file
		cp -f `find $TOPDIR/RPMS -name "$FILE-?.*noarch.rpm"` .

        # clean
        rm -rf $TOPDIR
else
	echo "Package creation is only supported on Debian and RedHat derivatives."
fi
