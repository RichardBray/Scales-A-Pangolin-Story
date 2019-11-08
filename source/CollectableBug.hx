package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Bug extends FlxSprite {
	var _seconds:Float = 0;
	var _randomSeconds = Std.random(3) + 3; // Random seconds between 3-5 for bug movement time
	var _distance:Int;
	var _facingDirection:Bool;

	// Sounds
	var _sndCollect:FlxSound;

	/**
	 * Basic bug sprite. 
	 */
	public function new(X:Float = 0, Y:Float = 0, Name:String = "", Otype:String = "") {
		super(X, Y);	
		_sndCollect = FlxG.sound.load("assets/sounds/collect.wav", 0.55);
	}

	override public function kill() {
		alive = false;
		_sndCollect.play(true);
		FlxTween.tween(this, {alpha: 0, y: y - 16}, .33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_) {
		exists = false;
	}	

	/**
	 * Sort of a hacky way to count seconds
	 */
	function countSeconds(Elapsed:Float) {
		_seconds += Elapsed;	
	}

	function setDirection(Name:String, Otype:String) {
		_distance = Std.parseInt(Otype) * 10; // 15 = tile width
		_facingDirection = Name == "left";			
	}
	/**
	 * This controls the bug pacing movement.
	 */
	function bugPacing() { 
		if (_seconds < _randomSeconds) {
			bugMovement(_facingDirection);
		} else if (_seconds < (_randomSeconds * 2)) {
			bugMovement(!_facingDirection);
		} else if (Math.round(_seconds) == (_randomSeconds * 2)) {
			_seconds = 0;
		}
	}	

	function bugMovement(Direction:Bool) {
		velocity.x = Direction ? -_distance: _distance;
		facing = Direction ? FlxObject.LEFT : FlxObject.RIGHT;
	}

	/**
	 * Animation for flying bug only.
	 *
	 * @param Direction Wether the sprite is facing left or right.
	 */
	function bugFlying(Direction:Bool) {
		var direction:Float = Direction ? -30 : 30;
		facing = Direction ? FlxObject.LEFT : FlxObject.RIGHT;

		if (_seconds < 1) {
			velocity.y = direction;
		} else if (_seconds < 2) {
			velocity.y = -direction;
		} else if (Math.round(_seconds) == 2) {
			_seconds = 0;
		}
	}
}

class StagBeetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String) {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_02.png", true, 42, 39);
		animation.add("flying", [for (i in 0...7) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	
		setDirection(Name, Otype);			
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		countSeconds(Elapsed);
		animation.play("flying");
		bugFlying(_facingDirection);
	}
}

class Beetle extends Bug {

	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String) {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_03.png", true, 47, 39);
		animation.add("walking", [for (i in 0...6) i], 12, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	
		setDirection(Name, Otype);		
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		countSeconds(Elapsed);
		animation.play("walking");
		bugPacing();
	}
}

class Caterpillar extends Bug {
	/**
	 * Creates a caterpillar looking bug
	 */
	public function new(X:Float = 0, Y:Float = 0, Name:String, Otype:String) {
		super(X, Y);
		loadGraphic("assets/images/L1_Bug_01.png", true, 36, 15);
		animation.add("walking", [for (i in 0...5) i], 12, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);	
		setDirection(Name, Otype);			
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		countSeconds(Elapsed);
		animation.play("walking");
		bugPacing();
	}
}

