FROM ubuntu:latest

WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y p7zip-full xorriso wget && \
    apt-get clean

COPY ubuntu-24.04.2-live-server-amd64.iso ubuntu-24.04.2-live-server-amd64.iso

RUN mkdir sources && \
    7z -y x ubuntu-24.04.2-live-server-amd64.iso -osources

RUN mv sources/\[BOOT\] ./BOOT

COPY server sources/server

COPY grub.cfg sources/boot/grub/grub.cfg

WORKDIR /workspace/sources

RUN xorriso -as mkisofs -r \
  -V 'Ubuntu 22.04 LTS (Auto Install)' \
  -o ../ubuntu-24.04.2-autoinstall.iso \
  --grub2-mbr ../BOOT/1-Boot-NoEmul.img \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
  -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot .
