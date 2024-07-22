## Installing NGINX Ingress Controller
### Using Helm
Using Helm, we can install the `ingress-nginx` controller as follows:
```bash
helm upgrade --install ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx --create-namespace
```

### Without Helm (using Manifests)
Instead of using Helm, the NGINX ingress controller can be created directly from a manifest:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/baremetal/deploy.yaml
```
(This manifest file has been copied and saved to this repository, `ingress-nginx-controller/ingress-nginx-controller-v1.7.1.yaml`).   

After a short while, we can run the following command to see if the pods are up and running:
```bash
kubectl get pods --namespace=ingress-nginx
```
The service, `ingress-nginx-controller`, should be edited to be of type `LoadBalancer` instead of `NodePort`. This will result in an external IP being exposed for the service (assuming Metallb has been setup as a load balancer).   

A local port can be forwarded to the ingress controller:
```bash
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

Here is an example Ingress that makes use of the controller: 
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example
  namespace: foo
spec:
  ingressClassName: nginx
  rules:
    - host: www.example.com
      http:
        paths:
          - pathType: Prefix
            backend:
              service:
                name: exampleService
                port:
                  number: 80
            path: /
  # This section is only required if TLS is to be enabled for the Ingress
  tls:
    - hosts:
      - www.example.com
      secretName: example-tls

# If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:
apiVersion: v1
kind: Secret
metadata:
  name: example-tls
  namespace: foo
data:
  tls.crt: <base64 encoded cert>
  tls.key: <base64 encoded key>
type: kubernetes.io/tls
```

**NOTE:** The test `my-deployment` resources can be deleted after confirming that the ingress controller is working as desired:
```bash
kubectl delete deployment my-deployment
kubectl delete service my-deployment
kubectl delete ingress my-deployment-ingress
```

### Uninstalling NGINX Ingress Controller
To uninstall the `nginx` ingress controller, first start by deleting the namespace:
```bash
kubectl delete namespace ingress-nginx
```
Then remove the `clusterrole` and `clusterrolebinding`:
```bash
kubectl delete clusterrole ingress-nginx
kubectl delete clusterrolebinding ingress-nginx
```
That should be enough, but a list of crds can be checked with:
```bash
kubectl get crds
```
If any of them contain something to do with `nginx`, they should be deleted. The core crds can be deleted with:
```bash
kubectl delete -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v3.5.1/deploy/crds.yaml
```
(The above deletion may not work (and may not be necessary), depending on the NGINX versions and whether or not the crds were already removed during the previous deletion steps).