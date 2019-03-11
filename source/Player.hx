package;

import flixel.FlxSprite;
import flixel.FlxG;

class Player extends FlxSprite {
	public static inline var GRAVITY:Float = 600;

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
		var SPEED:Float = 300;
		var left = FlxG.keys.anyPressed([LEFT, A]);
		var right = FlxG.keys.anyPressed([RIGHT, D]);

		acceleration.x = 0; // No movement when no buttons are pressed
		maxVelocity.x = SPEED; // Cap player speed
		drag.x = maxVelocity.x * 4; // Deceleration applied when acceleration is not affecting the sprite.    

		if (left || right) {
			acceleration.x = left ? -SPEED : SPEED;
		}

		if (left && right) {
			acceleration.x = 0;
		}
	}
}
