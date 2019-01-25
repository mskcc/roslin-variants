#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Proj_DEV_0003_sample_mapping.txt \
    -p Proj_DEV_0003_sample_pairing.txt \
    -g Proj_DEV_0003_sample_grouping.txt \
    -r Proj_DEV_0003_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Proj_DEV_0003_VariantCallingPost \
    --inputs inputs.yaml \
    --path . \
    --workflow VariantCallingPost \
    --batch-system singleMachine \
    --foreground-mode \
    --use_alignment_meta alignment-input-meta.json \
    --use_variant_calling_meta variant-calling-input-meta.json
