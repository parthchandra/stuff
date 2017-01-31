BEGIN { OFS = ","; 
    print "Time", "ms", "Operation", "Thread", "name", "time"
}
{
  if( $0 ~ /BufferedDirectBuf.*start/ ) {
    print $2, "Disk Read Start", $4, $12 
  } else if( $0 ~ /BufferedDirectBuf.*complete/ ) {
    print $2, "Disk Read Stop", $4, substr($12, 1, length($12)-1), $28
  } else if ( $0 ~ /AsyncPageReader.*read start.*Header/ ) {
    print $2, "Page Header Read Start", $4, $12
  } else if ( $0 ~ /AsyncPageReader.*read stop.*Header/ ) {
    print $2, "Page Header Read Stop", $4, $12, $27
  } else if ( $0 ~ /AsyncPageReader.*read start/ ) {
    print $2, "Page Read Start", $4, $13
  } else if ( $0 ~ /AsyncPageReader.*read stop/ ) {
    print $2, "Page Read Stop", $4, $13, $27
  } else if ( $0 ~ /AsyncPageReader.*Start Disk Wait/ ) {
    print $2, "Page Read Wait Start", $4, "" 
  } else if ( $0 ~ /AsyncPageReader.*Stop Disk Wait/ ) {
    print $2, "Page Read Wait Stop", $4, "", $16
  } else if ( $0 ~ /ScanBatch.*Start/ ) {
    print $2, "Scan Decode Start", $4, $11
  } else if ( $0 ~ /ScanBatch.*Stop/ ) {
    print $2, "Scan Decode Stop", $4, $11, $15
  } else if ( $0 ~ /AbstractSingleRecordBatch.*Start/ ) {
    print $2, "Operator Start", $4, $11
  } else if ( $0 ~ /AbstractSingleRecordBatch.*Stop/ ) {
    print $2, "Operator Stop", $4, $11, $15
  } else {
  }
}
