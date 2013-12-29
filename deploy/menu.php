		<div class="menu">
			<button id="menu-bt-twino" class="big twinoid" onclick="window.location='http://twinoid.com'" data-ot="Twinoid" data-ot-tip-joint="left"  data-ot-target="#menu-bt-twino"><img src="/kuest/img/twinoid_logo.png"/></button>
			<?php
			$enabled = (strpos($_SERVER['REQUEST_URI'], 'browse') === false && preg_match('/\/kuest\/?$/i', $_SERVER['REQUEST_URI']) == false && $_SERVER['REQUEST_URI'] != '/');
			$css = $enabled? 'big' : 'big disabled';
			$attributes = !$enabled? '' : ' data-ot="'.$menu_kuestsTT.'" data-ot-tip-joint="top" data-ot-target="#menu-bt-list"';
			?>
			<a href="/kuest/browse"><button id="menu-bt-list" class="<?php echo $css; ?>"<?php echo $attributes; ?>><img src="/kuest/img/list.png"> <?php echo $menu_kuests; ?></button></a>
			<?php
			$enabled = (strpos($_SERVER['REQUEST_URI'], 'history') === false);
			$css = $enabled? 'big' : 'big disabled';
			$attributes = !$enabled? '' : ' data-ot="'.$menu_histoButtonTT.'" data-ot-tip-joint="top" data-ot-target="#menu-bt-histo"';
			?>
			<a href="/kuest/history"><button id="menu-bt-histo" class="<?php echo $css; ?>"<?php echo $attributes; ?>><img src="/kuest/img/history.png"> <?php echo $menu_history; ?></button></a>
			<a href="/kuest/editor"><button id="menu-bt-edit" class="big" data-ot="<?php echo $menu_createButtonTT; ?>" data-ot-tip-joint="top" data-ot-target="#menu-bt-edit"><img src="/kuest/img/feather.png"> <?php echo $menu_createButton; ?></button></a>
		</div>