package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends FlxSprite {
	public var isJumping:Bool;
	private static var GRAVITY:Float = 1500;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y); // Pass X and Y arguments back to FlxSprite
		acceleration.y = GRAVITY; // Constantly pushes the player down on Y axis
		health = 3; // Health player starts off with
		loadGraphic("assets/images/pangolin-sprite_v2.png", true, 290, 114); // height 113.5
		setGraphicSize(73, 49);
		updateHitbox();
		offset.set(145, 25);
		scale.set(0.5, 0.5);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("idle", [4], false);
		animation.add("run", [for (i in 0...11) i], 24, false);
		animation.add("jump", [for (i in 13...24) i], 12, false);
		animation.add("jumpLoop", [16, 17, 18], 12, true);
	}

	override public function update(elapsed:Float):Void {
		playerMovement();
		super.update(elapsed);
	}

	function playerMovement() {
		var SPEED:Int = 900;
		var _left = FlxG.keys.anyPressed([LEFT, A]);
		var _right = FlxG.keys.anyPressed([RIGHT, D]);
		var _jump = FlxG.keys.anyJustPressed([SPACE, UP, W]);

		acceleration.x = 0; // No movement when no buttons are pressed
		maxVelocity.set(SPEED / 4, GRAVITY); // Cap player speed
		drag.x = maxVelocity.x * 4; // Deceleration applied when acceleration is not affecting the sprite.

		if (_left || _right) {
			acceleration.x = _left ? -SPEED : SPEED;
			offset.x = _left ? 73 : 145;
			facing = _left ? FlxObject.LEFT : FlxObject.RIGHT; // facing = variable from FlxSprite
			if (isTouching(FlxObject.FLOOR)) {
				animation.play("run");
			}
		} else if(isTouching(FlxObject.FLOOR)) {
			animation.play("idle");	
		}
		if (_left && _right) {
			acceleration.x = 0;
		}
		if (_jump && isTouching(FlxObject.FLOOR)) {
			velocity.y = -600;
			animation.play("jump");
			animation.play("jumpLoop");
			isJumping = true;
		}	
	}
}
