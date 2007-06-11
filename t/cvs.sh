#!/bin/bash

CVSDIR=$1
TMPL="repository"
REP="cvsdir"
LOCAL=":local:$CVSDIR/$REP"

echo $TMPL
echo $LOCAL

$CVS_BIN -d $LOCAL init 
cd $PWD/../$TMPL/Add
$CVS_BIN -d $LOCAL import -m "" Add V1 E2

cd $PWD

