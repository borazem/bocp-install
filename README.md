# bocp-install
Beno OpenShift Install scripts for IPI deployment on vSphere. 

The files:

- test.var is an example file with prepopulated variable as inputs for specific Openshift environment you are creating. Copy the test.var to <yourenvironment.var> and adjust values for your environment
- make-installconfig.sh is a script that creates an install-config.yaml file by combining an ./templates/install-config-ti.yaml template and the input values from the <yourenvironment>.var. you run the script with two parameters, the <yourenvionment>.var as a first parameter and the ocp install folder as the second parameter. The script creates a sub-folder in current folder with a name of OCP_ENV variable defined in the <yourenvironemtn>.var and in that sub-folder another folder with a name provided as a second parameter.
- make-machineconfigsets.sh is a script that creates an mmachineconifgsets for infra and odf machines based on templates in ./templates/ folder and values provided in <yourenvironment>.var (infra-machineset-tm.yaml, odf-machineset-tm.yaml for machinesets and infra-mcp-tm.yaml, odf-mcp-tm.yaml for machineconfigpools for infra and odf nodes). the output files are copies in the sub-folder or the curent folder with a name of OCP_ENV variable defined in the <yourenvironemtn>.var
- make-vcenterroles.sh is a script that created vCenter roles needed for OCP IPI installation. You can then manually assing the roles created to the vCenter objects (Vcenter, Datacenter, Cluster, Datastore, Network..) as needed for OCP IPI installation. Run the script with a parameter which is a name of <yourenvionment>.var or a vcenter specific environment variables <yourvcenterenvironment>.var file (example testvcenter.var). The script awill ask you for vcenter admin username and password and create a vCenter roles for OCP IPI deployment. 
- make-vcenterroles-full.sh is a script that creates vCenter user for OCP, Roles and assign Permissions required for IPI installation. The script will ask you for vcenter admin credentials and create a vCenter roles for OCP IPI deployment. Run the script with a parameter which is a name of <yourenvionment>.var or a vcenter specific environment variables <yourvcenterenvironment>.var (look at example testvcenter.var). The script will ask youu for vcenter admin userename and password as well as the password for the vcenter user with which OCP will interract with the vCenter then it download the GOVC vSphere CLI client, and creates the vCenter user, Roles and assings permission to the vCenter objects (Vcenter, Datacenter, Cluster, Datastore, Network..) as needed for OCP IPI installation.
- testcventer.var is a file with prepopulated variable as inputs for specific vSphere vCenter environment in which you are creating roles (make-vcenterroles.sh) or user, roles and assign permissions (make-vcenterroles-full.sh). Copy the testvcenter.var to <yourvcenterenvironment.var> and adjust values for your datacenter
