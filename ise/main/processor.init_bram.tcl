cd D:/Projekte/bak-hardware/processor
if { [ catch { xload xmp processor.xmp } result ] } {
  exit 10
}

if { [catch {run init_bram} result] } {
  exit -1
}

exit 0
