#!/bin/sh -e

# only execute anything if either
# - running under orb with package = orb
# - not running under opam at all
if [ "$ORB_BUILDING_PACKAGE" != "solo5-bindings-hvt" -a "$OPAM_PACKAGE_NAME" != "" ]; then
    exit 0;
fi

basedir=$(realpath "$(dirname "$0")"/../..)
tmpd=$basedir/_build/stage
rootdir=$tmpd/rootdir
bindir=$rootdir/usr/bin
debiandir=$rootdir/DEBIAN

trap 'rm -rf $tmpd' 0 INT EXIT

mkdir -p "$bindir" "$debiandir"

# stage app binaries
install $basedir/elftool/solo5-elftool $bindir/solo5-elftool
install $basedir/tenders/hvt/solo5-hvt $bindir/solo5-hvt

# install debian metadata
install -m 0644 $basedir/packaging/debian/control $debiandir/control
install -m 0644 $basedir/packaging/debian/changelog $debiandir/changelog
install -m 0644 $basedir/packaging/debian/copyright $debiandir/copyright

ARCH=$(dpkg-architecture -q DEB_TARGET_ARCH)
sed -i -e "s/^Architecture:.*/Architecture: ${ARCH}/" $debiandir/control

dpkg-deb --build $rootdir $basedir/solo5-hvt.deb
echo 'bin: [ "solo5-hvt.deb" ]' > $basedir/solo5-bindings-hvt.install
echo 'doc: [ "README.md" ]' >> $basedir/solo5-bindings-hvt.install
