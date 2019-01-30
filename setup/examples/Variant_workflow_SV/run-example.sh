#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Variant_workflow_SV_sample_mapping.txt \
    -p Variant_workflow_SV_sample_pairing.txt \
    -g Variant_workflow_SV_sample_grouping.txt \
    -r Variant_workflow_SV_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Variant_workflow_SV \
    --inputs inputs.yaml \
    --path . \
    --workflow VariantWorkflowSV \
    --batch-system singleMachine \
    --test-mode \
    --foreground-mode
