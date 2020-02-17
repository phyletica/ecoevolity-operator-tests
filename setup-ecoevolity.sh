#! /bin/bash

set -e

ecoevolity_commit="932c358ce"

if [ -n "$PBS_JOBNAME" ]
then
    source "${PBS_O_HOME}/.bash_profile"
    cd "$PBS_O_WORKDIR"
fi

if [ -n "$(uname -a | grep "hopper")" ]
then
    module load gcc/5.3.0
    module load cmake/3.7.1
fi

project_dir=""
this_dir=`dirname "$0"`
if [ "$this_dir" = "." ]
then
    project_dir="$(pwd)"
else
    cd "$this_dir"
    project_dir="$(pwd)"
fi

git clone https://github.com/phyletica/ecoevolity.git
cd ecoevolity
git checkout -b testing "$ecoevolity_commit"
./build.sh --prefix "$project_dir"
cd ..
rm -r ecoevolity
