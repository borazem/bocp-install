#! /bin/bash

echo ${1}

# erasing variables
export LOCAL_ENV_PARAM=""
export LOCAL_INSTALL_FOLDER=""


# OCP environment checking
export LOCAL_ENV_PARAM=${1}
export LOCAL_INSTALL_FOLDER=${2}

    if [[ -z "${LOCAL_ENV_PARAM}" || -e "./${LOCAL_INSTALL_FOLDER}" ]]
        then
            echo "WARNING:"
            echo "  Please provide the environment <something>.env file as first parameter and name of install folder as second parameter."
            echo "  Example: . make-installconfig.sh test.var install"
            return      # exit from the script
        else
            if [[ -e "./${LOCAL_ENV_PARAM}" ]]
                then
                    source ./${LOCAL_ENV_PARAM}   # sourcing variables from the evnironment file
                    export OCP_INSTALL_FOLDER=${LOCAL_INSTALL_FOLDER}
                    export OCP_ENV_FOLDER="./${OCP_ENV}/"
                    echo "INFO:"
                    echo "  The install-config file will be created for env ${OCP_ENV} in ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}"
                    echo ""
                else
                    echo "WARNING:"
                    echo "  The file you have provided as a parameter does not exist, please provide existing file."
                    echo " "
            fi
    fi


# Input code for getting Red Hat pull secret variable
    echo ""
    echo "Please enter Red Hat pull secret or leave it empty if the key variable is already set."
    read -s LOCAL_RH_PULL_SECRET

    if [[ -z "${LOCAL_RH_PULL_SECRET}" ]]
        then
            if [[ -z "${RH_PULL_SECRET}" ]]
                then
                    echo "enter Red Hat Pull Secret"
                else
                    echo "as you did not enter the Red Hat Pull secret and already exist the existing will be used"
            fi	
        else
            export RH_PULL_SECRET=${LOCAL_RH_PULL_SECRET}
            echo "the variable for Red Hat Pull Secret has been set"
    fi


# Input code for getting vCenter password variable
    echo ""
    echo ""
    echo "Please enter vCenter password or leave it empty if the password variable is already set. After Entering the password press Enter to continue."
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

# copy template files for macnineset and machineconfigpool for infra and odf nodes to a ./configs folder

    if [[ ! -d ${OCP_ENV_FOLDER} || ! -d ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER} ]] 
        then
            mkdir -p ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}
            echo "folder ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER} created"
        else
            echo ""
            echo "The folder ${OCP_INSTALL_FOLDER} already exist in ${OCP_ENV_FOLDER}. Delete it or spefify different install folder"
            echo ""
            return  # exit from the script
    fi

    
    \cp ./templates/install-config-ti.yaml ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    echo "Install-config.yaml has been copied to ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}"

    sed -i'' "s#<ocp_base_domain>#${OCP_BASE_DOMAIN}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<w_cpu>#${W_CPU}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<w_cpu_core>#${W_CPU_CORE}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<w_mem>#${W_MEM}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<w_diskgib>#${W_DISKGIB}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<w_node_replicas>#${W_NODE_REPLICAS}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<m_cpu>#${M_CPU}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<m_cpu_core>#${M_CPU_CORE}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<m_mem>#${M_MEM}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<m_diskgib>#${M_DISKGIB}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_cluster_name>#${OCP_CLUSTER_NAME}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_cluster_network>#${OCP_CLUSTER_NETWORK}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_cluster_network_hostprefix>#${OCP_CLUSTER_NETWORK_HOSTPREFIX}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_machine_network>#${OCP_MACHINE_NETWORK}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_service_network>#${OCP_SERVICE_NETWORK}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_vip_api>#${OCP_VIP_API}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_cluster>#${VCENTER_CLUSTER}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_datacenter_name>#${VCENTER_DATACENTER_NAME}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_datastore_name>#${VCENTER_DATASTORE_NAME}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_vip_ingress>#${OCP_VIP_INGRESS}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_vm_network_name>#${VCENTER_VM_NETWORK_NAME}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s/<vcenter_password>/${VCENTER_PASSWORD}/g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_username>#${VCENTER_USERNAME}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<vcenter_server_ip>#${VCENTER_SERVER_IP}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<rh_pull_secret>#${RH_PULL_SECRET}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml
    sed -i'' "s#<ocp_ssh_key>#${OCP_SSH_KEY}#g" ${OCP_ENV_FOLDER}${OCP_INSTALL_FOLDER}/install-config.yaml

    echo "The install-config.yaml file has been populated with information from ${LOCAL_ENV_PARAM} file "

echo ""
echo "Install-conifg.yaml file preparation is completed"


