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
            mkdir -p ${OCP_ENV_FOLDER}
            echo ""
            echo "INFO: The folder ${OCP_ENV_FOLDER} has been created."
        else
            echo ""
            echo "INFO: The existing ${OCP_ENV_FOLDER} folder will be used"
            echo ""
    fi

    cd ${OCP_ENV_FOLDER}

    # Download GOVC
    wget https://github.com/vmware/govmomi/releases/download/v0.30.0/govc_Linux_x86_64.tar.gz

    # Untar GOVC
    tar -vxf govc_Linux_x86_64.tar.gz




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


# Set GOVC variables

    export GOVC_URL=${VCENTER_SERVER_IP}
	export GOVC_USERNAME=${VCENTER_ADMIN_USER}
	export GOVC_PASSWORD=${VCENTER_ADMIN_PASSWORD}
	export GOVC_INSECURE=true
	# could also be:
	export GOVC_DATASTORE=${VCENTER_DATASTORE_NAME}
    export GOVC_NETWORK=${VCENTER_VM_NETWORK_NAME}
    export GOVC_RESOURCE_POOL=${VCENTER_RESOURCE_POOL}





# Create vCenter roles for OpenShift

    ./rgovc role.create ${VCENTER_ROLE_PREFIX}-PortGroup \
    Network.Assign

    echo "./rgovc role.ls ${VCENTER_ROLE_PREFIX}-PortGroup"
    ./rgovc role.ls ${VCENTER_ROLE_PREFIX}-PortGroup


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


    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-Cluster \
    Host.Config.Storage \
    Resource.AssignVMToPool \
    VApp.AssignResourcePool \
    VApp.Import \
    VirtualMachine.Config.AddNewDisk

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Cluster"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Cluster


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


    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-Datastore \
    Datastore.AllocateSpace \
    Datastore.Browse \
    InventoryService.Tagging.ObjectAttachable

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datastore"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-Datastore


    ./govc role.create ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool \
    Host.Config.Storage \
    Resource.AssignVMToPool \
    VApp.AssignResourcePool \
    VApp.Import \
    VirtualMachine.Config.AddNewDisk

    echo "./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool"
    ./govc role.ls ${VCENTER_ROLE_PREFIX}-vCenter-ResourcePool


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

    cd ..

    echo ""
    echo "INFO: The vCenter Roles are configured, please apply them to resource in line with guide"
    echo "      https://docs.openshift.com/container-platform/4.10/installing/installing_vsphere/installing-vsphere-installer-provisioned.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned"





# clear vCenter ADMIN credentials
    export VCENTER_ADMIN_PASSWORD=""
    export LOCAL_VCENTER_ADMIN_PASSWORD=""
    export VCENTER_ADMIN_USER=""
    export LOCAL_VCENTER_ADMIN_USER=""

echo ""
echo "INFO: Configuration of vCenter roles is complete"