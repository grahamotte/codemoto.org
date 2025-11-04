class SwapPatch < BasePatch
  class << self
    def needed?
      result = Cmd.ssh("sudo swapon --show")
      result.blank? || !result.include?("/swapfile")
    end

    def apply
      Cmd.ssh("sudo swapoff -a")
      Cmd.ssh("sudo rm -f /swapfile")
      Cmd.ssh("sudo fallocate -l 5G /swapfile")
      Cmd.ssh("sudo chmod 600 /swapfile")
      Cmd.ssh("sudo mkswap /swapfile")
      Cmd.ssh("sudo swapon /swapfile")
      Cmd.ssh("sudo swapon --show")
    end
  end
end

# deploy@graham:~$ htop
# deploy@graham:~$ sudo swapon --show
# deploy@graham:~$ df -h
# Filesystem      Size  Used Avail Use% Mounted on
# tmpfs           197M  1.1M  196M   1% /run
# /dev/vda1        48G   15G   33G  31% /
# tmpfs           984M  1.5M  983M   1% /dev/shm
# tmpfs           5.0M     0  5.0M   0% /run/lock
# tmpfs           984M  2.4M  982M   1% /tmp
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-udev-load-credentials.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev-early.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-sysctl.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup-dev.service
# /dev/vda13      989M  115M  808M  13% /boot
# /dev/vda15      105M  6.1M   99M   6% /boot/efi
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-tmpfiles-setup.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyS0.service
# tmpfs           1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
# tmpfs           197M   16K  197M   1% /run/user/1000
# deploy@graham:~$ sudo fallocate -l 5G /swapfile
# deploy@graham:~$ ls -lh /swapfile
# -rw-r--r-- 1 root root 5.0G Oct 18 22:36 /swapfile
# deploy@graham:~$ sudo chmod 600 /swapfile
# deploy@graham:~$ sudo mkswap /swapfile
# Setting up swapspace version 1, size = 5 GiB (5368705024 bytes)
# no label, UUID=4994747f-5d4c-4837-b6c5-913c0ab82d7e
# deploy@graham:~$ sudo swapon /swapfile
# deploy@graham:~$ sudo swapon --show
# NAME      TYPE SIZE USED PRIO
# /swapfile file   5G   0B   -2
# deploy@graham:~$
