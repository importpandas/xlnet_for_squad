#!/bin/bash


QUEUE="gpu"
NTASKS_PER_NODE=1
GPUS_PER_NODE=1
NODES=1
CPUS_PER_TASK=3
SHELL_NAME=""
TIME=$(date +%y_%m_%d_%H:%M:%S)
OUTPUT_DIR=""

POSITIONAL=()                                                                                                                                                                                                      
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--shell-name)
    SHELL_NAME=$2
    shift 2
    ;;
    -q|--queue)
    QUEUE=$2
    shift 2 #past argument and value
    ;;
    -n|--ntasks-per-node)
    NTASKS_PER_NODE=$2
    shift 2 
    ;;
    -g|--gpus-per-node)
    GPUS_PER_NODE=$2
    shift 2
    ;;
    -c|--cpus-per-task)
    CPUS_PER_TASK=$2
    shift 2
    ;;
    -N|--nodes)
    NODES=$2
    shift 2
    ;;
    -o|--output-dir)
    OUTPUT_DIR=$2
    shift 2
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z "${OUTPUT_DIR}" ];then
    OUTPUT_DIR="output/${SHELL_NAME%.*}_$TIME"
fi

echo "gpus per node ${GPUS_PER_NODE}"

bert_encoder_lr=(1e-3 7e-4 5e-4 3e-4 1e-4)
alpha_loss=(0.1 0.3 0.5 0.7 1.0)
for lr in ${bert_encoder_lr[@]}
do
    for alpha in ${alpha_loss[@]};do
        sbatch -p ${QUEUE} -c ${CPUS_PER_TASK} -o log/${SHELL_NAME%.*}_${lr}_${alpha}.output \
        -e log/${SHELL_NAME%.*}_${lr}_${alpha}.error \
        --ntasks-per-node=${NTASKS_PER_NODE} --gres=gpu:${GPUS_PER_NODE} \
        -N ${NODES} \
        shell/${SHELL_NAME} ${OUTPUT_DIR} $lr $alpha &
        sleep 2
    done
done

