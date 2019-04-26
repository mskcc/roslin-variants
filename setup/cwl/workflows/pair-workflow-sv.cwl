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
  doap:name: pair-workflow-sv
  doap:revision: 1.0.0
- class: doap:Version
  doap:name: cwl-wrapper
  doap:revision: 1.0.0

dct:creator:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org

dct:contributor:
- class: foaf:Organization
  foaf:name: Memorial Sloan Kettering Cancer Center
  foaf:member:
  - class: foaf:Person
    foaf:name: Christopher Harris
    foaf:mbox: mailto:harrisc2@mskcc.org
  - class: foaf:Person
    foaf:name: Jaeyoung Chun
    foaf:mbox: mailto:chunj@mskcc.org
  - class: foaf:Person
    foaf:name: Nikhil Kumar
    foaf:mbox: mailto:kumarn1@mskcc.org
  - class: foaf:Person
    foaf:name: Allan Bolipata
    foaf:mbox: mailto:bolipatc@mskcc.org


cwlVersion: v1.0

class: Workflow
id: pair-workflow-sv
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  db_files:
    type:
      type: record
      fields:
        refseq: File
        ref_fasta: string
        vep_path: string
        custom_enst: string
        vep_data: string
        hotspot_list: string
        hotspot_list_maf: File
        hotspot_vcf: string
        facets_snps: string
        bait_intervals: File
        target_intervals: File
        fp_intervals: File
        fp_genotypes: File
        conpair_markers: string
        conpair_markers_bed: string
        grouping_file: File
        request_file: File
        pairing_file: File
  hapmap:
    type: File
    secondaryFiles:
      - .idx
  dbsnp:
    type: File
    secondaryFiles:
      - .idx
  indels_1000g:
    type: File
    secondaryFiles:
      - .idx
  snps_1000g:
    type: File
    secondaryFiles:
      - .idx
  cosmic:
    type: File
    secondaryFiles:
      - .idx
  exac_filter:
    type: File
    secondaryFiles:
      - .tbi
  curated_bams:
    type:
      type: array
      items: File
    secondaryFiles:
      - ^.bai
  runparams:
    type:
      type: record
      fields:
        abra_scratch: string
        covariates: string[]
        emit_original_quals: boolean
        genome: string
        mutect_dcov: int
        mutect_rf: string[]
        num_cpu_threads_per_data_thread: int
        num_threads: int
        tmp_dir: string
        complex_tn: float
        complex_nn: float
        delly_type: string[]
        project_prefix: string
        opt_dup_pix_dist: string
        facets_pcval: int
        facets_cval: int
        abra_ram_min: int
        scripts_bin: string
        gatk_jar_path: string
  pair:
    type:
      type: array
      items:
        type: record
        fields:
          CN: string
          LB: string
          ID: string
          PL: string
          PU: string[]
          R1: string[]
          R2: string[]
          RG_ID: string[]
          adapter: string
          adapter2: string
          bwa_output: string

outputs:

  # bams & metrics
  bams:
    type: File[]
    secondaryFiles:
      - ^.bai
    outputSource: flatten_group/bams
  clstats1:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: flatten_group/clstats1
  clstats2:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: flatten_group/clstats2
  md_metrics:
    type: File[]
    outputSource: flatten_group/md_metrics
  as_metrics:
    type: File[]
    outputSource: flatten_group/as_metrics
  hs_metrics:
    type: File[]
    outputSource: flatten_group/hs_metrics
  insert_metrics:
    type: File[]
    outputSource: flatten_group/insert_metrics
  insert_pdf:
    type: File[]
    outputSource: flatten_group/insert_pdf
  per_target_coverage:
    type: File[]
    outputSource: flatten_group/per_target_coverage
  qual_metrics:
    type: File[]
    outputSource: flatten_group/qual_metrics
  qual_pdf:
    type: File[]
    outputSource: flatten_group/qual_pdf
  doc_basecounts:
    type: File[]
    outputSource: flatten_group/doc_basecounts
  gcbias_pdf:
    type: File[]
    outputSource: flatten_group/gcbias_pdf
  gcbias_metrics:
    type: File[]
    outputSource: flatten_group/gcbias_metrics
  gcbias_summary:
    type: File[]
    outputSource: flatten_group/gcbias_summary
  conpair_pileup:
    type: File[]
    outputSource: flatten_group/conpair_pileup

  # vcf
  mutect_vcf:
    type: File
    outputSource: flatten_group/mutect_vcf
  mutect_callstats:
    type: File
    outputSource: flatten_group/mutect_callstats
  vardict_vcf:
    type: File
    outputSource: flatten_group/vardict_vcf
  combine_vcf:
    type: File
    outputSource: flatten_group/combine_vcf
    secondaryFiles:
      - .tbi
  annotate_vcf:
    type: File
    outputSource: flatten_group/annotate_vcf
  # norm vcf
  vardict_norm_vcf:
    type: File
    outputSource: flatten_group/vardict_norm_vcf
    secondaryFiles:
      - .tbi
  mutect_norm_vcf:
    type: File
    outputSource: flatten_group/mutect_norm_vcf
    secondaryFiles:
      - .tbi
  # facets
  facets_png:
    type: File[]
    outputSource: flatten_group/facets_png
  facets_txt_hisens:
    type: File
    outputSource: flatten_group/facets_txt_hisens
  facets_txt_purity:
    type: File
    outputSource: flatten_group/facets_txt_purity
  facets_out:
    type: File[]
    outputSource: flatten_group/facets_out
  facets_rdata:
    type: File[]
    outputSource: flatten_group/facets_rdata
  facets_seg:
    type: File[]
    outputSource: flatten_group/facets_seg
  facets_counts:
    type: File
    outputSource: flatten_group/facets_counts
  # structural variants
  merged_file_unfiltered:
    type: File
    outputSource: flatten_group/merged_file_unfiltered
  merged_file:
    type: File
    outputSource: flatten_group/merged_file
  maf_file:
    type: File
    outputSource: flatten_group/maf_file
  portal_file:
    type: File
    outputSource: flatten_group/portal_file
  # maf
  maf:
    type: File
    outputSource: flatten_group/maf

steps:

  alignment:
    run:  ../modules/alignment.cwl
    in:
      db_files: db_files
      runparams: runparams
      single_pair: pair
      pairs:
        valueFrom: ${ return [inputs.single_pair] }
      hapmap: hapmap
      dbsnp: dbsnp
      indels_1000g: indels_1000g
      snps_1000g: snps_1000g
    out: [bams,clstats1,clstats2,md_metrics,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup,covint_list,covint_bed]
  variant_calling:
    run: ../modules/variant-calling.cwl
    in:
      runparams: runparams
      db_files: db_files
      bams: alignment/bams
      single_pair: pair
      pairs:
        valueFrom: ${ return [inputs.single_pair] }
      beds: alignment/covint_bed
      dbsnp: dbsnp
      cosmic: cosmic
    out: [combine_vcf, annotate_vcf, facets_png, facets_txt_hisens, facets_txt_purity, facets_out, facets_rdata, facets_seg, mutect_vcf, mutect_callstats, vardict_vcf, facets_counts, vardict_norm_vcf, mutect_norm_vcf]
  structural_variants:
    run: ../modules/structural-variants.cwl
    in:
      runparams: runparams
      db_files: db_files
      bams: alignment/bams
      single_pair: pair
      pairs:
        valueFrom: ${ return [inputs.single_pair] }
    out: [delly_sv,delly_filtered_sv,merged_file,merged_file_unfiltered,maf_file,portal_file]
  maf_processing:
    run: ../modules/maf-processing.cwl
    in:
      runparams: runparams
      db_files: db_files
      bams: alignment/bams
      single_pair: pair
      pairs:
        valueFrom: ${ return [inputs.single_pair] }
      annotate_vcf: variant_calling/annotate_vcf
      genome:
        valueFrom: ${ return inputs.runparams.genome }
      ref_fasta:
        valueFrom: ${ return inputs.db_files.ref_fasta }
      vep_path:
        valueFrom: ${ return inputs.db_files.vep_path }
      custom_enst:
        valueFrom: ${ return inputs.db_files.custom_enst }
      exac_filter: exac_filter
      vep_data:
        valueFrom: ${ return inputs.db_files.vep_data }
      tumor_sample_name:
        valueFrom: ${ return inputs.pair[0].ID }
      normal_sample_name:
        valueFrom: ${ return inputs.pair[1].ID }
      curated_bams: curated_bams
      hotspot_list:
        valueFrom: ${ return inputs.db_files.hotspot_list }
    out: [maf]
  flatten_group:
      in:
        bams_inputs: alignment/bams
        clstats1_inputs: alignment/clstats1
        clstats2_inputs: alignment/clstats2
        md_metrics_inputs: alignment/md_metrics
        as_metrics_inputs : alignment/as_metrics
        hs_metrics_inputs : alignment/hs_metrics
        insert_metrics_inputs : alignment/insert_metrics
        insert_pdf_inputs : alignment/insert_pdf
        per_target_coverage_inputs : alignment/per_target_coverage
        qual_metrics_inputs : alignment/qual_metrics
        qual_pdf_inputs : alignment/qual_pdf
        doc_basecounts_inputs : alignment/doc_basecounts
        gcbias_pdf_inputs : alignment/gcbias_pdf
        gcbias_metrics_inputs : alignment/gcbias_metrics
        gcbias_summary_inputs : alignment/gcbias_summary
        conpair_pileup_inputs : alignment/conpair_pileup
        mutect_vcf_inputs: variant_calling/mutect_vcf
        mutect_callstats_inputs: variant_calling/mutect_callstats
        vardict_vcf_inputs: variant_calling/vardict_vcf
        combine_vcf_inputs: variant_calling/combine_vcf
        annotate_vcf_inputs: variant_calling/annotate_vcf
        vardict_norm_vcf_inputs: variant_calling/vardict_norm_vcf
        mutect_norm_vcf_inputs: variant_calling/mutect_norm_vcf
        facets_png_inputs: variant_calling/facets_png
        facets_txt_hisens_inputs: variant_calling/facets_txt_hisens
        facets_txt_purity_inputs: variant_calling/facets_txt_purity
        facets_out_inputs: variant_calling/facets_out
        facets_rdata_inputs: variant_calling/facets_rdata
        facets_seg_inputs: variant_calling/facets_seg
        facets_counts_inputs: variant_calling/facets_counts
        merged_file_inputs: structural_variants/merged_file
        merged_file_unfiltered_inputs: structural_variants/merged_file_unfiltered
        maf_file_inputs: structural_variants/maf_file
        portal_file_inputs: structural_variants/portal_file
        maf_inputs: maf_processing/maf
      out: [ bams,clstats1,clstats2,md_metrics,mutect_vcf,mutect_callstats,vardict_vcf,combine_vcf,annotate_vcf,vardict_norm_vcf,mutect_norm_vcf,facets_png,facets_txt_hisens,facets_txt_purity,facets_out,facets_rdata,facets_seg,facets_counts,maf,as_metrics,hs_metrics,insert_metrics,insert_pdf,per_target_coverage,qual_metrics,qual_pdf,doc_basecounts,gcbias_pdf,gcbias_metrics,gcbias_summary,conpair_pileup,merged_file,merged_file_unfiltered,maf_file,portal_file]
      run:
          class: ExpressionTool
          id: flatten-group-pair
          requirements:
              - class: InlineJavascriptRequirement
          inputs:
            bams_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
              secondaryFiles:
                - ^.bai
            clstats1_inputs:
              type:
                type: array
                items:
                  type: array
                  items:
                    type: array
                    items: File
            clstats2_inputs:
              type:
                type: array
                items:
                  type: array
                  items:
                    type: array
                    items: File
            md_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            as_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            hs_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            insert_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            insert_pdf_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            per_target_coverage_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            qual_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            qual_pdf_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            doc_basecounts_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            gcbias_pdf_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            gcbias_metrics_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            gcbias_summary_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            conpair_pileup_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            mutect_vcf_inputs: File[]
            mutect_callstats_inputs: File[]
            vardict_vcf_inputs: File[]
            combine_vcf_inputs:
              type: File[]
              secondaryFiles:
              - .tbi
            annotate_vcf_inputs: File[]
            vardict_norm_vcf_inputs:
              type: File[]
              secondaryFiles:
                - .tbi
            mutect_norm_vcf_inputs:
              type: File[]
              secondaryFiles:
                - .tbi
            facets_png_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            facets_txt_hisens_inputs: File[]
            facets_txt_purity_inputs: File[]
            facets_out_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            facets_rdata_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            facets_seg_inputs:
              type:
                type: array
                items:
                  type: array
                  items: File
            facets_counts_inputs: File[]
            merged_file_inputs: File[]
            merged_file_unfiltered_inputs: File[]
            maf_file_inputs: File[]
            portal_file_inputs: File[]
            maf_inputs: File[]
          outputs:
            bams:
              type: File[]
              secondaryFiles:
                - ^.bai
            clstats1:
              type:
                type: array
                items:
                  type: array
                  items: File
            clstats2:
              type:
                type: array
                items:
                  type: array
                  items: File
            md_metrics: File[]
            as_metrics: File[]
            hs_metrics: File[]
            insert_metrics: File[]
            insert_pdf: File[]
            per_target_coverage: File[]
            qual_metrics: File[]
            qual_pdf: File[]
            doc_basecounts: File[]
            gcbias_pdf: File[]
            gcbias_metrics: File[]
            gcbias_summary: File[]
            conpair_pileup: File[]
            mutect_vcf: File
            mutect_callstats: File
            vardict_vcf: File
            combine_vcf:
              type: File
              secondaryFiles:
              - .tbi
            annotate_vcf: File
            vardict_norm_vcf:
              type: File
              secondaryFiles:
                - .tbi
            mutect_norm_vcf:
              type: File
              secondaryFiles:
                - .tbi
            facets_png: File[]
            facets_txt_hisens: File
            facets_txt_purity: File
            facets_out: File[]
            facets_rdata: File[]
            facets_seg: File[]
            facets_counts: File
            merged_file: File
            merged_file_unfiltered: File
            maf_file: File
            portal_file: File
            maf: File
          expression: "${ var output = {};
              for ( var input_key in inputs ){
                new_key = input_key.slice(0,-7);
                output[new_key] = inputs[input_key][0];
              }
              return output;
          }"