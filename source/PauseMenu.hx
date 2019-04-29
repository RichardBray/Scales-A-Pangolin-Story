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
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _choices:Array<FlxText>;
	var _titleText:String;
	var _playerDied:Bool;

	public var gamePaused:Bool = false;

	public function new(PlayerDied:Bool = false):Void {
		super();
		_playerDied = PlayerDied;
		_grpMenuItems = new FlxSpriteGroup();
		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		_grpMenuItems.add(_gameOverlay);

		_boundingBox = new FlxSprite((FlxG.width / 2) - (_menuWidth / 2), (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		_grpMenuItems.add(_boundingBox);

		_titleText = _playerDied ? "GAME OVER" : "GAME PAUSED";
		_menuTitle = new FlxText(20, 110, 0, _titleText, 30);
		_menuTitle.alignment = CENTER;
		_menuTitle.screenCenter(X);
		_grpMenuItems.add(_menuTitle);

		_pointer = new FlxSprite(_menuTitle.x, _menuTitle.y + 200);
		_pointer.makeGraphic(_menuWidth, 60, 0xffdc2de4);
		_grpMenuItems.add(_pointer);

		/**
		 * Text for paused screen.
		 *
		 * Restart
		 * Settings
		 * Quit
		 */
		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_menuTitle.x, _menuTitle.y + 200, 0, "Restart", 22));
		_choices.push(new FlxText(_menuTitle.x, _menuTitle.y + 250, 0, "Quit", 22));

		// Fix members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});

		add(_grpMenuItems);
		//
		_choices.map((_choice:FlxText) -> {
			_choice.screenCenter(X);
			_choice.scrollFactor.set(0, 0);
			add(_choice);
		});
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			close();
		}

		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			switch _selected {
				case 0:
					// Restarts the game / level
					FlxG.resetState();
				case 1:
					// Should go back to main menu
					js.Browser.console.log('Quit game');
				default:
					js.Browser.console.log('Quit game');
			}
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
