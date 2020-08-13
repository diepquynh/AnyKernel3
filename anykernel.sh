# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=RZ Kernel for Exynos 9810 devices
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=starlte
device.name2=starltexx
device.name3=star2lte
device.name4=star2ltexx
device.name5=crownlte
device.name6=crownltexx
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/platform/11120000.ufs/by-name/BOOT;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
dump_boot;

ui_print "Remounting vendor partition";
mount -o remount,rw /vendor;

ui_print "Remounting system partition"
if [ -e /system_root ]; then
	mount -o remount,rw /system_root;
	system_path=/system_root/system;
elif [ -e /system/system ]; then
	mount -o remount,rw /system;
	system_path=/system/system;
else
	mount -o remount,rw /system;
	system_path=/system;
fi;

sdk_ver=$(file_getprop $system_path/build.prop ro.system.build.version.sdk);
overlay_fstab=$system_path/product/vendor_overlay/$sdk_ver/fstab.samsungexynos9810;
vendor_fstab=/vendor/etc/fstab.samsungexynos9810;
if [ -e ${overlay_fstab} ]; then
	if [ ! -e ${overlay_fstab}~ ]; then
		ui_print "Backing up overlay fstab";
		backup_file $overlay_fstab;
	fi;

	ui_print "Copying patched overlay fstab";
	cp -f $home/vendor/etc/fstab.samsungexynos9810 $overlay_fstab;
else
	if [ ! -e ${vendor_fstab}~ ]; then
		ui_print "Backing up vendor fstab";
		backup_file $vendor_fstab;
	fi;

	ui_print "Copying patched vendor fstab";
	cp -f $home/vendor/etc/fstab.samsungexynos9810 $vendor_fstab;
fi;

ui_print "Copying vendor script";
cp -f $home/vendor/etc/init/init.services.rc /vendor/etc/init;

# Find device image/device tree
device_name=$(file_getprop /default.prop ro.product.device);
mv -f $home/$device_name/Image $home/Image;
mv -f $home/$device_name/dtb.img $split_img/extra;

write_boot;
## end install

