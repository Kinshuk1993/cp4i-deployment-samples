#!/bin/bash

export NAMESPACE=cp4i1
export DEV_NAMESPACE=$NAMESPACE
export BRANCH=eei-first-iteration
export FORKED_REPO=https://github.com/IBM/cp4i-deployment-samples.git

oc project $DEV_NAMESPACE

./DrivewayDentDeletion/Operators/cicd-apply-dev-pipeline.sh -n $NAMESPACE -r $FORKED_REPO -b $BRANCH

export URL=$(echo "$(oc get route el-main-trigger-route --template='http://{{.spec.host}}')")
sleep 60
curl $URL

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

tkn pr logs $(tkn pr ls | grep Running | awk '{print $1}') -f

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

./DrivewayDentDeletion/Operators/cicd-apply-test-pipeline.sh -n $NAMESPACE -r $FORKED_REPO -b $BRANCH

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

export URL=$(echo "$(oc get route el-main-trigger-route --template='http://{{.spec.host}}')")
sleep 60
curl $URL

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

tkn pr logs $(tkn pr ls | grep Running | awk '{print $1}') -f
