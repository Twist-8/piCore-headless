#!/bin/sh
#

# test if we weren't run once before...
if [ -f /tmp/p1/pre/newpartitiontable ]; then 
        # if so, just move on
        echo "the file 'newpartitiontable' already exists, so not doing any fdisk work" 
else
        # okay, so let's do our partioning business
        # extract the current p2 start, end and total sectors from fdisk -l
        start_p2=`fdisk -l /dev/mmcblk0 | awk -F" " /mmcblk0p2/'{print $4}'`
        end_p2=`fdisk -l /dev/mmcblk0 | awk -F" " /mmcblk0p2/'{print $5}'`
        sectors=`fdisk -l /dev/mmcblk0 | awk -F" " /sectors$/'{print $7}'`

        echo "now start of p2 = ${start_p2} and end = ${end_p2}"

        # test if a new size for p2 is specified (file with value exists)
        if [ -f /tmp/p1/pre/setp2size ]; then
                # if it does, let's use its contents as the end value for p2
                new_endp2=`cat /tmp/p1/pre/setp2size`
        else
                # otherwise use all of the disk (last sector will be total sectors - 1)
                new_endp2=$((sectors - 1))
        fi

        echo "new p2 will be from ${start_p2} to ${new_endp2}"


        # The below heredoc launches fdisk for the SD card, with units sectors
        # then d(elete partition) 2, n(ew), p(rimary partition number) 2, starts, ends, w(rite partition table) 

{
fdisk -u /dev/mmcblk0 << UPTOHERE
d
2
n
p
2
$start_p2
$new_endp2
w
UPTOHERE
}


        sleep 1
        echo "done the partition table changes."

#       # let's mount the disk again
#       mount -t vfat -o uid=1001,gid=50,fmask=0000,dmask=0000,allow_utime=0022,codepage=437,users,exec,umask=000,relatime /dev/mmcbl1

        # dump the new partiton table into a file that also serves as a flag that we've done this
        fdisk -l > /tmp/p1/pre/newpartitiontable
        echo "new partition table written to 'newpartitiontable'"

        # flag the need to expand in the next phase (after reboot)
        touch /tmp/p1/pre/resize2fs_needed
        echo "now rebooting to make the new partition table active"
        sleep 1
        reboot
        exit
fi

# Let's test if we need to resize the filesystem
if [ -f /tmp/p1/pre/resize2fs_needed ]; then
        # yes we need to so...
        # this can take a while. Let's inform the user
        echo "now expanding the filesystem on partition 2. This can take a while."
        resize2fs /dev/mmcblk0p2
        # we can remove the flag now
        rm -f /tmp/p1/pre/resize2fs_needed
else
        # no, not needed
        echo "not resizing the filesystem on p2"
fi
