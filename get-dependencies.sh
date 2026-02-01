#!/bin/sh

set -eu

ARCH=$(uname -m)
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	aarch64) deb_arch=arm64;;
esac
DEB_LINK="https://github.com/FreeTubeApp/FreeTube/releases/download/v0.23.13-beta/freetube_0.23.13_beta_$deb_arch.deb"

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm pipewire \
	pipewire-jack

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package freetube

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi

echo "Getting app..."
echo "---------------------------------------------------------------"
if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

ar xvf /tmp/app.deb
tar -xvf ./data.tar.xz
rm -f ./*.xz
rm -rf ./usr/share/doc
mv -v ./usr ./AppDir
mv -v ./opt/FreeTube ./AppDir/bin
#mv -v ./opt ./AppDir/lib
#mkdir -p ./AppDir/bin
#ln -s ./AppDir/lib/Freetube/freetube ./AppDir/bin/freetube
cp -v ./AppDir/share/applications/freetube.desktop            ./AppDir
cp -v ./AppDir/share/icons/hicolor/scalable/apps/freetube.svg  ./AppDir/.DirIcon
cp -v ./AppDir/share/icons/hicolor/scalable/apps/freetube.svg  ./AppDir

awk -F'/' '/Location:/{print $(NF-1); exit}' /tmp/download.log > ~/version
