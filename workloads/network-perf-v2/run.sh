#!/usr/bin/env bash
set -x

source ./env.sh
source ../../utils/common.sh

curl -sS -L $NETPERF_URL | tar -xz

# Assuming kubeconfig is set
oc create ns netperf
oc create sa netperf -n netperf
oc adm policy add-scc-to-user hostnetwork -z netperf -n netperf

log "###############################################"
log "Workload: ${WORKLOAD}"
log "###############################################"

echo $WORKLOAD
        if [ $WORKLOAD == iperf ];then
          timeout $TEST_TIMEOUT ./k8s-netperf --debug --metrics --all --iperf --search $ES_SERVER --tcp-tolerance ${TOLERANCE} --clean=true
          run=$?
        elif [ $WORKLOAD == local ]; then
          timeout $TEST_TIMEOUT ./k8s-netperf --debug --metrics --all --local --search $ES_SERVER --tcp-tolerance ${TOLERANCE} --clean=true
          run=$?
        elif [ $WORKLOAD == across ]; then
          timeout $TEST_TIMEOUT ./k8s-netperf --debug --metrics --all --across --search $ES_SERVER --tcp-tolerance ${TOLERANCE} --clean=true
          run=$?
        else
          timeout $TEST_TIMEOUT ./k8s-netperf --debug --metrics --all --config ${WORKLOAD} --search $ES_SERVER --tcp-tolerance ${TOLERANCE} --clean=true
          run=$?
        fi
# Add debugging info (will be captured in each execution output)
echo "============ Debug Info ============"
echo k8s-netperf version $NETPERF_VERSION
oc get pods -n netperf -o wide
oc get nodes -o wide
#oc get machineset -A

log "Finished workload ${0} ${WORKLOAD}, exit code ($run)"

cat *.csv

exit $run
