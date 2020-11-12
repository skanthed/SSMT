## Expected Output of following commands from Installation Script

Make sure you follow all the steps in Prerequisites here at [CRC for Openshift Reporting Backend](https://github.com/dburugupalli/SSMT/blob/feature-1/Documentation/Installing_crc.md).  and go as per the instruction printed on terminal before and after every command is executed when you run the script.


### Output after Metering Operator Installation for local OCP cluster. 
```bash
$oc get pods
NAME                                  READY   STATUS              RESTARTS   AGE

metering-operator-68dd64cfb6-pxh8v    2/2     Running             0          2m49s
```

if the metering operator is still not up and running. 
Stop the script and do the process manually of installing the metering operator -


```bash
a. Run command "crc console" in terminal.
b. Login using admin credentials for crc.
c. Search Red Hat Metering under Operator Hub and Click Install. 
d. Wait until Metering Operator pods are up and Running successfully.
```

Remove the steps that are done from the script. Rerun the script with the remaining steps.



### Output after Installing Metering Stack / Metering Configuration for local OCP cluser

Understanding [Metering Configuration](https://docs.openshift.com/container-platform/4.3/metering/configuring_metering/metering-about-configuring.html#metering-about-configuring)

At a minimum, you need to configure persistent storage and configure the Hive metastore.[Refer Samples](https://docs.openshift.com/container-platform/4.3/metering/configuring_metering/metering-about-configuring.html#metering-about-configuring)

```bash
$ oc -n openshift-metering get pods
NAME                                 READY   STATUS    RESTARTS   AGE
hive-metastore-0                     2/2     Running   14         7d15h
hive-server-0                        3/3     Running   21         7d15h
metering-operator-86b95669bb-njp4q   2/2     Running   14         7d15h
presto-coordinator-0                 2/2     Running   8          7d2h
reporting-operator-978687d9c-vkzrl   2/2     Running   27         7d15h

#if not, Wait few more mins until Componenets of metering stack are installed like hive metastore, presto database and reporting operator 
```



