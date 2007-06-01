#!/bin/bash

CVSDIR=$1
TMPL="repository"
REP="cvsdir"
LOCAL=":local:$CVSDIR/$REP"

PWD=`pwd`
cd $PWD/t

echo $TMPL
echo $LOCAL

cvs -d $LOCAL init 
cd $PWD/../$TMPL/Add
cvs -d $LOCAL import -m "" Add V1 E2

cd $PWD

