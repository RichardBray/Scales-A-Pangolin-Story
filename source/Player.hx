package;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;

class Player extends FlxSprite {
	var _controls:Controls;
	var _offFloorCount:Float;

	final GRAVITY:Float = Constants.worldGravity;	

	// Sounds	
	var _sndRun:FlxSound;
	var _sndJumpDown:FlxSound;
	var _sndHurt:FlxSound;
	var _sndDigging:FlxSound;	
	var _sndJump:FlxSound;
	var _sndQuickJump:FlxSound;

	public var sndWee:FlxSound;	

	public var jumpPosition:Array<Float>; // Saves player jump position for poof
	public var preventMovement:Bool;
	public var isGoindDown:Bool; // Used in LevelState.hx to animate player through clouds
	public var isJumping:Bool; // Used for player feet collisions in LevelState.hx
	public var isAscending:Bool = false; // Indicates is player ascending or descending in jump
	public var facingTermiteHill:Bool = false; // When player is colliding with termite hill
	public var playerIsDigging:Bool = false; // When player is digging termite hill
	public var pangoAttached:Bool = false;
	public var resetPosition:Array<Float>;

	// Abilities
	public var enableQuickJump:Bool = false;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y); // Pass X and Y arguments back to FlxSprite
		acceleration.y = GRAVITY; // Constantly pushes the player down on Y axis
		preventMovement = false;
		isGoindDown = false; // If down button is pressed
		health = 3; // Health player starts off with
	
		loadGraphic("assets/images/characters/pangolin_sprites.png", true, 300, 127);
		setGraphicSize(121, 92);
		updateHitbox();

		offset.set(165, 35);
		scale.set(1, 1);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		// Animations
		animation.add("run", [for (i in 0...5) i], 12);		
		animation.add("idle", [for (i in 24...30) i], 8);
		animation.add("jumpLoop", [17, 18, 19], 12);
		animation.add("digging", [for (i in 36...40) i], 8);

		// Anims with purple pango - pp
		animation.add("run_pp", [for (i in 60...65) i], 12);
		animation.add("idle_pp", [for (i in 84...90) i], 8);		
		animation.add("jumpLoop_pp", [77, 78, 79], 12);
		animation.add("digging_pp", [for (i in 96...100) i], 8);

		// Sounds
		_sndJump = loadSound("jump");
		_sndJumpDown = loadSound("jump-down");
		_sndRun = loadSound("footsteps");
		_sndHurt = loadSound("hurt");
		_sndDigging = loadSound("digging");
		_sndQuickJump = loadSound("quick-jump");

		sndWee = loadSound("wee");

		// Intialise controls
		_controls = new Controls();
	}

	/**
	 * Animation to play when player gets hit.
	 * 
	 * @param Left	If player is facing left or not
	 */
	public function animJump(Left:Bool = false) {
		final xPos:Float = Left ?  this.x + 225 :  this.x - 225;
		FlxTween.tween(this, {x: xPos, y: (this.y - 60)}, 0.1);
	}

	public function playHurtSound() {
		_sndHurt.play();
	}

	public function playerGoingDownSound() {
		_sndJumpDown.play();
	}

	/**
	 * Resets player position to the latest position of the mid checkpoint object they collided with.
	 */
	public function resetPlayer() {
		setPosition(resetPosition[0], resetPosition[1]);
	}

	public function animationName(Name:String):String {
		var suffix:String = "";
		if (pangoAttached) suffix = "_pp";
		return '$Name$suffix';
	}	

	function loadSound(Name:String):FlxSound {
		return FlxG.sound.load('assets/sounds/player/$Name.ogg', .7);
	}

	/**
	 * Allows player to jump just off edge of an object to reduce frustration.
	 */
	function floorTouchWithinTime():Bool {
		// isAscending
		final hasQuickJump = enableQuickJump ? enableQuickJump : !isAscending;
		return isTouching(FlxObject.FLOOR) || (hasQuickJump && _offFloorCount < 0.2);
	}

	function playerMovement() {
		final SPEED:Int = 1800;
		var _left = _controls.left.check();
		var _right = _controls.right.check();
		var _jump = _controls.cross.check() || _controls.up.check();
		var _jumpGamepad = _controls.cross.check();
	
		acceleration.x = 0; // No movement when no buttons are pressed
		maxVelocity.set(SPEED / 4, GRAVITY); // Cap player speed
		drag.x = SPEED; // Deceleration applied when acceleration is not affecting the sprite.

		if (!preventMovement) {
			isJumping = false;
			if (_left || _right) {
				acceleration.x = _left ? -SPEED : SPEED;
				facing = _left ? FlxObject.LEFT : FlxObject.RIGHT; // facing = variable from FlxSprite
				if (isTouching(FlxObject.FLOOR)) {
					animation.play(animationName("run"));
					_sndRun.play(false, 0.4);
					offset.x = _left ? 12 : 165;
				}
			} else if (isTouching(FlxObject.FLOOR)) {
				animation.play(animationName("idle"));
				offset.x = facing == FlxObject.LEFT ? 12 : 165;
			}
			if (_left && _right) {
				acceleration.x = 0;
			}
			if ((FlxG.gamepads.lastActive != null ? _jumpGamepad : _jump) && floorTouchWithinTime()) {
				jumpPosition = [this.x, this.y];
				_sndJump.play();
				offset.x = 80;
				isJumping = true;
				velocity.y = -800;
				animation.play(animationName("jumpLoop"));
			}
			if (isGoindDown) {
				animation.play(animationName("jumpLoop"));
				isJumping = true;
				offset.x = 80;
			}

			// Quick jump sound effect
			if (_jump && !isTouching(FlxObject.FLOOR) && enableQuickJump && isAscending && _offFloorCount < 0.2) {
				_sndQuickJump.play();
			}
		}

		// Fix bug where pressing down plays jump loop evem on ground
		if (isTouching(FlxObject.FLOOR)) isGoindDown = false;
	}

	/**
	 * Checks if player is going up or down
	 */
	function detectPlayerAscending():Bool {
		return velocity.y == 0 
			? false 
			: (velocity.y < 0);
	}

	override public function update(Elapsed:Float) {
		playerMovement();
		isAscending = detectPlayerAscending();
		// Allows player to jump just off the edge
		(isTouching(FlxObject.FLOOR)) 
			? _offFloorCount = 0
			: _offFloorCount += Elapsed;

		if (facingTermiteHill && _controls.triangle.check()) {
			preventMovement = true;
			playerIsDigging = true;
			animation.play(animationName("digging"));
			_sndDigging.play();

			// Allow movement after one second
			haxe.Timer.delay(() -> {
				facingTermiteHill = false;
				preventMovement = false;
				_sndDigging.stop();
			}, 2000);
		}

		super.update(Elapsed);
	}	
}

class JumpPoof extends FlxSprite {
	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);
		loadGraphic("assets/images/characters/player_jump_dust.png", true, 135, 29);

		// Animations
		animation.add("disperse", [for (i in 0...7) i], 7, false);
	}

	/**
	 * Show the poof for one second in the position of the player.
	 *
	 * @param	X	Player X position
	 * @param Y Player Y position
	 */
	public function show(X:Float, Y:Float) {
		setPosition(X, Y - this.height);
		alpha = 1;
		animation.play("disperse");
	}

	public function hide() {
		alpha = 0;
		animation.stop();		
	}

	override function update(Elapsed:Float) {
		super.update(Elapsed);
	}
}
