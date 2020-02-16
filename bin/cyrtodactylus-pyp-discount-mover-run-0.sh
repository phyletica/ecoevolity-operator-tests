#! /bin/bash

if [ -n "$PBS_JOBNAME" ]
then
    source "${PBS_O_HOME}/.bash_profile"
    cd "$PBS_O_WORKDIR"
    module load gcc/5.3.0
fi

seed=258078965
run_number=0
output_dir="../ecoevolity-output"

if [ ! -d "$output_dir" ] 
then
    mkdir -p "$output_dir"
fi

prefix="${output_dir}/run-${run_number}-"
config_name="cyrtodactylus-pyp-discount-mover"
config_path="../configs/${config_name}.yml"
std_out_path="${prefix}${config_name}.out"

./ecoevolity --seed "$seed" --prefix "$prefix" --relax-missing-sites --relax-constant-sites --relax-triallelic-sites "$config_path" 1>"$std_out_path" 2>&1
