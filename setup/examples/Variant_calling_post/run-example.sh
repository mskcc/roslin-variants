#!/bin/bash

pipeline_name=${ROSLIN_PIPELINE_NAME}
pipeline_version=${ROSLIN_PIPELINE_VERSION}

roslin_request_to_yaml.py \
    --pipeline ${pipeline_name}/${pipeline_version} \
    -m Variant_calling_post_sample_mapping.txt \
    -p Variant_calling_post_sample_pairing.txt \
    -g Variant_calling_post_sample_grouping.txt \
    -r Variant_calling_post_request.txt \
    -o . \
    -f inputs.yaml

roslin_submit.py \
    --name ${pipeline_name} \
    --version ${pipeline_version} \
    --id Variant_calling_post \
    --inputs inputs.yaml \
    --path . \
    --workflow VariantCallingPost \
    --batch-system singleMachine \
    --foreground-mode \
    --test-mode \
    --use_alignment_meta alignment-input-meta.json \
    --use_variant_calling_meta variant-calling-input-meta.json
