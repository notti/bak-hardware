cd /home/notti/fpga/bakk/processor
if { [xload xmp system.xmp] != 0 } {
  exit -1
}
xset intstyle default
save proj
exit 0
