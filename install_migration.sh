#!/bin/bash

storage_type=$(awk ''/^storage_type:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
installation_host_ip=$(awk ''/^installation_host_ip:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

ansible-playbook -i hosts ansible/create_base.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@config.yml"

if [[ $storage_type == "s3" ]]; then
ansible-playbook -i hosts ansible/install.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@aws_s3_config.yml" \
                                                      --extra-vars "@/tmp/cqube_migration/local_storage_config.yml" \
													  --extra-vars "@/tmp/cqube_migration/azure_container_config.yml"
    if [ $? = 0 ]; then
        echo "cQube Base installed successfully in remote machine!!"
	else
		exit;
    fi
fi
if [[ $storage_type == "azure" ]]; then
ansible-playbook -i hosts ansible/install.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@azure_container_config.yml" \
                                                      --extra-vars "@/tmp/cqube_migration/local_storage_config.yml" \
													  --extra-vars "@/tmp/cqube_migration/aws_s3_config.yml"
    if [ $? = 0 ]; then
        echo "cQube Base installed successfully in remote machine!!"
	else
        exit;

    fi
fi

if [[ $storage_type == "local" ]]; then
ansible-playbook -i hosts ansible/install.yml -e "my_hosts=$installation_host_ip" --tags "install" --extra-vars "@local_storage_config.yml" \
                                                      --extra-vars "@/tmp/cqube_migration/aws_s3_config.yml" \
													  --extra-vars "@/tmp/cqube_migration/azure_container_config.yml"
    if [ $? = 0 ]; then
        echo "cQube Base installed successfully in remote machine!!"
	else
        exit;

    fi
fi
