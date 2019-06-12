package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
// Typedefs
import Menu.MenuData;

class PauseMenu extends FlxSubState {
	var _boundingBox:FlxSprite;
	var _gameOverlay:FlxSprite;
	var _menuTitle:FlxText;
	var _menuWidth:Int = 500;
	var _menuHeight:Int = 500;
	var _titleText:String;
	var _menu:Menu;
	//
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _choices:Array<FlxText>;
	var _grpMenuItems:FlxSpriteGroup;

	public function new(PlayerDied:Bool = false):Void {
		super();
		var _boxXPos:Float = (FlxG.width / 2) - (_menuWidth / 2);
		_grpMenuItems = new FlxSpriteGroup();
		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		_grpMenuItems.add(_gameOverlay);

		_boundingBox = new FlxSprite(_boxXPos, (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		_grpMenuItems.add(_boundingBox);

		_titleText = PlayerDied ? "GAME OVER" : "GAME PAUSED";
		_menuTitle = new FlxText(20, 110, 0, _titleText, 30);
		_menuTitle.alignment = CENTER;
		_menuTitle.screenCenter(X);
		_grpMenuItems.add(_menuTitle);

		_pointer = new FlxSprite(_boxXPos, _menuTitle.y + 200);
		_pointer.makeGraphic(_menuWidth, 50, 0xffdc2de4);
		_grpMenuItems.add(_pointer);

		var _menuData:Array<MenuData> = [
			{
				title: "Restart",
				func: () -> FlxG.switchState(new LevelOne(0, 3, null, false))
			},
			{
				title: "Quit",
				func: () -> FlxG.switchState(new MainMenu())
			}
		];

		_menu = new Menu(20, 110, 200, _menuData);

		/**
		 * Text for paused screen.
		 */ _choices = new Array<FlxText>();

		// Add resume
		_choices.push(new FlxText(_menuTitle.x, _menuTitle.y + 200, 0, "Restart", 22));
		_choices.push(new FlxText(_menuTitle.x, _menuTitle.y + 250, 0, "Quit", 22));

		// Fix members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});

		add(_grpMenuItems);

		// Adds text to screen
		_choices.map((_choice:FlxText) -> {
			_choice.screenCenter(X);
			_choice.scrollFactor.set(0, 0);
			add(_choice);
		});
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			FlxG.sound.music.play();
			close();
		}

		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			FlxG.sound.music = null; // Kill the music
			switch _selected {
				case 0:
					// Restarts the game / level
					FlxG.switchState(new LevelOne(0, 3, null, false));
				case 1:
					// Should go back to main menu
					FlxG.switchState(new MainMenu());
			}
		}

		if (FlxG.keys.anyJustPressed([DOWN, S])) {
			if (_selected != _choices.length - 1) {
				_pointer.y = _pointer.y + 50;
				_selected++;
			}
		}

		if (FlxG.keys.anyJustPressed([UP, W])) {
			if (_selected != 0) {
				_pointer.y = _pointer.y - 50;
				_selected--;
			}
		}

		super.update(elapsed);
	}
}
