package com.twinoid.kube.quest.editor.components.tooltip.content {
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, bitmap.width + margin*2, bitmap.height + margin*2);
			graphics.beginBitmapFill(bitmap, m);
			graphics.drawRect(margin, margin, bitmap.width, bitmap.height);