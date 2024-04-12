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
