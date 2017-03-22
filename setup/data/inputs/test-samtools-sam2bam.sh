#!/bin/bash

prism-runner.sh \
    -w samtools/1.3.1/samtools-sam2bam.cwl \
    -i inputs-samtools-sam2bam.yaml \
    -d -b lsf 2>&1 | tee ./outputs/stdout.log