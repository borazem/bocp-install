#! /bin/bash

echo ${1}

# erasing variables
export LOCAL_ENV_PARAM=""


# OCP environment checking
export LOCAL_ENV_PARAM=${1}

    if [[ -z "${LOCAL_ENV_PARAM}" ]]
        then
            echo "WARNING:"
            echo "  Please provide the environment <something>.env file as a parameter."
            echo "  Example: . make-installconfig.sh test.var"
            return      # exit from the script
        else
            if [[ -e "./${LOCAL_ENV_PARAM}" ]]
                then
                    source ./${LOCAL_ENV_PARAM}   # sourcing variables from the evnironment file
                    export OCP_ENV_FOLDER="./${OCP_ENV}/"
                    echo ""
                    echo "INFO: The MachineSets files will be created for env ${OCP_ENV} in ${OCP_ENV_FOLDER} folder."
                    echo ""
                else
                    echo ""
                    echo "WARNING: The file you have provided as a parameter does not exist, please provide existing file."
                    echo " "
            fi
    fi

# copy template files for macnineset and machineconfigpool for infra and odf nodes to a ./configs folder

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

    cd ./templates

    for f in ./*-tm.yaml
    do
        \cp "${f}" ".${OCP_ENV_FOLDER}${f/-tm/}"
        # \ in front of cp dont ask for overwrite, the /-t/ removes the -t from the name
        echo "INFO: ${f} has been copied to ${OCP_ENV_FOLDER}${f/-tm/}"
    done
    cd ..

# replace the placeholders in the machinesets and machineconfigpool configuration files
      sed -i'' "s#<infrastructure_id>#${INFRASTRUCTURE_ID}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_vm_network_name>#${VCENTER_VM_NETWORK_NAME}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_vm_template_name>#${VCENTER_VM_TEMPLATE_NAME}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_datacenter_name>#${VCENTER_DATACENTER_NAME}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_datastore_name>#${VCENTER_DATASTORE_NAME}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_vm_folder_path>#${VCENTER_VM_FOLDER_PATH}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_resource_pool>#${VCENTER_RESOURCE_POOL}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<vcenter_server_ip>#${VCENTER_SERVER_IP}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml ${OCP_ENV_FOLDER}odf-machineset.yaml

      sed -i'' "s#<infra_node_replicas>#${INFRA_NODE_REPLICAS}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml
      sed -i'' "s#<infra_diskgib>#${INFRA_DISKGIB}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml
      sed -i'' "s#<infra_mem>#${INFRA_MEM}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml
      sed -i'' "s#<infra_cpu>#${INFRA_CPU}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml
      sed -i'' "s#<infra_cpu_core>#${INFRA_CPU_CORE}#g" ${OCP_ENV_FOLDER}infra-machineset.yaml

      sed -i'' "s#<odf_diskgib>#${ODF_DISKGIB}#g" ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<odf_mem>#${ODF_MEM}#g" ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<odf_cpu>#${ODF_CPU}#g" ${OCP_ENV_FOLDER}odf-machineset.yaml
      sed -i'' "s#<odf_cpu_core>#${ODF_CPU_CORE}#g" ${OCP_ENV_FOLDER}odf-machineset.yaml

    echo ""
    echo "INFO: Machineset and machineconfig files for infra and odf have been configured in folder ${OCP_ENV_FOLDER}"

echo ""
echo "INFO: Machineset and machineconfig files preparation is complete"