#!/bin/bash
set -e

# lookup specific binaries
: "${BIN_7Z:=$(type -P 7z)}"
: "${BIN_XORRISO:=$(type -P xorriso)}"

# get parameters
TARGET_ISO=${1:-"`pwd`/debian-9-netboot-amd64-unattended.iso"}

# get directories
CURRENT_DIR="`pwd`"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DOWNLOAD_DIR="`mktemp -d`"
TMP_DISC_DIR="`mktemp -d`"
TMP_INITRD_DIR="`mktemp -d`"

# download and extract netboot iso
SOURCE_ISO_URL="https://cdimage.debian.org/debian-cd/9.5.0/amd64/iso-cd/debian-9.5.0-amd64-netinst.iso"
cd "$TMP_DOWNLOAD_DIR"
wget -4 "$SOURCE_ISO_URL" -O "./netboot.iso"
"$BIN_7Z" x "./netboot.iso" "-o$TMP_DISC_DIR"

# patch boot menu
cd "$TMP_DISC_DIR"
dos2unix "./isolinux/isolinux.cfg"
patch -p1 -i "$SCRIPT_DIR/custom/boot-menu.patch"

# prepare assets
cd "$TMP_INITRD_DIR"
mkdir "./custom"
cp "$SCRIPT_DIR/custom/preseed.cfg" "./preseed.cfg"

# append assets to initrd image
cd "$TMP_INITRD_DIR"
cat "$TMP_DISC_DIR/install.amd/initrd.gz" | gzip -d > "./initrd"
echo "./preseed.cfg" | fakeroot cpio -o -H newc -A -F "./initrd"
find "./custom" | fakeroot cpio -o -H newc -A -F "./initrd"
cat "./initrd" | gzip -9c > "$TMP_DISC_DIR/install.amd/initrd.gz"

# build iso
cd "$TMP_DISC_DIR"
rm -r '[BOOT]'
"$BIN_XORRISO" -as mkisofs -r -V "debian_9_netboot_unattended" -J -b isolinux/isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -o "$TARGET_ISO" ./
#xorriso -as mkisofs -o preseed-debian-9.3.0-i386-netinst.iso -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table isofiles

# go back to initial directory
cd "$CURRENT_DIR"

# delete all temporary directories
rm -r "$TMP_DOWNLOAD_DIR"
rm -r "$TMP_DISC_DIR"
rm -r "$TMP_INITRD_DIR"

