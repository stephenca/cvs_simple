#!/bin/bash

CVSBIN=$1
CVSDIR=$2
TMPL="repository"
REP="cvsdir"
LOCAL=":local:$CVSDIR/$REP"

echo $CVSBIN
echo $LOCAL

$CVSBIN -d $LOCAL init 
cd $PWD/../$TMPL/Add
$CVSBIN -d $LOCAL import -m "" Add V1 E2

cd $PWD

