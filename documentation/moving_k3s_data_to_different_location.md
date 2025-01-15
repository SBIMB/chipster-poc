## Moving k3s Data to a Different Location   

Data for k3s has the following locations:
- `/run/k3s`
- `/var/lib/kubelet/pods`
- `/var/lib/rancher`   

These directories, particularly `/var/lib/rancher/k3s/storage`, can become very large. It might be desired to move the storage directory to an external drive or a logical volume. We can do this with the following steps:

```bash
# Stop the k3s daemon
systemctl stop k3s
systemctl stop k3s-agent
/usr/local/bin/k3s-killall.sh

# Copy the files
mv /run/k3s/ /mnt/data/chipster/k3s/
mv /var/lib/kubelet/pods/ /mnt/data/chipster/k3s-pods/
mv /var/lib/rancher/ /mnt/data/chipster/k3s-rancher/

# Create symbolic links
ln -s /mnt/data/chipster/k3s/ /run/k3s
ln -s /mnt/data/chipster/k3s-pods/ /var/lib/kubelet/pods
ln -s /mnt/data/chipster/k3s-rancher/ /var/lib/rancher

# Start the daemon
systemctl start k3s
systemctl start k3s-agent
```