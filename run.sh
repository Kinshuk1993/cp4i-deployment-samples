#!/bin/bash
#******************************************************************************
# PREREQUISITES:
#   - Logged into cluster on the OC CLI
#
# PARAMETERS:
#   -n : <NAMESPACE> (string), namespace for the 1-click uninstallation. Defaults to "cp4i"
#   -r : <REPO> (string), Defaults to 'https://github.com/IBM/cp4i-deployment-samples.git'
#   -b : <BRANCH> (string), Defaults to 'main'
#
# USAGE:
#   With defaults values
#     ./run.sh
#
#   Overriding the namespace and release-name
#     ./run.sh -n <NAMESPACE> -r <FORKED_REPO> -b <BRANCH>

function divider() {
    echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
}

function usage() {
    echo -e "\nUsage: $0 -n <NAMESPACE> -r <FORKED_REPO> -b <BRANCH>"
    divider
    exit 1
}

NAMESPACE="cp4i"
CURRENT_DIR=$(dirname $0)
TICK="\xE2\x9C\x85"
CROSS="\xE2\x9D\x8C"
ALL_DONE="\xF0\x9F\x92\xAF"
INFO="\xE2\x84\xB9"
MISSING_PARAMS="false"
BRANCH="main"
FORKED_REPO="https://github.com/IBM/cp4i-deployment-samples.git"

while getopts "n:r:b:" opt; do
    case ${opt} in
    n)
        NAMESPACE="$OPTARG"
        ;;
    r)
        FORKED_REPO="$OPTARG"
        ;;
    b)
        BRANCH="$OPTARG"
        ;;
    \?)
        usage
        ;;
    esac
done

if [[ -z "${NAMESPACE// /}" ]]; then
    echo -e "$cross ERROR: Driveway Dent deletion testing namespace is empty. Please provide a value for '-n' parameter."
    missingParams="true"
fi

if [[ -z "${FORKED_REPO// /}" ]]; then
    echo -e "$cross ERROR: Driveway Dent deletion testing repository is empty. Please provide a value for '-r' parameter."
    missingParams="true"
fi

if [[ -z "${BRANCH// /}" ]]; then
    echo -e "$cross ERROR: Driveway Dent deletion testing branch is empty. Please provide a value for '-b' parameter."
    missingParams="true"
fi

if [[ "$missingParams" == "true" ]]; then
    usage
fi

divider
echo -e "$info Current directory: $CURRENT_DIR"
echo -e "$info  Driveway Dent deletion testing namespace: $NAMESPACE"
echo -e "$info  Driveway Dent deletion testing repository: $FORKED_REPO"
echo -e "$info  Driveway Dent deletion testing branch: $BRANCH"
divider

oc project $NAMESPACE

./DrivewayDentDeletion/Operators/cicd-apply-dev-pipeline.sh -n $NAMESPACE -r $FORKED_REPO -b $BRANCH

export URL=$(echo "$(oc get route el-main-trigger-route --template='http://{{.spec.host}}')")
sleep 60
curl $URL

divider

tkn pr logs $(tkn pr ls | grep Running | awk '{print $1}') -f

divider

./DrivewayDentDeletion/Operators/cicd-apply-test-pipeline.sh -n $NAMESPACE -r $FORKED_REPO -b $BRANCH

divider

export URL=$(echo "$(oc get route el-main-trigger-route --template='http://{{.spec.host}}')")
sleep 60
curl $URL

divider

tkn pr logs $(tkn pr ls | grep Running | awk '{print $1}') -f

divider

./DrivewayDentDeletion/Operators/cicd-apply-test-apic-pipeline.sh -n $NAMESPACE -r $FORKED_REPO -b $BRANCH

divider

export URL=$(echo "$(oc get route el-main-trigger-route --template='http://{{.spec.host}}')")
sleep 60
curl $URL

divider

tkn pr logs $(tkn pr ls | grep Running | awk '{print $1}') -f

# echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

# ./EventEnabledInsurance/prereqs.sh -n $NAMESPACE -b $BRANCH -r $FORKED_REPO
