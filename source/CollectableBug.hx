package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Bug extends FlxSprite {
	var _frames:Int; // Count number of frames
	var _seconds:Int; // Count seconds, 60 frames
	var _randomSeconds = Std.random(4) + 3; // Random seconds between 3-6 for bug movement time
	var _distance:Int;
	var _facingDirection:Bool;

	public var uniqueID:Int;
	public function new(X:Float = 0, Y:Float = 0, Name:String = "", Otype:String = "", UniqueID:Int = 0):Void {
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

	/**
	 * Sort of a hacky way to count seconds
	 */
	function countSeconds():Void {
		_frames++;
		if (_frames % FlxG.updateFramerate == 0) _seconds++;		
	}

	function setDirection(Name:String, Otype:String):Void {
		_distance = Std.parseInt(Otype) * 10; // 15 = tile width
		_facingDirection = Name == "left";			
	}
	/**
	 * This controls the bug pacing movement.
	 */
	function bugPacing():Void { 
		js.Lib.debug();
		if (_seconds < _randomSeconds) {
			bugMovement(_facingDirection);
		} else if (_seconds < (_randomSeconds * 2)) {
			bugMovement(!_facingDirection);
		} else if (_seconds == (_randomSeconds * 2)) {
			_seconds = 0;
		}
	}	

	function bugMovement(Direction:Bool):Void {
		velocity.x = Direction ? -_distance: _distance;
		facing = Direction ? FlxObject.LEFT : FlxObject.RIGHT;
	}
}

class StagBeetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_02.png", true, 42, 39);
		animation.add("flying", [for (i in 0...7) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	
		setDirection(Name, Otype);			
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		countSeconds();
		animation.play("flying");
		bugPacing();
	}
}

class Beetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_03.png", true, 47, 39);
		animation.add("walking", [for (i in 0...6) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	
		setDirection(Name, Otype);			
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		countSeconds();
		animation.play("walking");
		bugPacing();
	}
}

class Caterpillar extends Bug {
	/**
	 * Creates a caterpillar looking bug
	 */
	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String, UniqueID:Int = 0):Void {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_01.png", true, 36, 15);
		animation.add("walking", [for (i in 0...5) i], 12, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);	
		setDirection(Name, Otype);			
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		countSeconds();
		animation.play("walking");
		bugPacing();
	}
}

