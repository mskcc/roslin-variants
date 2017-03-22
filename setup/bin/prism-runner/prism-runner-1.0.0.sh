#!/bin/bash

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_DATA_PATH ] || \
   [ -z $PRISM_INPUT_PATH ] || [ -z $PRISM_SINGULARITY_PATH ]
then
    echo "Some necessary paths are not correctly configured."
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_DATA_PATH=${PRISM_DATA_PATH}"
    echo "PRISM_INPUT_PATH=${PRISM_INPUT_PATH}"
    echo "PRISM_SINGULARITY_PATH=${PRISM_SINGULARITY_PATH}"    
    exit 1
fi

# defaults
PIPELINE_VERSION=${PRISM_VERSION}
DEBUG_OPTIONS=""
RESTART_OPTIONS=""
RESTART_JOBSTORE=""
BATCH_SYSTEM="singleMachine"
OUTPUT_DIRECTORY=${PRISM_INPUT_PATH}/chunj/outputs

usage()
{
cat << EOF

USAGE: `basename $0` [options]

Prism Pipeline Runner

OPTIONS:

   -v      Pipeline version (default=${PIPELINE_VERSION})
   -w      Workflow filename (*.cwl)
   -i      Input filename (*.yaml)
   -b      Batch system ("singleMachine", "lsf", "mesos")
   -o      Output directory (default=${OUTPUT_DIRECTORY})
   -r      Restart the workflow with the given Job Store
   -d      Enable debugging

EXAMPLE:

   `basename $0` -v 1.0.0 -w module-1.cwl -i inputs-module-1.yaml
   `basename $0` -v test  -w cmo-bwa-mem.cwl -i inputs-cmo-bwa-mem.yaml

EOF
}


while getopts “v:w:i:b:o:r:d” OPTION
do
    case $OPTION in
        v) PIPELINE_VERSION=$OPTARG ;;
        w) WORKFLOW_FILENAME=$OPTARG ;;
        i) INPUT_FILENAME=$OPTARG ;;
        b) BATCH_SYSTEM=$OPTARG ;;
        o) OUTPUT_DIRECTORY=$OPTARG ;;
        r) RESTART_JOBSTORE=$OPTARG; RESTART_OPTIONS="--restart" ;;
        d) DEBUG_OPTIONS="--logDebug --cleanWorkDir never" ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $WORKFLOW_FILENAME ] || [ -z $INPUT_FILENAME ]
then
    usage
    exit 1
fi

# create output directory
mkdir -p ${OUTPUT_DIRECTORY}

#fixme: check if input file exists?


# handle batch system options
case $BATCH_SYSTEM in

    singleMachine)
        BATCH_SYS_OPTIONS="--batchSystem singleMachine"
        ;;

    lsf)
        BATCH_SYS_OPTIONS="--batchSystem lsf --stats"
        ;;

    mesos)
        echo "Unsupported right now."
        exit 1
        ;;

    *)
        usage
        exit 1
        ;;
esac


# override CMO_RESOURC_CONFIG only while cwltoil is running
export CMO_RESOURCE_CONFIG="${PRISM_BIN_PATH}/pipeline/${PRISM_VERSION}/prism_resources.json"

if [ -z $RESTART_JOBSTORE ]
then
    # create a new UUID for job
    job_uuid=`python -c 'import uuid; print str(uuid.uuid1())'`
else
    # we're doing a restart - use the supplied uuid
    job_uuid=${RESTART_JOBSTORE}
fi

jobstore_path="${PRISM_BIN_PATH}/tmp/jobstore-${job_uuid}"

printf "\n---> JOBSTORE = ${job_uuid}\n"

# run cwltoil
cwltoil \
    ${PRISM_BIN_PATH}/pipeline/${PIPELINE_VERSION}/${WORKFLOW_FILENAME} \
    ${PRISM_INPUT_PATH}/chunj/${INPUT_FILENAME} \
    --jobStore file://${jobstore_path} \
    --defaultDisk 10G \
    --preserve-environment PATH PRISM_DATA_PATH PRISM_BIN_PATH PRISM_INPUT_PATH PRISM_SINGULARITY_PATH CMO_RESOURCE_CONFIG \
    --no-container \
    --disableCaching \
    --logFile ${OUTPUT_DIRECTORY}/${job_uuid}.log \
    --workDir ${PRISM_BIN_PATH}/tmp \
    --outdir ${OUTPUT_DIRECTORY} ${RESTART_OPTIONS} ${BATCH_SYS_OPTIONS} ${DEBUG_OPTIONS}

# revert CMO_RESOURCE_CONFIG
unset CMO_RESOURCE_CONFIG

printf "\n<--- JOBSTORE = ${job_uuid}\n\n"