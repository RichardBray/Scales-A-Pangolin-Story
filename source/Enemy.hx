package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Enemy extends FlxSprite {
	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);
		makeGraphic(50, 50, 0xffff0000); // temporary
	}

	override public function kill():Void {
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y + 50}, .5, {ease: FlxEase.quadOut, onComplete: finishKill});
	}

	function finishKill(_):Void {
		exists = false;
	}
}
