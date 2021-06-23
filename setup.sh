#!/bin/bash
for d in CSE141pp-DJR CSE141pp-LabPython ; do
    (cd $d;
     pip install -e .
    )
done
    
