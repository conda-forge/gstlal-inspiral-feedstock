#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# only link libraries we actually use
export GSL_LIBS="-L${PREFIX}/lib -lgsl"
export GSTLAL_LIBS="-L${PREFIX}/lib -lgstlal -lgstlaltags -lgstlaltypes"
export LAL_LIBS="-L${PREFIX}/lib -llal"

# replace '/usr/bin/env python{3}' with $PYTHON so that the builder
# invokes prefix replacement correctly
sed -i.tmp -E "s|/usr/bin/env python(3)?|${PYTHON}|g" ${SRC_DIR}/bin/gstlal_*

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
