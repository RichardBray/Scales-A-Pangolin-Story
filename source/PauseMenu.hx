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

		_menu = new Menu(_boxXPos, _menuTitle.y + 200, _menuWidth, _menuData, true);

		// Fix members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});

		_menu.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});		

		add(_grpMenuItems);
		add(_menu);

	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			FlxG.sound.music.play();
			close();
		}

		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			FlxG.sound.music = null; // Kill the music
		}

		super.update(elapsed);
	}
}
