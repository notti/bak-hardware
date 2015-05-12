proc pngeninsttemplate {} {
  cd D:/Projekte/bak-hardware/processor
  if { [ catch { xload xmp processor.xmp } result ] } {
    exit 10
  }
  if { [catch {run mhs2hdl} result] } {
    return -1
  }
  return 0
}
if { [catch {pngeninsttemplate} result] } {
  exit -1
}
exit $result
