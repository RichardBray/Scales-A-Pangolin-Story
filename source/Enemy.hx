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

	/**
	 * Method to change the site of a sprite's hitbox size.
	 *
	 * @param Width Amount to want to reduce or increase the hitbox WIDTH by
	 * @param Height Amount to want to reduce or increase the hitbox HEIGHT by
	 * @param Sprite Sprite instance
	 */
	public function updateSpriteHitbox(Width:Int, Height:Int, Sprite:FlxSprite) {
		var newHitboxWidth:Int = Std.int(Sprite.width - Width);
		var newHitboxHeight:Int = Std.int(Sprite.height - Height);

		Sprite.setGraphicSize(newHitboxWidth, newHitboxHeight);
		Sprite.updateHitbox();
		Sprite.offset.set(Width / 2, Height);
		Sprite.scale.set(1, 1);
	}	
}

class Fire extends Enemy {
	var _timer:FlxTimer;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y + 50); // to make up for offset
		_timer = new FlxTimer();
		loadGraphic("assets/images/L1_FIRE_01.png", true, 178, 206);
		updateSpriteHitbox(70, 50, this);

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
	var _timer:FlxTimer;
	var _enemyHit:Bool = false;

	public function new(X:Float, Y:Float, Name:String = "", Otype:String = "") {
		super(X, Y + 40);
		_timer = new FlxTimer();
		loadGraphic("assets/images/boar_sprites.png", true, 156, 88);
		updateSpriteHitbox(40, 40, this);
	
		_distance = Std.parseInt(Otype) * 10; // 15 = tile width
		_facingDirection = Name == "left";	

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);			

		animation.add("walking", [for (i in 0...6) i], 8, true);
		animation.add("dying", [for (i in 7...12) i], 8, false);			
	}

	function boarPacing() { 
		if (!_enemyHit) {
			if (_seconds < 5) {
				boarMovement(_facingDirection);
			} else if (_seconds < (5 * 2)) {
				boarMovement(!_facingDirection);
			} else if (Math.round(_seconds) == (5 * 2)) {
				_seconds = 0;
			}
		} else {
			velocity.x = 0;
		}		
	}	

	function boarMovement(Direction:Bool) {
		velocity.x = Direction ? -_distance: _distance;
		facing = Direction ? FlxObject.LEFT : FlxObject.RIGHT;
	}	

	override public function kill() {
		_enemyHit = true;
		alive = false;
		_timer.start(1, (_) -> {
			exists = false;
		}, 1);
  }

	override public function update(Elapsed:Float) {
		_seconds += Elapsed;	
		_enemyHit ? animation.play("dying") : animation.play("walking");
		boarPacing();
		super.update(Elapsed);
	}		
}

class Snake extends Enemy {
	var _facingDirection:Bool;
	var _enemyHit:Bool = false;
	var _timer:FlxTimer;

	public function new(X:Float, Y:Float, Name:String = "", Otype:String = "") {
		super(X, Y);
		_timer = new FlxTimer();
		loadGraphic("assets/images/snake_sprites.png", true, 238, 120);
		_facingDirection = Name == "left";	

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);	

		animation.add("idle", [for (i in 0...4) i], 6, true);
		animation.add("attacking", [for (i in 5...9) i], 8, false);		
		animation.add("dying", [for (i in 10...14) i], 8, false);				
	}

	override public function kill() {
		_enemyHit = true;
		alive = false;
		_timer.start(1, (_) -> {
			exists = false;
		}, 1);
  }

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_enemyHit ? animation.play("dying") : animation.play("idle");
	}		
}
