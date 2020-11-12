#!/bin/bash


echo "Starting NetworkManager service" 
sudo systemctl start NetworkManager

echo "Starting libvrtd service"
sudo systemctl start libvirtd

echo "Lets configure CRC cluster with 7+vcpus &16+GB memory"

read -p "Enter memory in MB : " mem
read -p "Enter number of cpus : " cpu
echo "Entered memory size $mem "


echo "Setting cpu and mem"
crc config set cpus $cpu
crc config set memory $mem

echo "View the CRC config"
crc config view
crc setup
echo "Starting the CRC, make sure you have the right path to pull-secret.txt file"
crc start -p pull-secret.txt 



echo "Openshift login - Take the credentials from the output of previous command. Use admin credentials to login, as you need to install operators"
oc login


echo "Create openshift-metering namespace"
oc create -f https://raw.githubusercontent.com/skanthed/SSMT/bash-script/openshift-metering-templates/configuration-templates/metering-namespace.yaml


oc project openshift-metering


echo "Get the cluster versions"
oc get clusterversion version -ojsonpath='{range .spec.overrides[*]}{.name}{"\n"}{end}' | nl -v 0


echo "Patch the cluster versions and Replace the unmanged-operator-index to [0 cluster-monitoring-operator]"
read -p "Enter un-managed operator index : " umidx
oc patch clusterversion/version --type='json' -p '[{"op":"remove", "path":"/spec/overrides/' + $umidx + '"}]' -oyaml
sleep 1m


echo "Scaling the Openshift Monitoring"
oc scale --replicas=1 statefulset --all -n openshift-monitoring; 
oc scale --replicas=1 deployment --all -n openshift-monitoring


echo "Creating OperatorGroup object"
oc create -f https://raw.githubusercontent.com/skanthed/SSMT/bash-script/openshift-metering-templates/configuration-templates/metering-og.yaml

echo "Installing metering operator"
oc create -f https://raw.githubusercontent.com/skanthed/SSMT/bash-script/openshift-metering-templates/configuration-templates/metering-sub.yaml


echo "Waiting to complete the Metering Operator Creation"
sleep 10m  # 10 mins pause


oc get pods


echo "Now using project the openshift metering"
oc project openshift-metering


echo "Validate the metering status. If succeeded, then configure persistent storage and configure the Hive metastore"
oc create -f https://raw.githubusercontent.com/dburugupalli/SSMT/feature-1/openshift-metering-templates/configuration-templates/metering-configuration.yaml
sleep 25m 


echo "See the status of all component of metering stack"
oc -n openshift-metering get pods


echo "Verifying Metering Stack / Configuration for local OCP cluster "
echo "Metering stack creates sample instances of reportdatasource and reportqueries custom resources. "
oc get reportdatasources -n openshift-metering | grep -v raw
