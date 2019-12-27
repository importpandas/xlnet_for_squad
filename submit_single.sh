#!/bin/bash


QUEUE="2080ti"
NTASKS_PER_NODE=1
GPUS_PER_NODE=1
NODES=1
CPUS_PER_TASK=3
SHELL_PATH=""
TIME=$(date +%y_%m_%d_%H:%M:%S)
OUTPUT_DIR=""

POSITIONAL=()                                                                                                                                                                                                      
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--shell-path)
    SHELL_PATH=$2
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

SHELL_NAME=${SHELL_PATH%.*}
SHELL_NAME=${SHELL_NAME##*/}

if [ -z "${OUTPUT_DIR}" ];then
    OUTPUT_DIR="output/${SHELL_NAME}_$TIME"
fi

echo "run shell \"${SHELL_NAME}\""
echo "gpus per node ${GPUS_PER_NODE}"

srun -p ${QUEUE} -c ${CPUS_PER_TASK} -o log/${SHELL_NAME}_$TIME.output \
    -e log/${SHELL_NAME%}_$TIME.error \
    --ntasks-per-node=${NTASKS_PER_NODE} --gres=gpu:${GPUS_PER_NODE} \
    -N ${NODES} \
    sh ${SHELL_PATH} ${OUTPUT_DIR} ${POSITIONAL[@]} &
