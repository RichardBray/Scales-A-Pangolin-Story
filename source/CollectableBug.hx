package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Bug extends FlxSprite {
	public var uniqueID:Int;
	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);	
		uniqueID = UniqueID;
	}

	override public function kill():Void {
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y - 16}, .33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_):Void {
		exists = false;
	}	
}


class StagBeetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_02.png", true, 42, 39);
		animation.add("flying", [for (i in 0...7) i], 12, true);
	}

	override public function update(Elapsed:Float):Void {
		animation.play("flying");
		super.update(Elapsed);
	}
}

class Caterpillar extends Bug {

	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_01.png", true, 36, 15);
		animation.add("walking", [for (i in 0...5) i], 12, true);
	}

	override public function update(Elapsed:Float):Void {
		animation.play("walking");
		super.update(Elapsed);
	}
}

