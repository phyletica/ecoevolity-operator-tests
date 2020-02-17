#!/bin/bash

set -e

if [ -n "$PBS_JOBNAME" ]
then
    source ${PBS_O_HOME}/.bash_profile
    cd $PBS_O_WORKDIR
fi

label_array=()
convert_labels_to_array() {
    local concat=""
    local t=""
    label_array=()

    for word in $@
    do
        local len=`expr "$word" : '.*"'`

        [ "$len" -eq 1 ] && concat="true"

        if [ "$concat" ]
        then
            t+=" $word"
        else
            word=${word#\"}
            word=${word%\"}
            label_array+=("$word")
        fi

        if [ "$concat" -a "$len" -gt 1 ]
        then
            t=${t# }
            t=${t#\"}
            t=${t%\"}
            label_array+=("$t")
            t=""
            concat=""
        fi
    done
}

burnin=101

bin_dir=""
this_dir=`dirname "$0"`
if [ "$this_dir" = "." ]
then
    bin_dir="$(pwd)"
else
    cd "$this_dir"
    bin_dir="$(pwd)"
fi
echo $bin_dir
project_dir="$(dirname "$bin_dir")"
echo $project_dir

ecoevolity_config_dir="${project_dir}/configs"
ecoevolity_output_dir="${project_dir}/ecoevolity-output"
cd "$ecoevolity_output_dir"

plot_dir="../ecoevolity-results"
mkdir -p "$plot_dir"

labels='-l "Bohol0" "Bohol"
-l "CamiguinSur0" "Camiguin Sur"
-l "root-Bohol0" "Bohol-Camiguin Sur Root"
-l "Palawan1" "Palawan"
-l "Kinabalu1" "Borneo"
-l "root-Palawan1" "Palawan-Borneo Root"
-l "Samar2" "Samar"
-l "Leyte2" "Leyte"
-l "root-Samar2" "Samar-Leyte Root"
-l "Luzon3" "Luzon 1"
-l "BabuyanClaro3" "Babuyan Claro"
-l "root-Luzon3" "Luzon-Babuyan Claro Root"
-l "Luzon4" "Luzon 2"
-l "CamiguinNorte4" "Camiguin Norte"
-l "root-Luzon4" "Luzon-Camiguin Norte Root"
-l "Polillo5" "Polillo"
-l "Luzon5" "Luzon 3"
-l "root-Polillo5" "Polillo-Luzon Root"
-l "Panay6" "Panay"
-l "Negros6" "Negros"
-l "root-Panay6" "Panay-Negros Root"
-l "Sibuyan7" "Sibuyan"
-l "Tablas7" "Tablas"
-l "root-Sibuyan7" "Sibuyan-Tablas Root"
-l "BabuyanClaro8" "Babuyan Claro"
-l "Calayan8" "Calayan"
-l "root-BabuyanClaro8" "Babuyan Claro-Calayan Root"
-l "SouthGigante9" "S. Gigante"
-l "NorthGigante9" "N. Gigante"
-l "root-SouthGigante9" "S. Gigante-N. Gigante Root"
-l "Lubang11" "Lubang"
-l "Luzon11" "Luzon"
-l "root-Lubang11" "Lubang-Luzon Root"
-l "MaestreDeCampo12" "Maestre De Campo"
-l "Masbate12" "Masbate"
-l "root-MaestreDeCampo12" "Maestre De Campo-Masbate Root"
-l "Panay13" "Panay 1"
-l "Masbate13" "Masbate"
-l "root-Panay13" "Panay-Masbate Root"
-l "Negros14" "Negros"
-l "Panay14" "Panay 2"
-l "root-Negros14" "Negros-Panay Root"
-l "Sabtang15" "Sabtang"
-l "Batan15" "Batan"
-l "root-Sabtang15" "Sabtang-Batan Root"
-l "Romblon16" "Romblon"
-l "Tablas16" "Tablas"
-l "root-Romblon16" "Romblon-Tablas Root"
-l "CamiguinNorte17" "Camiguin Norte"
-l "Dalupiri17" "Dalupiri"
-l "root-CamiguinNorte17" "Camiguin Norte-Dalupiri Root"'

convert_labels_to_array $labels

gzip -k -d *-state-run-1.log.gz

for config_name in "cyrtodactylus-pyp-discount-mixer" "cyrtodactylus-pyp-discount-mover" "cyrtodactylus-rjsw"
do
    pyco-sumchains run-?-${config_name}-state-run-1.log.gz > "${plot_dir}/pyco-sumchains-${config_name}.txt"
    if [ "$config_name" = "cyrtodactylus-rjsw" ]
    then
        ${bin_dir}/sumcoevolity -f -b $burnin -p "${plot_dir}/sumcoevolity-${config_name}-" run-?-${config_name}-state-run-1.log
    else
        ${bin_dir}/sumcoevolity -f -b $burnin -n 1000000 -p "${plot_dir}/sumcoevolity-${config_name}-" -c "${ecoevolity_config_dir}/${config_name}.yml" run-?-${config_name}-state-run-1.log
    fi
done

# Only needed unzipped log files for sumcoevolity
rm *-state-run-1.log

# make pretty single plots
# How I got these colors from matplotlib:
# import matplotlib
# v = matplotlib.cm.get_cmap("viridis")
# matplotlib.colors.rgb2hex(v(0.0))
connected_color="#440154"
# matplotlib.colors.rgb2hex(v(0.5))
maybe_color="#21918c"
# matplotlib.colors.rgb2hex(v(1.0))
not_color="#fde725"

cyrt_colors="$maybe_color $maybe_color $connected_color $not_color $not_color $connected_color $connected_color $maybe_color"
cyrt_drop_colors="$maybe_color $connected_color $not_color $not_color $connected_color $connected_color $maybe_color"
gekko_colors="$not_color $connected_color $not_color $connected_color $connected_color $maybe_color $connected_color $not_color"

time_ylabel=""
size_ylabel="Cyrtodactylus population"
comparison_colors="$cyrt_colors"
ignore_arg="-i Palawan1"

for config_name in "cyrtodactylus-pyp-discount-mixer" "cyrtodactylus-pyp-discount-mover" "cyrtodactylus-rjsw"
do
    pyco-sumtimes -f -z -x "Divergence time (substitutions/site)" -y "Island pair" -b $burnin --colors $comparison_colors "${label_array[@]}" -p "${plot_dir}/pyco-sumtimes-${config_name}-" run-?-${config_name}-state-run-1.log.gz
    if [ -n "$ignore_arg" ]
    then
        pyco-sumtimes -f -z -x "Divergence time (substitutions/site)" -y "Island pair" -b $burnin $ignore_arg --colors $cyrt_drop_colors "${label_array[@]}" -p "${plot_dir}/pyco-sumtimes-${config_name}-" run-?-${config_name}-state-run-1.log.gz
    fi
    pyco-sumsizes -f -y "$size_ylabel" -b $burnin "${label_array[@]}" -p "${plot_dir}/pyco-sumsizes-${config_name}-" run-?-${config_name}-state-run-1.log.gz
    pyco-sumevents -p "${plot_dir}/pyco-sumevents-${config_name}-" -f "${plot_dir}/sumcoevolity-${config_name}-sumcoevolity-results-nevents.txt"
done

# cd "$plot_dir"

# for p in pyco-*.pdf
# do
#     pdfcrop "$p" "$p"
# done

cd "$current_dir"
