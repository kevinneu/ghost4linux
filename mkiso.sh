#!/bin/sh

echo "Ghost for Linux based on g4l."
echo "Chen Hongquan"
sleep 3

echo "Clean up first"
OLD_ISO=`find -iname boot.iso`
if [ $OLD_ISO != "" ] ;
then `rm -f $OLD_ISO`
fi

#ramdisk_size=32768
#ramdisk_size=65535
#ramdisk_size=98304
ramdisk_size=131072


echo "Creating ramdisk"
dd if=/dev/zero of=bootcd/ramdisk bs=1k count=$ramdisk_size

echo "Creating loop device"
losetup /dev/loop0 bootcd/ramdisk

echo "Creating ext2 filesystem"
mke2fs -m -0 -N 4000 /dev/loop0

echo "Mounting loop device in /mnt"
mount /dev/loop0 /mnt

echo "Deleting lost+found"
rm -R /mnt/lost+found

echo "Copy rootfs files to ramdisk to /mnt"
cp -R rootfs/* /mnt

cp -p rootfs/.bash_profile /mnt

echo "Umounting /mnt"
umount /mnt

echo "Delete loop device"
losetup -d /dev/loop0

echo "Compressing ramdisk"
LZMA=`which lzma 2>/dev/null `
if [ $? = "0" ] ;
    then echo $LZMA
else
    echo "lzma package is required "
exit 1
fi

lzma -v bootcd/ramdisk
gzip bootcd/ramdisk


echo "Deleting ramdisk"
rm bootcd/ramdisk.gz

echo "Creating ISO9660/Joliet/RopckRidge filesystem"

mkisofs -l -allow-leading-dots -V "Ghost4Linux" -cache-inodes -J -R -o ./boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -input-charset utf-8 -boot-info-table bootcd

echo "DONE..."
