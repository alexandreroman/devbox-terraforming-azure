
# Terraforming a devbox VM in Azure

Using this project, you can create a virtual machine in Azure which includes
everything you need to run dev-related tasks, including your favorite tools:

- Java 17
- Docker Engine
- and more...!

No need to worry about installing those tools on your workstation.
You can create a VM with the tools you need. When you're done, just destroy
this VM to save resources (and money!).

This VM will be quite handy if you need to download stuff from Internet,
using the bandwidth from your Azure tenant:
you're not limited by your mobile connection 😉

## Prerequisites

Here are some prerequisites to use this app:

- an Azure tenant: for hosting your VM
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli): for authenticating with Azure
- [Terraform](https://www.terraform.io/): for managing Azure resources

## How to use it?

Make sure you are authenticated with your Azure tenant,
[using the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli).

Terraform will create resources in an existing Azure resource group.
If you need to create a new resource group, use this command:

```shell
az group create -l francecentral -n devbox
```

A default configuration is provided for creating Azure resources.
If you need to add your own settings, create a file `terraform.tfvars`
starting from [terraform.tfvars.template](terraform.tfvars.template):

```tfvars
az_location  = "francecentral"
az_res_group = "devbox"

devbox_user_login      = "devuser"
devbox_user_ssh_public = "~/.ssh/id_rsa.pub"
devbox_user_ssh_private = "~/.ssh/id_rsa"
```

The VM will be initialized with a set of default tools.
Edit [init-devbox.sh](init-devbox.sh) to customize the initialization process.

Run Terraform to create the VM and associated resources:

```shell
terraform apply
```

A few minutes later, you should be able to connect to your VM:

```shell
ssh -i ~/.ssh/id_rsa devuser@$(terraform output -raw devbox_public_ip_address)
```

The VM will be automatically shut down every day at 9:00 PM.

Use this command to destroy the VM (everything will be destroyed!):

```shell
terraform destroy
```

Hope it helps!

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2023 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
