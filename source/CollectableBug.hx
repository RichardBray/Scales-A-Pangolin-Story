package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class CollectableBug extends FlxSprite {
	public function new(X:Float = 0, Y:Float = 0, width:Int, height:Int):Void {
		super(X, Y);
		loadGraphic("assets/images/purp-bug.png", false, width, height);
	}

	override public function kill():Void {
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y - 16}, .33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_):Void {
		exists = false;
	}
}
