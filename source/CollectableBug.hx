package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Bug extends FlxSprite {
	var _frames:Int; // Count number of frames
	var _seconds:Int; // Count seconds, 60 frames
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

	function countSeconds():Void {
		_frames++;
		if (_frames % FlxG.updateFramerate == 0) _seconds++;		
	}
}

class StagBeetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_02.png", true, 42, 39);
		animation.add("flying", [for (i in 0...7) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);			
	}

	override public function update(Elapsed:Float):Void {
		animation.play("flying");
		super.update(Elapsed);
	}
}

class Beetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_03.png", true, 47, 39);
		animation.add("walking", [for (i in 0...6) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);			
	}

	override public function update(Elapsed:Float):Void {
		animation.play("walking");
		super.update(Elapsed);
	}
}

class Caterpillar extends Bug {
	/**
	 * Creates a caterpillar looking bug
	 */
	public function new(X:Float = 0, Y:Float = 0, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_01.png", true, 36, 15);
		animation.add("walking", [for (i in 0...5) i], 12, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);			
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		countSeconds();
		animation.play("walking");
		bugPacing();
	}

	function bugPacing():Void {
		var DISTANCE:Int = 6 * 15; 
		// Randomise seconds 2 - 5
		if (_seconds < 3) {
			velocity.x = -DISTANCE;
			facing = FlxObject.LEFT;
		} else if (_seconds < 6) {
			velocity.x = DISTANCE;
			facing = FlxObject.RIGHT;
		} else if (_seconds == 6) {
			_seconds = 0;
		}
	}
}

