#!/bin/bash
for d in CSE141pp-DJR CSE141pp-LabPython ; do
    (cd $d;
     py.test -s $(find src -name '*.py' | grep -v '#' ) $@
    )
done
    
