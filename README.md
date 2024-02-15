# Chipster-POC

## Introduction
This repository contains all configuration and manifest files for the installation or deployment of [chipster](https://github.com/chipster/chipster-openshift/tree/k3s) on our K3s cluster (the K3s cluster is currently hosting the [Gen3](https://github.com/sbimb/gen3-dev) workloads).

## Setup of Chipster
The instructions for installing `chipster` can be found in [their repository](https://github.com/chipster/chipster-openshift/blob/k3s/k3s/README.md). However, there are some subtle differences in our case, since we already have a K3s cluster running on bare-metal Ubuntu. The rest of this README will assume there is a K3s cluster already running, with `helm` and `kubectl` already installed.      

Firstly, we need to have some prerequisites installed on our Ubuntu machine, namely:
- [ansible](https://docs.ansible.com/)
- [yq](https://github.com/mikefarah/yq/blob/master/README.md)
- [diceware](https://pypi.org/project/diceware/)

There are many different ways to install the above tools, so we'll cover the way in which we performed the installation. To install `ansible`, run (this assumes that the `apt` package manager is already installed):
```bash
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

To install `yq`, the following command can be run:
```bash
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
```
Then permissions need to be given to the folder where the executable is located:
```bash
sudo chmod a+x /usr/local/bin/yq
```
To verify that the installation was successful, run:
```bash
yp --version
```
To install `diceware`, run (this assumes that the `apt` package manager is installed):
```bash
sudo apt-get -y install diceware
```
The installation can be verified with:
```bash
diceware --version
```
If all the prerequite libraries or tools have been successfully installed, we should be ready to clone the `chipster` repository now:
```bash
 git clone https://github.com/chipster/chipster-openshift.git
```
Navigate into the `k3s` directory:
```bash
cd chipster/openshift/k3s
```
This directory contains the `helm` charts for the `chipster` workloads. Inside, the `helm` directory (`/yourHomeDirectory/chipster-openshift/k3s/helm`), there exists a `values.yaml` file that will need to be used to perform a Helm deployment. If we take a look at the `values.yaml` file, we'll notice that the `password` fields are all empty. We need to get those passwords before a Helm deployment can be successfully performed.   

There exists a password generating script inside the repository, which by now should have been cloned and probably located at `/yourHomeDirectory/chipster-openshift/k3s`. Inside this directory, script can be executed with:
```bash
bash generate-passwords.bash
``` 
A kubernetes secret called `passwords` gets created and saved to the `default` namespace. This secret contains all the passwords that are needed in the `values.yaml` for the Helm deployment. The base64 encoded value for the passwords can be seen in the secret with:
```bash
kubectl get secret passwords -o yaml
```
In the `data` key of the secret manifest, a base64 encoded value exists which contains all the passwords in JSON format. To see these passwords, the following command can be run to decode the passwords:
```bash
echo 'base64 value in secret' | base64 --decode
```
These passwords could be manually copied and pasted into the `values.yaml`. This would be painfully tedious, since there are many passwords.