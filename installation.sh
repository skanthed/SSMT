#!/bin/bash


echo "Starting NetworkManager service" 
sudo systemctl start NetworkManager

echo "Starting libvrtd service"
sudo systemctl start libvirtd

read -p "Enter memory in MB : " mem
read -p "Enter number of cpus : " cpu
echo "Entered memory size $mem "


echo "Setting cpu and mem"
crc config set cpus $cpu
crc config set memory $mem

echo "View the CRC config"
crc config view
crc setup
echo "Start the CRC"
crc start -p pull-secret.txt 


echo "Openshift admin login"
oc login


echo "Create openshift-metering namespace"
oc create -f metering-namespace.yaml


oc project openshift-metering


echo "Get cluster version"
oc get clusterversion version -ojsonpath='{range .spec.overrides[*]}{.name}{"\n"}{end}' | nl -v 0


echo "Patch the cluster version"
read -p "Enter un-managed operator index : " umidx
oc patch clusterversion/version --type='json' -p '[{"op":"remove", "path":"/spec/overrides/' + $umidx + '"}]' -oyaml
sleep 1m


echo "Scales the Openshift Monitoring"
oc scale --replicas=1 statefulset --all -n openshift-monitoring; 
oc scale --replicas=1 deployment --all -n openshift-monitoring


echo "Create OperatorGroup object"
oc create -f metering-og.yaml


echo "Install metering operator"
oc create -f metering-sub.yaml


echo "Waiting to complete the Metering Creation"
sleep 10m  # 10 mins pause


oc get pods


echo "Project the openshift metering"
oc project openshift-metering


echo "Validate the metering status. If succeeded, then configure persistent storage and configure the Hive metastore"
oc create -f https://raw.githubusercontent.com/dburugupalli/SSMT/feature-1/openshift-metering-templates/configuration-templates/metering-configuration.yaml
sleep 25m 


echo "Get pods details"
oc -n openshift-metering get pods


echo "See all the generated reports"
oc get reportdatasources -n openshift-metering | grep -v raw
