#!/bin/bash

export NAMESPACE=cp4i1

export DEV_NAMESPACE=$NAMESPACE
export TEST_NAMESPACE=$NAMESPACE-ddd-test

# ddd specific - delete pvc
# oc get pvc buildah-ace-acme -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc get pvc buildah-ace-api  -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc get pvc buildah-ace-bernie -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc get pvc buildah-ace-chris -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc get pvc buildah-mq -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc get pvc git-source-workspace -o json | jq 'del(.metadata.finalizers)' | oc apply -f -
# oc delete pvc -n $DEV_NAMESPACE buildah-ace-acme buildah-ace-api buildah-ace-bernie buildah-ace-chris buildah-mq git-source-workspace

# old tekton stuff delete
# oc delete --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.12.1/release.yaml
# oc delete -f https://storage.googleapis.com/tekton-releases/triggers/previous/v0.5.0/release.yaml

# oc delete Subscription openshift-pipelines-operator -n openshift-operators
# oc delete csv $(oc get csv -n openshift-operators | grep openshift-pipelines-operato | awk '{print $1}') -n openshift-operators

oc delete is -n $DEV_NAMESPACE --all
oc delete is -n $TEST_NAMESPACE --all

tkn resource delete -n $DEV_NAMESPACE --all -f
tkn tasks delete -n $DEV_NAMESPACE --all -f
tkn taskruns delete -n $DEV_NAMESPACE --all -f
tkn pipelines delete -n $DEV_NAMESPACE --all -f
tkn pipelineruns delete -n $DEV_NAMESPACE --all -f
tkn eventlisteners delete -n $DEV_NAMESPACE --all -f
tkn triggerbindings delete -n $DEV_NAMESPACE --all -f
tkn triggertemplate delete -n $DEV_NAMESPACE --all -f

oc delete rolebinding tekton-triggers-rolebinding
oc delete role tekton-triggers-role
oc delete role $(oc get roles -n $DEV_NAMESPACE | grep role- | awk '{print $1}')
oc delete rolebinding $(oc get rolebinding -n $DEV_NAMESPACE | grep test | awk '{print $1}')

oc delete route el-main-trigger-route

oc delete integrationserver -n $DEV_NAMESPACE --all
oc delete integrationserver -n $TEST_NAMESPACE --all
oc delete queuemanager -n $DEV_NAMESPACE --all
oc delete queuemanager -n $TEST_NAMESPACE --all

oc delete configuration ace-policyproject-ddd
oc delete configuration ace-policyproject-eei

oc -n $DEV_NAMESPACE policy remove-role-from-user registry-editor system:serviceaccount:$DEV_NAMESPACE:image-bot
oc -n $TEST_NAMESPACE policy remove-role-from-user registry-editor system:serviceaccount:$DEV_NAMESPACE:image-bot

oc delete sa cicd-ace-sa -n $DEV_NAMESPACE
oc delete sa cicd-mq-sa -n $DEV_NAMESPACE
oc delete sa cicd-pipeline -n $DEV_NAMESPACE
oc delete sa image-bot -n $DEV_NAMESPACE
oc delete sa cicd-test -n $DEV_NAMESPACE
oc delete sa cicd-push-to-test -n $DEV_NAMESPACE
oc delete sa cicd-deploy-to-test -n $DEV_NAMESPACE
oc delete sa cicd-mq-deploy-in-test-sa -n $DEV_NAMESPACE
oc delete sa cicd-ace-deploy-in-test-sa -n $DEV_NAMESPACE
oc delete sa cicd-api-e2e-in-test-sa -n $DEV_NAMESPACE

oc delete secret er-pull-secret -n $DEV_NAMESPACE
oc delete secret cicd-$DEV_NAMESPACE -n $DEV_NAMESPACE


echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

#for ddd
./DrivewayDentDeletion/Operators/prereqs.sh -n $NAMESPACE

#for eei
./EventEnabledInsurance/prereqs.sh -n $NAMESPACE

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"

./run.sh

echo -e "\n----------------------------------------------------------------------------------------------------------------------------------------------------------\n"


# -------------------------------------------------- DB AND ROLE/USER DELETION -------------------------------------------------------

# export POSTGRES_NAMESPACE=postgres
# DB_POD=$(oc get pod -n $POSTGRES_NAMESPACE -l name=postgresql -o jsonpath='{.items[].metadata.name}')
# DB_SVC="$(oc get cm -n $POSTGRES_NAMESPACE postgres-config -o json | jq '.data["postgres.env"] | split("\n  ")' | grep DATABASE_SERVICE_NAME | cut -d "=" -f 2- | tr -dc '[a-z0-9-]\n').postgres.svc.cluster.local"
# DEV_DB_USER=$(echo ${DEV_NAMESPACE}_ddd | sed 's/-/_/g')
# TEST_DB_USER=$(echo ${DEV_NAMESPACE}_ddd | sed 's/-/_/g')
# EEI_DB_USER=$(echo ${DEV_NAMESPACE}_ddd | sed 's/-/_/g')
# DEV_DB_NAME="db_$DEV_DB_USER"
# TEST_DB_NAME="db_$TEST_DB_USER"
# EEI_DB_NAME="db_$EEI_DB_USER"

# oc exec -n postgres -it ${DB_POD} -- /bin/bash
# psql
# DROP DATABASE IF EXISTS db_cp4i1_ddd;
# DROP DATABASE IF EXISTS db_cp4i1_ddd_test_ddd;
# DROP DATABASE IF EXISTS db_cp4i1_eei;
# DROP ROLE cp4i1_ddd;
# DROP ROLE cp4i1_ddd_test_ddd;
# DROP ROLE cp4i1_eei;
# \q

#### DOES NOT WORK ####
# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $DEV_DB_USER -d $DEV_DB_NAME -c \
#     'DROP DATABASE IF EXISTS db_cp4i1_ddd;'

# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $TEST_DB_USER -d $TEST_DB_NAME -c \
#     'DROP DATABASE IF EXISTS db_cp4i1_ddd_test_ddd;'

# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $EEI_DB_USER -d $EEI_DB_NAME -c \
#     'DROP DATABASE IF EXISTS db_cp4i1_eei;'

# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $DEV_DB_USER -d $DEV_DB_NAME -c \
#     'DROP ROLE cp4i1_ddd;'

# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $TEST_DB_USER -d $TEST_DB_NAME -c \
#     'DROP ROLE cp4i1_ddd_test_ddd;'

# oc exec -n $POSTGRES_NAMESPACE -it $DB_POD \
#     -- psql -U $EEI_DB_USER -d $EEI_DB_NAME -c \
#     'DROP ROLE cp4i1_eei;'