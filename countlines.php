<?php

define('FILEPATTERN','/.*\.rb$/i');
$exemptdirs = array('.','..');


print("\nTotal lines: ".countlines('./')."\n");

function countlines($dir) {
  global $exemptdirs;
  $dirp = opendir($dir);
  $tot = 0;
  while (($file = readdir($dirp)) !== false) {
    if (array_search($file,$exemptdirs) !== false) { continue; }
    if (is_dir($dir.$file)) {
      $tot += countlines($dir.$file.'/');
    } elseif (preg_match(FILEPATTERN,$file)) {
      $tot += count(file($dir.$file));
    }
  }
  return $tot;
}


?>
