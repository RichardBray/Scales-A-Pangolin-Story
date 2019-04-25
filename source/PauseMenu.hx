package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;

class PauseMenu extends FlxSubState {
	var _boundingBox:FlxSprite;
	var _gameOverlay:FlxSprite;
	var _grpMenuItems:FlxSpriteGroup;
	var _menuTitle:FlxText;
	var _menuWidth:Int = 500;
	var _menuHeight:Int = 600;

	public var gamePaused:Bool = false;

	public function new():Void {
		super();
		_grpMenuItems = new FlxSpriteGroup();
		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		_grpMenuItems.add(_gameOverlay);

		_boundingBox = new FlxSprite((FlxG.width / 2) - (_menuWidth / 2), (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		_grpMenuItems.add(_boundingBox);

		_menuTitle = new FlxText(20, 100, 0, "Game Paused", 22);
		_menuTitle.alignment = CENTER;
		_menuTitle.screenCenter(X);
		_grpMenuItems.add(_menuTitle);

		/**
		 * GAME PAUSED
		 * Restart Level
		 * Load latest checkpoint
		 * Settings
		 * Quit
		 */

		// Hide and fix the members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			// _member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});

		add(_grpMenuItems);
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustReleased([ESCAPE])) {
			close();
		}
		super.update(elapsed);
	}

	public function toggle(Alpha:Int):Void {
		gamePaused = !gamePaused;

		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.alpha = Alpha;
		});
	}
}
