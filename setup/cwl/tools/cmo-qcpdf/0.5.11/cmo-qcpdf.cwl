#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#

doap:release:
- class: doap:Version
  doap:name: cmo-qcpdf
  doap:revision: 0.5.11
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

# This tool description was generated automatically by argparse2cwl ver. 0.3.1
# To generate again: $ cmo_qcpdf -o FILENAME --generate_cwl_tool
# Help: $ cmo_qcpdf  --help_arg2cwl

cwlVersion: v1.0

class: CommandLineTool
baseCommand:
- cmo_qcpdf
- --version
- 0.5.11
id: cmo-qcpdf

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 4000
    coresMin: 1

doc: |
  None

inputs:
  globdir:
    type: string
    inputBinding:
      prefix: --globdir

  md_metrics_files:
    type:
      type: array
      items:
        type: array
        items: File

  clstats1:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  clstats2:
    type:
      type: array
      items:
        type: array
        items:
          type: array
          items: File

  files:
    type:
      type: array
      items: File

  gcbias_files:
    type: string
    default: "*.hstmetrics"
    inputBinding:
      prefix: --gcbias-files

  mdmetrics_files:
    type: string
    default: "*.md_metrics"
    inputBinding:
      prefix: --mdmetrics-files

  insertsize_files:
    type: string
    default: "*.ismetrics"
    inputBinding:
      prefix: --insertsize-files

  hsmetrics_files:
    type: string
    default: "*.hsmetrics"
    inputBinding:
      prefix: --hsmetrics-files

  qualmetrics_files:
    type: string
    default: "*.quality_by_cycle_metrics"
    inputBinding:
      prefix: --qualmetrics-files

  fingerprint_files:
    type: string
    default: "*_FP_base_counts.txt"
    inputBinding:
      prefix: --fingerprint-files

  trimgalore_files:
    type: string
    default: "*_cl.stats"
    inputBinding:
      prefix: --trimgalore-files

  file_prefix:
    type: string
    inputBinding:
      prefix: --file-prefix

  fp_genotypes:
    type: File
    inputBinding:
      prefix: --fp-genotypes

  pairing_file:
    type: File
    inputBinding:
      prefix: --pairing-file

  grouping_file:
    type: File
    inputBinding:
      prefix: --grouping-file

  request_file:
    type: File
    inputBinding:
      prefix: --request-file

  minor_contam_threshold:
    type: ['null', float]
    default: 0.02

    inputBinding:
      prefix: --minor-contam-threshold

  major_contam_threshold:
    type: ['null', float]
    default: 0.55

    inputBinding:
      prefix: --major-contam-threshold

  duplication_threshold:
    type: ['null', int]
    default: 80

    inputBinding:
      prefix: --duplication-threshold

  cov_warn_threshold:
    type: ['null', int]
    default: 200

    inputBinding:
      prefix: --cov-warn-threshold

  cov_fail_threshold:
    type: ['null', int]
    default: 50

    inputBinding:
      prefix: --cov-fail-threshold

outputs:
  qc_files:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
            return inputs.file_prefix + "*";
        }