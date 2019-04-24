package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class PauseMenu extends FlxSpriteGroup {
	var _boundingBox:FlxSprite;
	var _gameOverlay:FlxSprite;

	public var gamePaused:Bool = false;

	public function new():Void {
		super();
		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		add(_gameOverlay);

		_boundingBox = new FlxSprite(FlxG.width / 2, FlxG.height / 2).makeGraphic(200, 200, 0xff205ab7);
		add(_boundingBox);

		/**
		 * GAME PAUSED
		 * Restart Level
		 * Load latest checkpoint
		 * Settings
		 * Quit
		 */

		// Hide and fix the members to the screen
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});
	}

	public function toggle(Alpha:Int):Void {
		gamePaused = !gamePaused;

		this.forEach((_member:FlxSprite) -> {
			_member.alpha = Alpha;
		});
	}
}
