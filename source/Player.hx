package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends FlxSprite {
	public static var GRAVITY:Float = 1500;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y); // Pass X and Y arguments back to FlxSprite
		acceleration.y = GRAVITY;
		loadGraphic("assets/images/debug.png", false, 40, 20);
	}

	override public function update(elapsed:Float):Void {
		_playerMovement();
		super.update(elapsed);
	}

	private function _playerMovement() {
		var SPEED:Int = 900;
		var left = FlxG.keys.anyPressed([LEFT, A]);
		var right = FlxG.keys.anyPressed([RIGHT, D]);
		var jump = FlxG.keys.anyJustPressed([SPACE, UP, W]);

		acceleration.x = 0; // No movement when no buttons are pressed
		maxVelocity.set(SPEED/4, GRAVITY); // Cap player speed
		drag.x = maxVelocity.x * 4; // Deceleration applied when acceleration is not affecting the sprite.

		if (left || right)
			acceleration.x = left ? -SPEED : SPEED;
		if (left && right)
			acceleration.x = 0;
		if (jump && isTouching(FlxObject.FLOOR))
			velocity.y = -600;
	}
}
