Openstack_health_checks


This script is a mix of shell and adhoc ansible commands to check the health of various openstack services. Currently script checks for

*neutron/nova agent state

*rabbitmq cluster health

*percona cluster health

*services behind haproxy

*pacemaker resources

*hypervisor disk usage

*controller / hypervisor NIC/bonding state.


If the  environment does not have a certain component corresponding commands can be easily removed. Servers are assumed to have 4 NICs with 2 bond interfaces.

To use this script follow the steps below.


Step 1)
Ansible (>1.9.4) and python openstack clients should be installed on the environment the script will be run. Ansible inventory should be organized with all openstack controllers under the group controllers and all the hypervisors under the group hypervisors. A sample inventory file is included in the repo.
In the inventory file controller1 is the first controller of the openstack controller cluster. Certain commands are only run from the first controller.

Step2)
Enter the path to any additional ssh parameters as below.This is not necessary if you do not need additional ssh parameters such as in case of ssh tunneling and crypto parameters.

export ANSIBLE_SSH_ARGS="-F /root/.ssh/openstack_cloud1_config"

Step 3)
Enter the path to the openstack rc file as below.
source /home_dir/openstack_cloud1/envrc


