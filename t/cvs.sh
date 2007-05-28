#!/bin/bash

PWD=$1
TMPL="repository"
REP="cvsdir"
LOCAL=":local:$PWD/$REP"

echo $TMPL
echo $LOCAL

cvs -d $LOCAL init 
cd $PWD/../$TMPL/Add
cvs -d $LOCAL import -m "" Add V1 E2

