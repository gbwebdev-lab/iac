# OpenTofu (Terraform)


```console
$ source ./secrets.env
$ tofu init --backend-config="./lab-minio.backend.config"
```

Import :
```console
tofu import maas_fabric.lab lab
tofu import maas_vlan.lab_infra_mgt lab:1
tofu import maas_subnet.lab_infra_mgt 1 
```