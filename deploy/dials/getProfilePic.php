<?php

$url = 'http://twinoid.com/user/'.(int)$_GET['pic'];
$fh = fopen($url, "rb") or die("cannot open remote file");
$contents = stream_get_contents($fh);
fclose($fh);

$matches = array();
preg_match('/.*<img class="tid_avatarImg" src="(.*?)".*/i', $contents, $matches);

if(count($matches) > 1) {
	echo $matches[1]."\n";
}else {
	echo "\n";
}
		
$matches = array();
preg_match('/.*<span onEdit="window.location=.*?">(.*?)<\/span>.*/i', $contents, $matches);
echo $matches[1];

?>