podman pull dperson/samba:latest
podman stop nas
podman rm nas
podman run -d -p --network nas 139:139 -p 445:445 -p 137:137/udp -p 138:138/udp \
    --name nas \
    -u "teleport:hkn4!ovNMUYQGjaZGvpUTi.D" \
    -u "marcel:EB.VTVDXBPbdVFEpr@C7NbJK" \
    -s "Backups:/share/backups:rw:teleport,marcel" \
    -s "NVR:/share/nvr:rw:teleport,marcel" \
    -s "Utilities (private):/share/data/teleport:rw:teleport" \
    -s "Marcel (private):/share/data/marcel:rw:marcel" \
    -s "Documents (readonly):/share/data/documents:ro:teleport,marcel" \
    -s "shared;/share;yes;no;yes;all;none;none;Shared files" \
    -s "Public (readonly):/share/data/public:ro:" \
    -g "usershare allow guests = yes" \
    -g "map to guest = bad user" \
    -g "load printers = no" \
    -g "printcap cache time = 0" \
    -g "printing = bsd" \
    -g "printcap name = /dev/null" \
    -g "disable spoolss = yes" \
    -v /mnt/drive/share:/share:Z \ 
    -v /etc/timezone:/etc/localtime:ro \
    --hostname samba \
    dperson/samba:latest
