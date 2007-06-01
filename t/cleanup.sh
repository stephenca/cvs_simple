#!/bin/bash

CVSDIR=$1
REP="cvsdir"
PWD=`pwd`
cd $PWD/t

rm -rf $CVSDIR/$REP
rm -rf Add/
