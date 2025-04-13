# OpenTofu (Terraform)

## Setup

The S3 backend credentials are stored in `secrets.env` and the connection settings in `lab-minio.backend.config`. \
Do not forget to create `secrets.env` from `secrets.env.tpl` and replace credentials.

```console
source ./secrets.env
tofu init --backend-config="./lab-minio.backend.config"
```

The MAAS backend credentials are stored in `secrets.auto.tfvars`. \ 
Do not forget to create `secrets.auto.tfvars` from `secrets.auto.tfvars.tpl` and replace credentials.

MAAS automatically creates the main fabric (we'll rename it to "lab") as well as the untagged vlan and subnet. \
The fabric can be declared using a data source be we do not want to do the same with vlan and subnet as we wish to use tf to change their settings. \
So we have to import it in the state BEFORE running the first apply.

```console
# tofu import maas_fabric.lab lab  # Using data, so not used anymore
tofu import maas_vlan.lab_infra_mgt lab:1
tofu import maas_subnet.lab_infra_mgt 1 
```

[//]: #TODO : explain  the logic behind the project and module.