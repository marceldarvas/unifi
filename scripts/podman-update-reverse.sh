cd /usr/libexec/podman

# Delete the symbolic link
rm conmon
# Restore the backup file
mv conmon.old conmon

cd /usr/bin
# Delete the symbolic link
rm podman
# Restore the backup file
mv podman.old podman

# Delete the symbolic link
rm runc
# Restore the backup file
mv runc.old runc

# Reverse this change
sed -i 's/driver = "overlay"/driver = ""/' /etc/containers/storage.conf

# Test it out
podman ps

# Delete the crazy file with the question marks. Run this, then after the first prompt, delete any junk in the terminal with backspace, and type a single 'y' character and hit enter. Then Ctrl+C to break out.
rm -i -- *