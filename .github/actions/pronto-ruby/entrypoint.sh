#!/bin/sh -l

export PATH=$GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
pronto run -f ${1} -c "${2}"
