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
  doap:name: gather-metrics
  doap:revision: 1.0.0
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
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Ronak H. Shah
    foaf:mbox: mailto:shahr2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org

cwlVersion: v1.0

class: Workflow
id: gather-metrics
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  bait_intervals: File
  target_intervals: File
  fp_intervals: File
  ref_fasta: string
  conpair_markers_bed: string
  genome: string
  tmp_dir: string
  gatk_jar_path: string
  bams:
    type: File[]
    secondaryFiles: ^.bai

outputs:

  as_metrics:
    type: File[]
    outputSource: gather_metrics/as_metrics_files
  hs_metrics:
    type: File[]
    outputSource: gather_metrics/hs_metrics_files
  insert_metrics:
    type: File[]
    outputSource: gather_metrics/is_metrics
  insert_pdf:
    type: File[]
    outputSource: gather_metrics/is_hist
  per_target_coverage:
    type: File[]
    outputSource: gather_metrics/per_target_coverage
  qual_metrics:
    type: File[]
    outputSource: gather_metrics/qual_metrics
  qual_pdf:
    type: File[]
    outputSource: gather_metrics/qual_pdf
  doc_basecounts:
    type: File[]
    outputSource: gather_metrics/doc_basecounts
  gcbias_pdf:
    type: File[]
    outputSource: gather_metrics/gcbias_pdf
  gcbias_metrics:
    type: File[]
    outputSource: gather_metrics/gcbias_metrics_files
  gcbias_summary:
    type: File[]
    outputSource: gather_metrics/gcbias_summary
  conpair_pileup:
    type: File[]
    outputSource: gather_metrics/conpair_pileup

steps:

  gather_metrics:
    in:
      bam: bams
      bait_intervals: bait_intervals
      target_intervals: target_intervals
      fp_intervals: fp_intervals
      ref_fasta: ref_fasta
      conpair_markers_bed: conpair_markers_bed
      genome: genome
      tmp_dir: tmp_dir
      gatk_jar_path: gatk_jar_path
    out: [as_metrics_files, hs_metrics_files, is_metrics, per_target_coverage, qual_metrics, qual_pdf, is_hist, doc_basecounts, gcbias_pdf, gcbias_metrics_files, gcbias_summary, conpair_pileup]
    scatter: [bam]
    scatterMethod: dotproduct
    run:
      class: Workflow
      id: gather-metrics-sample
      inputs:
        bam: File
        genome: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        tmp_dir: string
        gatk_jar_path: string
        conpair_markers_bed: string
        ref_fasta: string
      outputs:
        gcbias_pdf:
          type: File
          outputSource: gcbias_metrics/pdf
        gcbias_metrics_files:
          type: File
          outputSource: gcbias_metrics/out_file
        gcbias_summary:
          type: File
          outputSource: gcbias_metrics/summary
        as_metrics_files:
          type: File
          outputSource: as_metrics/out_file
        hs_metrics_files:
          type: File
          outputSource: hs_metrics/out_file
        per_target_coverage:
          type: File
          outputSource: hst_metrics/per_target_out
        is_metrics:
          type: File
          outputSource: insert_metrics/is_file
        is_hist:
          type: File
          outputSource: insert_metrics/is_hist
        qual_metrics:
          type: File
          outputSource: quality_metrics/qual_file
        qual_pdf:
          type: File
          outputSource: quality_metrics/qual_hist
        doc_basecounts:
          type: File
          outputSource: doc/out_file
        conpair_pileup:
          type: File
          outputSource: pileup/out_file
      steps:
        as_metrics:
          run: ../tools/cmo-picard.CollectAlignmentSummaryMetrics/2.9/cmo-picard.CollectAlignmentSummaryMetrics.cwl
          in:
            I: bam
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".asmetrics")}
            LEVEL:
              valueFrom: ${return ["null", "SAMPLE"]}
            TMP_DIR: tmp_dir
          out: [out_file]

        hs_metrics:
          run: ../tools/cmo-picard.CollectHsMetrics/2.9/cmo-picard.CollectHsMetrics.cwl
          in:
            BI: bait_intervals
            TI: target_intervals
            I: bam
            R: genome
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".hsmetrics")}
            LEVEL:
              valueFrom: ${ return ["null", "SAMPLE"];}
            TMP_DIR: tmp_dir
          out: [out_file, per_target_out]

        hst_metrics:
          run: ../tools/cmo-picard.CollectHsMetrics/2.9/cmo-picard.CollectHsMetrics.cwl
          in:
            BI: bait_intervals
            TI: target_intervals
            I: bam
            R: genome
            O:
              valueFrom: ${ return "all_reads_hsmerics_dump.txt"; }
            PER_TARGET_COVERAGE:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".hstmetrics")}
            LEVEL:
              valueFrom: ${ return ["ALL_READS"];}
            TMP_DIR: tmp_dir
          out: [per_target_out]

        insert_metrics:
          run: ../tools/cmo-picard.CollectInsertSizeMetrics/2.9/cmo-picard.CollectInsertSizeMetrics.cwl
          in:
            I: bam
            H:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".ismetrics.pdf")}
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".ismetrics")}
            LEVEL:
              valueFrom: ${ return ["null", "SAMPLE"];}
            TMP_DIR: tmp_dir
          out: [ is_file, is_hist]
        quality_metrics:
          run: ../tools/cmo-picard.CollectMultipleMetrics/2.9/cmo-picard.CollectMultipleMetrics.cwl
          in:
            I: bam
            PROGRAM:
              valueFrom: ${return ["null","MeanQualityByCycle"]}
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".qmetrics")}
            TMP_DIR: tmp_dir
          out: [qual_file, qual_hist]
        gcbias_metrics:
          run: ../tools/cmo-picard.CollectGcBiasMetrics/2.9/cmo-picard.CollectGcBiasMetrics.cwl
          in:
            I: bam
            R: genome
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbiasmetrics") }
            CHART:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbias.pdf")}
            S:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".gcbias.summary")}
            TMP_DIR: tmp_dir
          out: [pdf, out_file, summary]

        doc:
          run: ../tools/cmo-gatk.DepthOfCoverage/3.3-0/cmo-gatk.DepthOfCoverage.cwl
          in:
            input_file: bam
            intervals: fp_intervals
            reference_sequence: genome
            out:
              valueFrom: ${ return inputs.input_file.basename.replace(".bam", "_FP_base_counts.txt") }
            omitLocustable:
              valueFrom: ${ return true; }
            omitPerSampleStats:
              valueFrom: ${ return true; }
            read_filter:
              valueFrom: ${ return ["BadCigar"];}
            minMappingQuality:
              valueFrom: ${ return "10"; }
            minBaseQuality:
              valueFrom: ${ return "3"; }
            omitIntervals:
              valueFrom: ${ return true; }
            printBaseCounts:
              valueFrom: ${ return true; }
            java_temp: tmp_dir
          out: [out_file]
        pileup:
         run: ../tools/conpair/0.3.1/conpair-pileup.cwl
         in:
             bam: bam
             ref: ref_fasta
             gatk: gatk_jar_path
             java_temp: tmp_dir
             markers_bed: conpair_markers_bed
             java_xmx:
                 valueFrom: ${ return ["24g"]; }
             outfile:
                 valueFrom: ${ return inputs.bam.basename.replace(".bam", ".pileup"); }
         out: [out_file]