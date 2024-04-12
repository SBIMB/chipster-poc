## Adding a Logical Volume to Linux Machine
### Logical Volumes
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

Now we'd like to mount this file system to a directory on our Linux machine. First, we create a new directory called `chipster_tools`,
```bash
mkdir /chipster_tools
```
and then we mount the file system as follows:
```bash
sudo mount /dev/chipster/chipster_tools_lv /chipster_tools   
```
![Mounted Chipster Tools Directory](/public/assets/images/mounted-chipster-tools-directory.png "Mounted Chipster Tools Directory")     

If ever required, we can extend the size of the logical volume by using the `lvextend` command. We can extend it by a percentage (let's say `50%`) of the free space inside the volume group, e.g.
```bash
lvextend -l +50%FREE /dev/chipster/chipster_tools_lv
```
