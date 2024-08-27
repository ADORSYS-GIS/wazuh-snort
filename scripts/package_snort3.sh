#!/bin/bash

# Variables
PACKAGE_NAME="snort3-full"
VERSION="3.2.2.0-1"
ARCH=$1
WORK_DIR="/work"
DEBIAN_DIR="$WORK_DIR/$PACKAGE_NAME/DEBIAN"
INSTALL_DIR="$WORK_DIR/$PACKAGE_NAME/usr/local/snort"

# Create directory structure
mkdir -p "$DEBIAN_DIR"
mkdir -p "$INSTALL_DIR"

# Copy the .deb files into the installation directory
cp $WORK_DIR/*.deb "$INSTALL_DIR/"

# Create the control file
cat <<EOL > "$DEBIAN_DIR/control"
Package: $PACKAGE_NAME
Version: $VERSION
Section: base
Priority: optional
Architecture: $ARCH
Depends: flex (>= 2.6.4), libdaq (>= 3.0.15), luajit (>= 2.1.0), hwloc (>= 2.5.0), libdnet (>= 1.14), pcre (>= 8.45), zlib (>= 1.2.13)
Maintainer: Dylane Bengono <chameldylanebengono@gmail.com>
Description: Snort 3 with all dependencies bundled
 This package contains Snort 3 and all its dependencies.
EOL

# Add post-installation script to install dependencies
cat <<EOL > "$DEBIAN_DIR/postinst"
#!/bin/bash
dpkg -i /usr/local/snort/*.deb
apt-get install -f
EOL

chmod 755 "$DEBIAN_DIR/postinst"

# Build the .deb package
dpkg-deb --build "$WORK_DIR/$PACKAGE_NAME"

# Move the final .deb package to the output directory
mv "$WORK_DIR/${PACKAGE_NAME}.deb" "$WORK_DIR/packages/$ARCH/"
