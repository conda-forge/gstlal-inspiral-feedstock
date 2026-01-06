#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./gnuscripts

set -ex

mkdir -p _build
pushd _build

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"
export GSTLAL_LIBS="-L${PREFIX}/lib -lgstlal -lgstlaltags -lgstlaltypes"
export LAL_LIBS="-L${PREFIX}/lib -llal"

# replace '/usr/bin/env python3' with '/usr/bin/python'
# so that conda-build will then replace it with the $PREFIX/bin
sed -i.tmp 's/\/usr\/bin\/env python3/\/usr\/bin\/python/g' ${SRC_DIR}/bin/gstlal_*

# ignore deprecation warning from distutils, it breaks ac_python_devel.m4
export PYTHONWARNINGS="${PYTHONWARNINGS},ignore:The distutils package:DeprecationWarning"

# configure
${SRC_DIR}/configure \
  --disable-massmodel \
  --enable-introspection=yes \
  --enable-gtk-doc=no \
  --enable-gtk-doc-html=no \
  --enable-gtk-doc-pdf=no \
  --prefix=${PREFIX} \
  --without-doxygen \
;

# build
make -j ${CPU_COUNT} V=1 VERBOSE=1

# install
make -j ${CPU_COUNT} V=1 VERBOSE=1 install
