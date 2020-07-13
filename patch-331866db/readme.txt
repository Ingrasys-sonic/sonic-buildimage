#!/bin/bash

PATCH_PATH=/tmp/patch-331866db


git clone https://github.com/ufispace-bytedance/sonic-buildimage.git sonic-buildimage-bytedance
cd sonic-buildimage-bytedance
make init
cp -rf ${PATCH_PATH}/* ./
make configure PLATFORM=barefoot
BLDENV=stretch make stretch
make target/sonic-barefoot.bin



