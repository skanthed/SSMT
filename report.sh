#!/bin/bash

#To view reports on the terminal. 

echo "Get into the openshift metering project"
oc project openshift-metering

echo "Get the list of all pods"
oc -n openshift-metering get pods

echo "See all the generated reports"
oc get reportdatasources -n openshift-metering | grep -v raw


echo " Setting meteringRoute"
meteringRoute="$(oc get routes metering -o jsonpath='{.spec.host}')"
echo "$meteringRoute"

token="$(oc whoami -t)"


echo "Name of the report we are acessing"
read -p "Enter report name : " nameOfReport
reportName=$nameOfReport

echo "$reportName"


echo "Data type can be either csv or json"
read -p "Enter report name : " formatOfReport
reportFormat=$formatOfReport


echo "Curl command to access data"
curl --insecure -H "Authorization: Bearer ${token}" "https://${meteringRoute}/api/v1/reports/get?name=${reportName}&namespace=openshift-metering&format=$reportFormat"

