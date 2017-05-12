#!/bin/sh -e

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:
   -t      Tool name (e.g. trimgalore)
   -v      Version of the tool (e.g. 0.4.3)
   -c      cmo wrapper name (e.g cmo_trimgalore)
   -d      Skip installation of cmo and gxargparse (only for debugging)
   -h      Help

e.g. $0 -t trimgalore -v 0.4.3 -c cmo_trimgalore

EOF
}

while getopts “t:v:c:h” OPTION
do
    case $OPTION in
        t) TOOL_NAME=$OPTARG ;;
        v) TOOL_VERSION=$OPTARG ;;
        c) CMO_WRAPPER=$OPTARG ;;        
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $TOOL_NAME} ] || [ -z $TOOL_VERSION ] || [ -z $CMO_WRAPPER ]
then
    usage
    exit 1
fi

# convert _ to -
CMO_WRAPPER_WITH_DASH=`echo "${CMO_WRAPPER}" | sed "s/_/-/g"`

TOOL_DIRECTORY="../cwl-wrappers/${CMO_WRAPPER_WITH_DASH}/${TOOL_VERSION}"

if [ ! -d $TOOL_DIRECTORY ]
then
    # skip
    exit 0
fi

# if .original.cwl exists, use that as the basis
# otherwise, use gxargparse to generate
if [ -e ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.original.cwl ]
then
    # cwl manually genereated in the past (*.original.cwl) must be placed in the tool directory
    cp ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.original.cwl ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
else
    # do not use "-t" because docker messes up stdout and stderr
    # hack: an extra space at the end helps cases where a container has multiple entry points
    # e.g. sudo docker run -it --rm vcf2maf:1.6.12maf2vcf.pl
    #      vs.
    #      sudo docker run -it --rm vcf2maf:1.6.12 maf2vcf.pl
    tool_cmd="sudo docker run -i $TOOL_NAME:$TOOL_VERSION "

    # modify cmo_resources.json so that cmo calls a dockerized tool
    python ./update_resource_def.py -f ../cwl-wrappers/cmo_resources.json ${TOOL_NAME} default "${tool_cmd}"

    # tell cmo to use this json file for calling tools
    export CMO_RESOURCE_CONFIG="../cwl-wrappers/cmo_resources.json"

    # finally, run cmo wrapper and generate cwl
    # https://github.com/common-workflow-language/gxargparse
    python /usr/local/bin/cmo-gxargparse/cmo/bin/${CMO_WRAPPER} --generate_cwl_tool \
        --directory ${TOOL_DIRECTORY} \
        --output_section ${TOOL_DIRECTORY}/outputs.yaml
        # --basecommand="${CMO_WRAPPER} --version ${TOOL_VERSION}"

    # rename _ to -
    mv ${TOOL_DIRECTORY}/${CMO_WRAPPER}.cwl ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
fi

# replace str with string
sed -i "s/type: \[\"null\", str\]/type: \[\"null\", string\]/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
sed -i "s/type: str$/type: string/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl

# remove unnecessasry u (unicode)
sed -i "s/u'/'/g" ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl

# postprocess: add metadata, requirements section, other necessary 
python ./postprocess_cwl.py \
    -f ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl \
    -v ${TOOL_VERSION} \
    -r ${TOOL_DIRECTORY}/requirements.yaml \
    -m ${TOOL_DIRECTORY}/metadata.yaml

# postprocess: convert to yaml, make changes, convert back to cwl
if [ -e "${TOOL_DIRECTORY}/postprocess.py" ]
then
    python ${TOOL_DIRECTORY}/postprocess.py \
        -f ${TOOL_DIRECTORY}/${CMO_WRAPPER_WITH_DASH}.cwl
fi

tree ${TOOL_DIRECTORY}

#fixme: is it the right location to do this? or should we do right after create containers?
# modify prism_resources.json so that cmo in production can call sing.sh (singularity wrapper)
case ${TOOL_NAME} in
    pindel)
        # pindel needs special treament since pindel container has two executables "pindel" and "pindel2vcf"
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json pindel ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION} pindel"
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json pindel2vcf ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION} pindel2vcf"
        ;;
    vardict)
        # vardict needs special treament since vardict container has one R script and one Perl script to be exposed
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json vardict ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION} vardict"

        # an extra space needed at the end because cmo will append either "testsomatic.R" or "var2vcf_paired.pl"
        # and we need to make sure it's treated as an argument.
        # e.g. sing.sh vardict 1.4.6 testsomatic.R
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json vardict_bin ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION} "
        ;;
    vcf2maf)
        # an extra space needed at the end because cmo will append "vcf2maf.pl"
        # e.g. sing.sh vcf2maf 1.6.12 vcf2maf.pl
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json vcf2maf ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION} "
        ;;
    *)
        python ./update_resource_def.py -f ../cwl-wrappers/prism_resources.json ${TOOL_NAME} ${TOOL_VERSION} "sing.sh ${TOOL_NAME} ${TOOL_VERSION}"
        ;;
esac
