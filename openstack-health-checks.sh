#!/bin/bash

export ANSIBLE_SSH_ARGS="-F /root/.ssh/openstack_cloud1_config"


#Enter the path to the openstack rc file below
source /root/openstack_cloud1/envrc

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++ Checking Services in cloud +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "--------- mySQL Cluster Check ---------------------------------------------------------------------------------------------------"
echo "--------- Checks if mySQL Cluster nodes are in synced state ---------------------------------------------------------------------"
ansible 'controllers' -m shell -a "clustercheck | grep 'Cluster Node is synced'" -i inventory.yaml
echo
echo "--------- RabbitMQ Cluster Check ------------------------------------------------------------------------------------------------"
echo "--------- Checks if any RabbitMQ nodes are in partition state  ------------------------------------------------------------------"
ansible 'controllers' -m shell -a "rabbitmqctl cluster_status" -i inventory.yaml
echo
echo
echo "--------- Corosync Cluster Check ------------------------------------------------------------------------------------------------"
echo "--------- Checks if all corosync members have joined the cluster and cluster health  --------------------------------------------"
echo "--------- All members should be in joined state and the ring status should be active with no faults------------------------------"
ansible '*controller1*' -m shell -a "corosync-cmapctl | grep members" -i inventory.yaml
echo
ansible 'controllers' -m shell -a "corosync-cfgtool -s" -i inventory.yaml
echo
echo
echo "--------- Pacemaker Cluster Check ------------------------------------------------------------------------------------------------"
echo "--------- Checks if all pacemaker members have joined the cluster and cluster health  --------------------------------------------"
echo
ansible '*controller1*' -m shell -a "pcs cluster status" -i inventory.yaml
echo
echo "--------- Pacemaker service Check ------------------------------------------------------------------------------------------------"
echo "--------- Checks for inactive resources group by OS Controllers and failed services  ------ -------------------------------------------------"
ansible '*controller1*' -m shell -a "crm_mon --group-by-node --inactive -1 | grep -v Started" -i inventory.yaml
echo
echo "--------- haproxy Check ----------------------------------------------------------------------------------------------------------"
echo "--------- Check if any services are in DOWN state in haproxy stats ---------------------------------------------------------------"
echo "--------- No output means no services are marked down ----------------------------------------------------------------------------"
ansible 'controllers' -m shell -a "echo 'show stat' | socat stdio unix-connect:/var/lib/haproxy/stats | grep -i down | grep -v '^#'" -i inventory.yaml | grep -i down
echo
echo "--------- System and openstack systemd service Check -----------------------------------------------------------------------------"
echo "--------- List services marked as failed by systemd ------------------------------------------------------------------------------"
ansible 'controllers' -m shell -a "systemctl list-units --type=service | grep failed" -i inventory.yaml
echo
echo "--------- Nova Service Check -----------------------------------------------------------------------------------------------------"
echo "--------- Check for any down Nova Services ---------------------------------------------------------------------------------------"
echo
nova service-list | grep down | sort
echo
echo "--------- Neutron agent status Check ---------------------------------------------------------------------------------------------"
echo "--------- Checks for any hypervisors/netnodes with any Neutron agents down -------------------------------------------------------"
neutron agent-list | grep -v ':-)' | sort
echo
echo
echo "--------- Cinder service agent status Check --------------------------------------------------------------------------------------"
echo "--------- Checks for any cinder services showing own -----------------------------------------------------------------------------"
cinder service-list | grep down
echo
echo "--------- Looking for down interfaces in eth0-5 (Linux bond 0) on OS Controllers -------------------------------------------------------------"
echo "--------- No output means no interface is down ------------------------------------------------------------------------------------"
echo
ansible 'controllers' -m shell -a "ip a | grep 'eth[0-5]' | grep 'DOWN' | egrep 'success|DOWN'" -i inventory.yaml
echo
echo "--------- Looking for down interfaces in eth0-5 (Linux bond 0) on Hypervisors -------------------------------------------------------------"
echo "--------- No output means no interface is down ------------------------------------------------------------------------------------"
echo
ansible 'hypervisors' -m shell -a "ip a | grep 'eth[0-5]' | grep 'DOWN' | egrep 'success|DOWN'" -i inventory.yaml
echo
echo "--------- Looking for bond interface settings for bond0/1/2 interfaces of OS Controllers -----------------------------------------"
echo "--------- No output means these are not configured ---------------------------------------------------------------------------------"
echo
echo "--------- Looking for bond interface settings for bond0 interfaces of OS Controllers -----------------------------------------"
ansible 'controllers' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond0' -i inventory.yaml
echo "--------- Looking for bond interface settings for bond1 interfaces of OS Controllers -----------------------------------------"
ansible 'controllers' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond1' -i inventory.yaml
echo "--------- Looking for bond interface settings for bond2 interfaces of OS Controllers -----------------------------------------"
ansible 'controllers' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond2' -i inventory.yaml
echo
echo "--------- Looking for bond interface settings for bond0/1/2 interfaces of Hypervisors -----------------------------------------"
echo "--------- No output means these are not configured ---------------------------------------------------------------------------------"
echo
echo "--------- Looking for bond interface settings for bond0 interfaces of Hypervisors -----------------------------------------"
ansible '*hypervisors' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond0' -i inventory.yaml
echo "--------- Looking for bond interface settings for bond1 interfaces of Hypervisors  -----------------------------------------"
ansible 'hypervisors' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond1' -i inventory.yaml
echo "--------- Looking for bond interface settings for bond2 interfaces of Hypervisors  -----------------------------------------"
ansible '*hypervisors' -m shell -a 'grep BONDING_OPTS /etc/sysconfig/network-scripts/ifcfg-bond2' -i inventory.yaml
echo
echo "--------- Looking for disk space usage for instances on Hypervisors hypervisors ------------------------------------------------------------"
echo
ansible 'hypervisors' -m shell -a 'df -h | grep nova' -i inventory.yaml
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++ System checks completed +++++++++++++++++++++++++++++++++++++++++++++++++++++"


