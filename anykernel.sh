# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=RZ Kernel for Exynos 8895 devices
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=dreamlte
device.name2=dream2lte
device.name3=greatlte
supported.versions=9
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
set_perm_recursive 0 0 750 750 $ramdisk/init*;
set_perm_recursive 0 0 755 755 $ramdisk/rz;
set_perm 0 0 750 $ramdisk/*.rc;

## AnyKernel install
dump_boot;

# begin system changes
ui_print "Cleaning old RZ leftovers...";
mount -o remount,rw /system;
rm -f $ramdisk/rz/scripts/40perf;
rm -f $ramdisk/rz/scripts/90userinit;
rm -f $ramdisk/init.spectrum.rc;
rm -f $ramdisk/init.spectrum.sh;
rm -f $ramdisk/sbin/rz_kernel.sh;
rm -f /system/bin/sysinit_cm;
rm -f /system/etc/init.d/30zram;
rm -f /system/etc/init.d/40perf;
rm -f /system/etc/init.d/90userinit;
rm -rf /data/rz_system;
rm -rf /system/rz_system;

ui_print "Cleaning previous kernels' leftovers...";
rm -rf /system/lib/modules;
rm -rf /system/etc/A2NKernelControl*;
rm -f /system/etc/init.d/99_user;
rm -rf /system/vendor/hades;
rm -rf $ramdisk/hades;

# Make init.d path if non-existent
ui_print "Initializing init.d support...";
mkdir /system/etc/init.d;
chmod 755 /system/etc/init.d;

chmod -R 0755 $home/rz_system;

## libsecure_storage patch ##
ui_print "Setting libsecure_storage permissions...";

# Delete wrongly replaced libsecure_storage paths
rm -rf /system/vendor/lib/libsecure_storage.so;
rm -rf /system/vendor/lib64/libsecure_storage.so;

# Change permissions
chmod 0644 $home/rz_system/lib/libsecure_storage.so;
chmod 0644 $home/rz_system/lib64/libsecure_storage.so;

## Vendor fimc binaries patch ##
ui_print "Setting fimc binaries permissions...";
device_name=$(file_getprop /default.prop ro.product.device);
if [ "$device_name" == "dream2lte" ] || [ "$device_name" == "dreamlte" ]; then
	rm -rf $home/rz_system/vendor/firmware_n8;
	mv -f $home/rz_system/vendor/firmware_s8 $home/rz_system/vendor/firmware;
elif [ "$device_name" == "greatlte" ]; then
	rm -rf $home/rz_system/vendor/firmware_s8;
	mv -f $home/rz_system/vendor/firmware_n8 $home/rz_system/vendor/firmware;
fi;
find $home/rz_system/vendor/firmware -name '*.bin' -exec chmod 0644 {} \;

ui_print "Copying patched files into system path";
cp -rf $home/rz_system /system/rz_system;
chmod 0755 /system/rz_system;

# Remove RMM lock (credits: @corsicanu)
ui_print "Removing RMM lock... (credits: corsicanu@XDA)";
replace_string /system/build.prop "ro.security.vaultkeeper.feature=1" "ro.security.vaultkeeper.feature=0";
sed -i 's/vaultkeeper\.feature\=1/vaultkeeper\.feature\=0/' /system/build.prop;
rm -f /system/lib/libvk*;
rm -f /system/lib64/libvk*;
rm -rf /system/priv-app/Rlc;
rm -rf /system/priv-app/KnoxGuard;

insert_line $ramdisk/init.rc "init.services.rc" after "import /init.environ.rc" "import /init.services.rc\n";

# Check device dtb
mv -f $home/*${device_name}*/Image $home/Image;
mv -f $home/*${device_name}*/dtb_$device_name.img $split_img/extra;

write_boot;
## end install

