Credit to Reddit u/pcpcy

https://www.reddit.com/r/Ubiquiti/comments/kx6sig/sshfs_or_rsync_on_udmpro/?utm_source=share&utm_medium=web2x&context=3


It is possible to install either an SFTP server (for SSHFS to work) or rsync within the unifi-os container, OR on the base OS. In both cases you can access the protect folder. I don't use protect myself, but from some research I believe the backup folder is at /mnt/data/unifi-os/unifi/data/backup/autobackup/. Please tell me if it's at another folder location.

Option 1: SFTP/SSHFS or rsync within unifi-os container

1.SSH into the udmp, go into the unifi-os container, and install the sftp server and rsync using APT.

ssh root@192.168.1.254 
unifi-os shell
apt install openssh-sftp-server rsync
2.The last command will end with an error due to attempting to start SSH server on port 22 (since port 22 is in use by the base OS SSH server). We will change the SSH server port to 2222 and allow root to login.

echo "Port 2222" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
3.Run passwd to change the root password (you can set it to the same as the base OS).

4.Start the ssh server in the unifi-os shell and enable it to start on boot.

systemctl start ssh
systemctl enable ssh
5.Now you should be able to login with any SFTP client on port 2222. You should also be able to use SSHFS on port 2222. You should also be able to use rsync from another computer on port 2222 like so

rsync -av -e 'ssh -p 2222' root@192.168.1.254:/files-to-move ./
6.Mount the /mnt/data directory (which contains the protect files) within the unifi-os container by running,

mkdir -p /mnt/data
mount /dev/sda6 /mnt/data
7.Now you should be able to access the protect video files at /mnt/data/unifi-os/unifi/data/backup/autobackup/ from within the unifi-os container, and hence from SSHFS/SFTP or rsync (on port 2222).

8.NOTE: The rsync and sftp-server packages you install in the unifi-os container via apt will not get removed when you reboot or upgrade the firmware, and will actually get reinstalled every update. However, the configuration files will be reset (like changing the port to 2222). Which means you need to run a boot script to change the port to 2222 every update and allow root login, and possibly change the passwd. You can also add SSH keys and use SSH keys to login without a password by configuring the ssh server as you normally would within the unifi-OS container.

Option 2: SFTP/SSHFS or rsync on base-os

This is possible but a little more work. You just need to follow the above steps to install the rsync/sftp binaries within the unifi-os container, and then copy the binaries from the unifi-os container to the base OS. Make sure /mnt/data is mounted within the unifi-os container because we will use it for copying files to the base OS.

1.Within the unifi-os container (NOT base OS), copy the binaries to /mnt/data/binaries. Note the .so library files are dependencies for rsync. They are not needed if you only plan to use the sftp-server/SSHFS.

mkdir -p /mnt/data/binaries
cp /usr/lib/sftp-server /mnt/data/binaries/
cp /usr/bin/rsync /mnt/data/binaries/
cp /lib/aarch64-linux-gnu/libacl.so.1 /mnt/data/binaries/
cp /lib/aarch64-linux-gnu/libattr.so.1 /mnt/data/binaries/
cp /lib/aarch64-linux-gnu/libpopt.so.0 /mnt/data/binaries/
exit
2.Exit from the unifi-os container back to the base OS, and copy the files to the proper locations on the base OS. Make sure you ran the last exit command in Step 1 to get back the base OS first.

cp /mnt/data/binaries/sftp-server /usr/libexec/
cp /mnt/data/binaries/rsync /usr/bin/
cp /mnt/data/binaries/lib* /usr/lib/
3.That's it. Now you should be able to login with any SFTP client or rsync on port 22 (default port) to access the base OS directly. You should also be able to use SSHFS on port 22 too. Note the port is not 2222 like within the unifi-os container since we didn't change it here from the default.

4.Protect files are again at /mnt/data/unifi-os/unifi/data/backup/autobackup/I believe. No need to mount the /mnt/data folder like we did in unifi-os since that's already mounted in the base OS.

5.NOTE: Unlike the Unifi-OS container, all changes are wiped on the base OS at every reboot (/mnt/data is never wiped though). Which means you need to run a boot script to copy these files EVERY boot, not just every update. This can be a really simple script that just copies these binaries from /mnt/data/binaries to the right folders at startup. You do not need to re-installl these files within the unifi-os container once you already have the files saved on /mnt/data, if you only plan to use the base OS for sftp/rsync. We just installed it in unifi-os the first time to obtain the right files.



If you're doing option 2 (base OS), you just need to copy the files to /mnt/data from the Unifi OS the first time. /mnt/data is shared in both the base os and the Unifi OS (because we mounted it in Unifi). Also, /mnt/data never gets deleted, so you can copy the binaries from /mnt/data/binaries to the right folders every reboot and you don't have to worry about unifi-os anymore.

So basically if you copied the binaries to /mnt/data, your on boot script can just be this:

#!/bin/sh
cp /mnt/data/binaries/sftp-server /usr/libexec/
cp /mnt/data/binaries/rsync /usr/bin/
cp /mnt/data/binaries/lib* /usr/lib/
Save it as install-sftp.sh in the folder /mnt/data/on_boot.d/ in the base OS. Then run chmod +x /mnt/data/on_boot.d/install-sftp.sh. Next time you reboot, it should copy the binaries to the right folders on the system.