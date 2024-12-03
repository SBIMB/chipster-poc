## Logical Volumes with Linux
### Adding A Logical Volume
There exists a volume group called `chipster` which has about `3.6TB` of available storage space. The physical volume corresponding to this volume group is `/dev/sdc1`.   

Our goal is to create two logical volumes, namely `chipster_tools_lv` and `chipster_data_lv` of about `750GB` each. The `chipster_tools_lv` will be the place where the `tools-bin` package will be installed, and the `chipster_data_lv` will be where uploaded data files will be stored.   

The volume groups can be listed with the command:
```bash
sudo pvs
```
and a more detailed description of a particular volume group, in this case `chipster`, can be seen with:
```bash
sudo vgdisplay chipster
```
![Chipster Volume Group Details](/public/assets/images/vgdisplay-chipster.png "Chipster Volume Group Details")    

We use the `lvcreate` command to create a new logical volume. The command is as follows:
```bash
sudo lvcreate -L 750G -n chipster_tools_lv chipster
```
The status of the newly created logical volume can be seen with:
```bash
sudo lvs /dev/chipster/chipster_tools_lv
```
and a more detailed description of the logical volume can be seen with:
```bash
sudo lvdisplay /dev/chipster/chipster_tools_lv
```
![Chipster Tools Logical Volume](/public/assets/images/chipster-tools-lv.png "Chipster Tools Logical Volume")    

The same steps can be followed for adding the logical volume called `chipster_data_lv`.   

Our next task is to format the logical volume with a particular file system. For large files, it is recommended to use **XFS**, since it can perform input and output simultaneously. Consequently, frontend applications and end users can store and retrieve data faster. Since `chipster` has a frontend component to it, and the files involved are generally quite large, the **XFS** file system would be ideal. The following command will format the logical volume with the **XFS** file system:
```bash
sudo mkfs.xfs /dev/chipster/chipster_tools_lv
```
![Chipster Tools XFS File System](/public/assets/images/chipster-tools-file-system.png "Chipster Tools XFS File System")    

Now we'd like to mount this file system to a directory on our Linux machine. First, we create a new directory called `chipster`,
```bash
sudo mkdir -p /mnt/data/chipster
sudo chown $(whoami) /mnt/data/chipster
```
and then we mount the file system as follows:
```bash
sudo mount /dev/chipster/chipster_tools_lv /mnt/data/chipster
```
![Mounted Chipster Tools Directory](/public/assets/images/mounted-chipster-tools-directory.png "Mounted Chipster Tools Directory")     
To ensure that the file system does _not_ get unmounted when the system is rebooted, we should update the `/etc/fstab` configuration file with the relevant data in the format:
```bash
<file system> <mount point> <type> <options> <dump> <pass>
```
We can get some of this information by running the command:
```
df -kHT
```
and looking at the different columns in the output table. In our case above, the `/etc/fstab` should be updated with the following:
```bash
/dev/mapper/chipster-chipster_tools_lv /mnt/data/chipster xfs defaults 0 2
```
The `dump` parameter is used by the dump utility to decide if the file system should be backed up. The key-value pairs are:   

- 0: Do not back up the file system
- 1: Back up the file system during `dump`   

The `pass` parameter determines the order in which the file systems get checked during boot or reboot. The key-value pairs are:   

- 0: Do not check the file system
- 1: Check file system first (common for root file systems)
- 2: Check file system after the root file system   

If ever required, we can extend the size of the logical volume by using the `lvextend` command. We can extend it by a percentage (let's say `50%`) of the free space inside the volume group, e.g.
```bash
lvextend -l +50%FREE /dev/chipster/chipster_tools_lv
```
For session storage (i.e., when Chipster jobs are being run), we should create a directory called `/mnt/data/chipster/file-storage` and ensure that this path is specified in the relevant pod or deployment manifest (the `file-storage` pod).

### Removing A Logical Volume
To remove a logical volume from a volume group, the first step is to unmount the file system with the `umount` command:
```bash
umount /chipster_tools
```
The `/etc/fstab` file can be checked to verify that an entry to automatically mount the file system doesn't exist. If one exists, the entry should be removed and the changes saved.   

Now the logical volume can be removed using the `lvremove` command:
```bash
lvremove vg0/myvol
```
To verify that the removal was successful, check the output of:
```bash
sudo vgs
```
The storage that was assigned to the logical volume should be made available to the volume group.
