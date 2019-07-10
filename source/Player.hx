package;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;

class Player extends FlxSprite {
	var _sndJump:FlxSound;
	var _controls:Controls;

	public var preventMovement:Bool;
	public var isGoindDown:Bool;
	private static var GRAVITY:Float = 1500;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y); // Pass X and Y arguments back to FlxSprite
		acceleration.y = GRAVITY; // Constantly pushes the player down on Y axis
		preventMovement = false;
		isGoindDown = false; // If down button is pressed
		health = 3; // Health player starts off with
	
		loadGraphic("assets/images/pangolin_sprites.png", true, 300, 135); // height 113.5
		setGraphicSize(121, 100);
		updateHitbox();

		offset.set(165, 33);
		scale.set(1, 1);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		// Animations
		animation.add("idle", [for (i in 23...28) i], 8, true);
		animation.add("run", [for (i in 0...5) i], 12, false);
		animation.add("jump", [for (i in 11...23) i], 12, false);
		animation.add("jumpLoop", [16, 17, 18], 12, true);

		// Sounds
		_sndJump = FlxG.sound.load("assets/sounds/jump.wav");

		// Intialise controls
		_controls = new Controls();
	}

	override public function update(Elapsed:Float):Void {
		playerMovement();
		super.update(Elapsed);
	}

	/**
	 * @param Left	If player is facing left or not
	 */
	public function animJump(Left:Bool = false) {
		var xPos:Float = Left ?  this.x + 225 :  this.x - 225;
		FlxTween.tween(this, {x: xPos, y: (this.y - 60)}, 0.1);
	}

	function playerMovement() {
		var SPEED:Int = 1500;
		var _left = _controls.left.check();
		var _right = _controls.right.check();
		var _jump = _controls.cross.check() || _controls.up.check();

		acceleration.x = 0; // No movement when no buttons are pressed
		maxVelocity.set(SPEED / 4, GRAVITY); // Cap player speed
		drag.x = SPEED; // Deceleration applied when acceleration is not affecting the sprite.

		if (!preventMovement) {
			if (_left || _right) {
				acceleration.x = _left ? -SPEED : SPEED;
				facing = _left ? FlxObject.LEFT : FlxObject.RIGHT; // facing = variable from FlxSprite
				if (isTouching(FlxObject.FLOOR)) {
					animation.play("run");
					offset.x = _left ? 12 : 165;
				}
			} else if (isTouching(FlxObject.FLOOR)) {
				animation.play("idle");
				offset.x = facing == FlxObject.LEFT ? 12 : 165;
			}
			if (_left && _right) {
				acceleration.x = 0;
			}
			if (_jump && isTouching(FlxObject.FLOOR)) {
				_sndJump.play();
				offset.x = 80;
				velocity.y = -800; // 1100
				animation.play("jump");
				animation.play("jumpLoop");
			}
			if (isGoindDown) {
				animation.play("jumpLoop");
			}
		}
	}
}
