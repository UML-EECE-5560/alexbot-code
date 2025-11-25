sudo udisksctl mount -b /dev/nvme0n1p1
sudo udisksctl mount -b /dev/nvme0n1p2
sudo mkdir /media/student/writable/home/shared
sudo cp /home/student/alexbot-code/scrips/install.sh /media/student/writable/home/shared/install.sh
sudo chmod 777 /media/student/writable/home/shared/install.sh