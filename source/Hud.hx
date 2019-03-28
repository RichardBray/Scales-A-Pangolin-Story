package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class Hud extends FlxSpriteGroup {
	var _health:FlxSprite;

	public function new(_playerHealth:Int) {
		super();

		// Create hearts
		for (i in 0...Std.int(_playerHealth)) {
			_health = new FlxSprite((i * 80), 30).loadGraphic("assets/images/heart.png", false, 60, 60);
			_health.scrollFactor.set(0, 0);
			add(_health);
		}
	}

	override public function update(elapsed:Float):Void {}
}
