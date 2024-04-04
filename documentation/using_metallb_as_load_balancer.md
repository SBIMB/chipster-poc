## Installation of Metal LB Load Balancer on K3s Cluster
The installation of the `k3s` cluster needs to have the _"--disable servicelb"_ flag set, so the following command should be run:
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb" sh -s - --write-kubeconfig-mode 644
```   
This will remove the default internal load balancer, `servicelb` (formerly known as `klipper`). We'd like to use [Metal LB](https://metallb.universe.tf/) because it will allow for the IP address of the node to be externally available.   

Using Helm, we begin the deployment by adding the `metallb` chart repository with:
```bash
helm repo add stable https://charts.helm.sh/stable
```
In the past, `metallb` used to be configured using config maps because that’s traditionally where configs were placed. However, now it uses custom resources (CRs). We'll create a namespace called `metallb-system` and then perform a Helm deployment for all the `metallb` resources:
```bash
kubectl create ns metallb-system
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --namespace metallb-system
```
Now we need to create two additional resources, an address pool and a layer two advertisement, which instructs `metallb` to use the address pool. Here are the manifests of the two resources (saved inside the `metallb` directory):
**IPAddressPool.yaml**   
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: k3s-cloud05-pool
  namespace: metallb-system
spec:
  addresses:
  - 146.141.240.75/32
```
**L2Advertisement.yaml**   
```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: k3s-cloud05-l2advertisment
  namespace: metallb-system
spec:
  ipAddressPools:
  - k3s-cloud05-pool
```
To create these resources, we need to run the `kubectl apply -f` command:
```bash
kubectl -n metallb-system apply -f metallb/IPAddressPool.yaml
kubectl -n metallb-system apply -f metallb/L2Advertisement.yaml
```
To see if the resources have been created, we can run:
```bash
kubectl get pods -n metallb-system
```
and should get an output that looks similar to:   

| NAME                                | READY | STATUS   | RESTARTS   | AGE |
| ----------------------------------- | ----- | -------- | ---------- | --- |
| metallb-speaker-dzcks               | 4/4   | Running  | 0          | 20m |
| metallb-controller-6cb58c6c9b-p9dqz | 1/1   | Running  | 1 (9m ago) | 20m |