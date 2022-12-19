#! /bin/bash

echo ${1}

# erasing variables
export LOCAL_ENV_PARAM=""
export VCENTER_ADMIN_PASSWORD=""
export LOCAL_VCENTER_ADMIN_PASSWORD=""
export VCENTER_ADMIN_USER=""
export LOCAL_VCENTER_ADMIN_USER=""


# OCP environment checking
export LOCAL_ENV_PARAM=${1}

    if [[ -z "${LOCAL_ENV_PARAM}" ]]
        then
            echo "WARNING:"
            echo "  Please provide the environment <something>.env file as a parameter."
            echo "  Example: . make-vcenterpermissions.sh test.var"
            return      # exit from the script
        else
            if [[ -e "./${LOCAL_ENV_PARAM}" ]]
                then
                    source ./${LOCAL_ENV_PARAM}   # sourcing variables from the evnironment file
                    export OCP_ENV_FOLDER="./${OCP_ENV}/"
                    echo ""
                    echo "INFO: The vCenter roles will be created for env ${OCP_ENV}."
                    echo ""
                else
                    echo ""
                    echo "WARNING: The file you have provided as a parameter does not exist, please provide existing file."
                    echo " "
            fi
    fi

# Download and install GOVC tool to the OCP_ENV_FOLDER folder

    if [[ ! -d ${OCP_ENV_FOLDER} ]] 
        then
            mkdir -p ./${OCP_ENV_FOLDER}
            echo ""
            echo "INFO: The folder ${OCP_ENV_FOLDER} has been created."
        else
            echo ""
            echo "INFO: The existing ${OCP_ENV_FOLDER} folder will be used"
            echo ""
    fi

    cd ${OCP_ENV_FOLDER}

    # Download GOVC
    wget https://github.com/vmware/govmomi/releases/download/v0.30.0/govc_Linux_x86_64.tar.gz &>/dev/null

    # Untar GOVC
    tar -vxf govc_Linux_x86_64.tar.gz &>/dev/null




# Input code for getting vCenter admin credentials
    echo ""
    echo ""
    echo "Please enter vCenter ADMIN username creating OCP required vCenter Roles. After Entering the password press Enter to continue."
    read LOCAL_VCENTER_ADMIN_USER

    if [[ -z "${LOCAL_VCENTER_ADMIN_USER}" ]]
        then
            echo "WARNING: the VCENTER_ADMIN_USER  has not been entered so please enter it and press Enter."
            read -s LOCAL_VCENTER_ADMIN_USER

            if [[ -z "${LOCAL_VCENTER_ADMIN_USER}" ]]
                then
                    echo "WARNING: You did not provide username, exiting the script"
                    export VCENTER_ADMIN_PASSWORD=""
                    export LOCAL_VCENTER_ADMIN_PASSWORD=""
                    export VCENTER_ADMIN_USER=""
                    export LOCAL_VCENTER_ADMIN_USER=""
                    return      # exit from the script
                else
                    export VCENTER_ADMIN_USER=${LOCAL_VCENTER_ADMIN_USER}
                    echo "INFO: the variable for vCenter ADMIN user has been set"
            fi
        else
            export VCENTER_ADMIN_USER=${LOCAL_VCENTER_ADMIN_USER}
            echo "INFO: the variable for vCenter ADMIN user has been set"
    fi

    echo ""
    echo ""
    echo "Please enter vCenter ADMIN password for seting OCP required roles in vCenter. After Entering the password press Enter to continue."
    read -s LOCAL_VCENTER_ADMIN_PASSWORD

    if [[ -z "${LOCAL_VCENTER_ADMIN_PASSWORD}" ]]
        then
            echo "WARNING: the VCENTER_ADMIN_PASSWORD  has not been entered so please enter it and press Enter."
            read -s LOCAL_VCENTER_ADMIN_PASSWORD

            if [[ -z "${LOCAL_VCENTER_ADMIN_PASSWORD}" ]]
                then
                    echo "WARNING: You did not provide pasword, exiting the script"
                    export VCENTER_ADMIN_PASSWORD=""
                    export LOCAL_VCENTER_ADMIN_PASSWORD=""
                    export VCENTER_ADMIN_USER=""
                    export LOCAL_VCENTER_ADMIN_USER=""
                    return      # exit from the script
                else
                    export VCENTER_ADMIN_PASSWORD=${LOCAL_VCENTER_ADMIN_PASSWORD}
                    echo "INFO: the variable for vCenter ADMIN password has been set"
            fi
        else
            export VCENTER_ADMIN_PASSWORD=${LOCAL_VCENTER_ADMIN_PASSWORD}
            echo "INFO: the variable for vCenter ADMIN password has been set"
    fi


# Input code for getting vCenter password variable
    echo ""
    echo ""
    echo "Please enter vCenter password for ${VCENTER_USERNAME} or leave it empty if the password variable is already set. After Entering the password press Enter to continue."
    read -s LOCAL_VCENTER_PASSWORD

    if [[ -z "${LOCAL_VCENTER_PASSWORD}" ]]
        then
            if [[ -z "${VCENTER_PASSWORD}" ]]
                then
                    echo "the VCENTER_PASSWORD variable does not exist yet so please enter vCenter Password and press Enter."
                    read -s LOCAL_VCENTER_PASSWORD
                    if [[ -z "${LOCAL_VCENTER_PASSWORD}" ]]
                        then
                            echo "You did not provide pasword, exiting the script"
                            return      # exit from the script
                        else
                            export VCENTER_PASSWORD=${LOCAL_VCENTER_PASSWORD}
                            echo "the variable for vCenter password has been set"
                    fi
                else
                    echo "as you did not enter vCenter password as the VCENTER_PASSWORD variable has already been set the existing will be used"
            fi	
        else
            export VCENTER_PASSWORD=${LOCAL_VCENTER_PASSWORD}
            echo "the variable for vCenter password has been set"
    fi


# Set GOVC variables

    export GOVC_URL=${VCENTER_SERVER_IP}
	export GOVC_USERNAME=${VCENTER_ADMIN_USER}
	export GOVC_PASSWORD=${VCENTER_ADMIN_PASSWORD}
	export GOVC_INSECURE=true
	# could also be:
	export GOVC_DATASTORE=${VCENTER_DATASTORE_NAME}
    export GOVC_NETWORK=${VCENTER_VM_NETWORK_NAME}
    export GOVC_RESOURCE_POOL=${VCENTER_RESOURCE_POOL}





# Create user account for OCP

    # not yet implemented control if user already exists.
    echo "-----------------------------------------------------------------------"
    echo "Creating OpenShift Installer service account: ${VCENTER_USERNAME}"
    export LOCAL_VCENTER_TMPUSR=${VCENTER_USERNAME%@*}
    ./govc sso.user.create -p ${VCENTER_PASSWORD} -f="Openshift" -l="installer" -d="Openshift Installer account" ${LOCAL_VCENTER_TMPUSR}

# Create vCenter roles for OpenShift

    echo "-----------------------------------------------------------------------"
    echo "Creating vCenter roles for OpenShift Installer"

    # role for PortGroup - Network
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-PortGroup \
    Network.Assign

    echo "./rgovc role.ls ${VCENTER_ROLE_PREFIX}-PortGroup"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-PortGroup

    # role for vCenter
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter  \
    Cns.Searchable \
    InventoryService.Tagging.AttachTag \
    InventoryService.Tagging.CreateCategory \
    InventoryService.Tagging.CreateTag \
    InventoryService.Tagging.DeleteCategory  \
    InventoryService.Tagging.DeleteTag \
    InventoryService.Tagging.EditCategory \
    InventoryService.Tagging.EditTag \
    Sessions.ValidateSession \
    StorageProfile.Update \
    StorageProfile.View

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter

    # role for vCenter Cluster
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-Cluster \
    Host.Config.Storage \
    Resource.AssignVMToPool \
    VApp.AssignResourcePool \
    VApp.Import \
    VirtualMachine.Config.AddNewDisk

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Cluster"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Cluster


    # role for vCenter Datecenter
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-Datacenter \
    Folder.Create \
    Folder.Delete \
    InventoryService.Tagging.ObjectAttachable \
    Resource.AssignVMToPool \
    VApp.Import \
    VirtualMachine.Config.AddExistingDisk \
    VirtualMachine.Config.AddNewDisk \
    VirtualMachine.Config.AddRemoveDevice \
    VirtualMachine.Config.AdvancedConfig \
    VirtualMachine.Config.Annotation \
    VirtualMachine.Config.CPUCount \
    VirtualMachine.Config.DiskExtend \
    VirtualMachine.Config.DiskLease \
    VirtualMachine.Config.EditDevice \
    VirtualMachine.Config.Memory \
    VirtualMachine.Config.RemoveDisk \
    VirtualMachine.Config.Rename \
    VirtualMachine.Config.ResetGuestInfo \
    VirtualMachine.Config.Resource \
    VirtualMachine.Config.Settings \
    VirtualMachine.Config.UpgradeVirtualHardware \
    VirtualMachine.Interact.GuestControl \
    VirtualMachine.Interact.PowerOff \
    VirtualMachine.Interact.PowerOn \
    VirtualMachine.Interact.Reset \
    VirtualMachine.Inventory.Create \
    VirtualMachine.Inventory.CreateFromExisting \
    VirtualMachine.Inventory.Delete \
    VirtualMachine.Provisioning.Clone \
    VirtualMachine.Provisioning.DeployTemplate \
    VirtualMachine.Provisioning.MarkAsTemplate

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datacenter"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datacenter


    # role for vCenter Datastore
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-Datastore \
    Datastore.AllocateSpace \
    Datastore.Browse \
    InventoryService.Tagging.ObjectAttachable

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datastore"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datastore


    # role for vCenter ResourcePool - Used only ir there are predefine Resource Pools Permissions not yet assigned automatically
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool \
    Host.Config.Storage \
    Resource.AssignVMToPool \
    VApp.AssignResourcePool \
    VApp.Import \
    VirtualMachine.Config.AddNewDisk

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool


    # role for vCenter VM Folder - Used only ir there are predefine VM Folder. Permissions not yet assigned automatically.
    echo ""
    ./govc role.create ${VCENTER_ROLE_PREFIX}-VM-Folder \
    InventoryService.Tagging.ObjectAttachable \
    Resource.AssignVMToPool \
    System.Anonymous \
    System.Read \
    System.View \
    VApp.Import \
    VirtualMachine.Config.AddExistingDisk \
    VirtualMachine.Config.AddNewDisk \
    VirtualMachine.Config.AddRemoveDevice \
    VirtualMachine.Config.AdvancedConfig \
    VirtualMachine.Config.Annotation \
    VirtualMachine.Config.CPUCount \
    VirtualMachine.Config.DiskExtend \
    VirtualMachine.Config.DiskLease \
    VirtualMachine.Config.EditDevice \
    VirtualMachine.Config.Memory \
    VirtualMachine.Config.RemoveDisk \
    VirtualMachine.Config.Rename \
    VirtualMachine.Config.ResetGuestInfo \
    VirtualMachine.Config.Resource \
    VirtualMachine.Config.Settings \
    VirtualMachine.Config.UpgradeVirtualHardware \
    VirtualMachine.Interact.GuestControl \
    VirtualMachine.Interact.PowerOff \
    VirtualMachine.Interact.PowerOn \
    VirtualMachine.Interact.Reset \
    VirtualMachine.Inventory.Create \
    VirtualMachine.Inventory.CreateFromExisting \
    VirtualMachine.Inventory.Delete \
    VirtualMachine.Provisioning.Clone \
    VirtualMachine.Provisioning.DeployTemplate \
    VirtualMachine.Provisioning.MarkAsTemplate

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-VM-Folder"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-VM-Folder

    echo ""
    echo "INFO: The vCenter Roles are configured, please apply them to resource in line with guide"
    echo "      https://docs.openshift.com/container-platform/4.10/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned"



# Assigning roles to user

    echo "-----------------------------------------------------------------------"
    echo " Assigning vCenter roles for OpenShift Installer"

    echo ""
    echo " Assigning permissions to vCenter"
    ./govc permissions.set -principal="${VCENTER_USERNAME}" -propagate=false -role="${VCENTER_ROLE_PREFIX}-vCenter"
    ./govc permissions.ls | grep -E "Entity|${LOCAL_VCENTER_TMPUSR}"

    echo ""
    echo " Assigning permissions to vCenter Datecenter /${VCENTER_DATACENTER_NAME}"
    ./govc permissions.set -principal="${VCENTER_USERNAME}" -propagate=false -role="${VCENTER_ROLE_PREFIX}-vCenter-Datacenter" "/${VCENTER_DATACENTER_NAME}"
    ./govc permissions.ls "/${VCENTER_DATACENTER_NAME}" | grep -E "Entity|${LOCAL_VCENTER_TMPUSR}"

    echo ""
    echo " Assigning permissions to vCenter Cluster: /${VCENTER_DATACENTER_NAME}/host/${VCENTER_CLUSTER}"
    ./govc permissions.set -principal="${VCENTER_USERNAME}" -propagate=true -role="${VCENTER_ROLE_PREFIX}-vCenter-Cluster" "/${VCENTER_DATACENTER_NAME}/host/${VCENTER_CLUSTER}"
    ./govc permissions.ls "/${VCENTER_DATACENTER_NAME}/host/${VCENTER_CLUSTER}" | grep -E "Entity|${LOCAL_VCENTER_TMPUSR}"

    echo ""
    echo " Assigning permissions to vCenter Datasotre: /${VCENTER_DATACENTER_NAME}/datastore/${VCENTER_DATASTORE_NAME}"
    ./govc permissions.set -principal="${VCENTER_USERNAME}" -propagate=true -role="${VCENTER_ROLE_PREFIX}-vCenter-Datastore" "/${VCENTER_DATACENTER_NAME}/datastore/${VCENTER_DATASTORE_NAME}"
    ./govc permissions.ls "/${VCENTER_DATACENTER_NAME}/datastore/${VCENTER_DATASTORE_NAME}" | grep -E "Entity|${LOCAL_VCENTER_TMPUSR}"

    echo ""
    echo " Assigning permissions to vCenter Network /${VCENTER_DATACENTER_NAME}/network/${VCENTER_VM_NETWORK_NAME}"
    ./govc permissions.set -principal="${VCENTER_USERNAME}" -propagate=false -role="${VCENTER_ROLE_PREFIX}-PortGroup" "/${VCENTER_DATACENTER_NAME}/network/${VCENTER_VM_NETWORK_NAME}"
    ./govc permissions.ls "/${VCENTER_DATACENTER_NAME}/network/${VCENTER_VM_NETWORK_NAME}" | grep -E "Entity|${LOCAL_VCENTER_TMPUSR}"


# clear vCenter ADMIN credentials
    export VCENTER_ADMIN_PASSWORD=""
    export LOCAL_VCENTER_ADMIN_PASSWORD=""
    export VCENTER_ADMIN_USER=""
    export LOCAL_VCENTER_ADMIN_USER=""

cd ..

echo ""
echo "INFO: Configuration of vCenter roles is complete"
