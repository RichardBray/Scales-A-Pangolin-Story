package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.FlxObject;

class Enemy extends FlxSprite {
	public var sndHit:FlxSound;
	public var sndEnemyKill:FlxSound;

	public function new(X:Float = 0, Y:Float = 0, Name:String = "", Otype:String = "") {
		super(X, Y);
		sndHit = FlxG.sound.load("assets/sounds/hurt.wav");
		sndEnemyKill = FlxG.sound.load("assets/sounds/drop.wav");		
	}

	// override public function kill() {
		// exists = false;
		// FlxTween.tween(this, {alpha: 0, y: y + 50}, .5, {ease: FlxEase.quadOut, onComplete: finishKill});
  //}

	// function finishKill(_) {
	// 	exists = false;
	// }
	
}

class Fire extends Enemy {
	var _timer:FlxTimer;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y + 40); // to make up for offset
		_timer = new FlxTimer();
		loadGraphic("assets/images/L1_FIRE_01.png", true, 178, 206);
		setGraphicSize(138, 166);
		updateHitbox();
		offset.set(20, 40);
		scale.set(1, 1);

		animation.add("burning", [for (i in 0...7) i], 12, true);		
	}

	override public function update(Elapsed:Float) {
		animation.play("burning");
		super.update(Elapsed);
	}	

	override public function kill() {
		alive = false;
		_timer.start(.5, (_) -> alive = true, 1);
	}	
}

class Boar extends Enemy {
	var _facingDirection:Bool;
	var _distance:Int;
	var _seconds:Float = 0;

	public function new(X:Float, Y:Float, Name:String = "", Otype:String = "") {
		super(X, Y);
		loadGraphic("assets/images/boar_sprites.png", true, 156, 87);
		_distance = Std.parseInt(Otype) * 10; // 15 = tile width
		_facingDirection = Name == "left";	

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);			

		animation.add("walking", [for (i in 0...6) i], 8, true);
		animation.add("dying", [for (i in 7...12) i], 8, true);			
	}

	function boarPacing() { 
		if (_seconds < 5) {
			boarMovement(_facingDirection);
		} else if (_seconds < (5 * 2)) {
			boarMovement(!_facingDirection);
		} else if (Math.round(_seconds) == (5 * 2)) {
			_seconds = 0;
		}
	}	

	function boarMovement(Direction:Bool) {
		velocity.x = Direction ? -_distance: _distance;
		facing = Direction ? FlxObject.LEFT : FlxObject.RIGHT;
	}	

	override public function update(Elapsed:Float) {
		_seconds += Elapsed;	
		animation.play("walking");
		boarPacing();
		super.update(Elapsed);
	}		
}
