cd D:/Projekte/bak-hardware/processor/
if { [ catch { xload xmp processor.xmp } result ] } {
  exit 10
}
xset hdl vhdl
run stubgen
exit 0
