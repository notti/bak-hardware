cd D:/Projekte/bak-hardware/processor
if { [ catch { xload xmp processor.xmp } result ] } {
  exit 10
}
xset intstyle default
save proj
exit 0
