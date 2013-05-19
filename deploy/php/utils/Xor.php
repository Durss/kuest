<?php
class Xorer {
	public static function bitxor($o1, $o2) {
		$res = '';
		$modulo = strlen($o1);
		$runs = strlen($o2);
		for ($i = 0; $i < $runs; $i++) {
			$res .= chr(ord($o1[$i % $modulo]) ^ ord($o2[$i]));
		}
		return $res;
	}
}
?>