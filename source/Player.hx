package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends FlxSprite {
	private static var GRAVITY:Float = 1500;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y); // Pass X and Y arguments back to FlxSprite
		acceleration.y = GRAVITY; // Constantly pushes the player down on Y axis
		health = 3; // Health player starts off with
		loadGraphic("assets/images/pangolin-run.png", true, 290, 98);
		scale.set(0.4, 0.4); // scales character smaller
		// offset.set(.1, .1);
		updateHitbox();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("run", [for (i in 0...12) i], 12, false);
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
			facing = _left ? FlxObject.LEFT : FlxObject.RIGHT; // facing = variable from FlxSprite
			animation.play("run");
		}
		if (_left && _right)
			acceleration.x = 0;
		if (_jump && isTouching(FlxObject.FLOOR))
			velocity.y = -600;
	}
}
