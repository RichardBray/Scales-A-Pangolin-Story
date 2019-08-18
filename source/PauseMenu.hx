package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import flixel.addons.display.shapes.FlxShapeBox;

// Typedefs
import Menu.MenuData;

class PauseMenu extends FlxSubState {
	var _boundingBox:FlxShapeBox;
	var _gameOverlay:FlxSprite;
	var _menuTitle:FlxText;
	var _menuWidth:Int = 750;
	var _menuHeight:Int = 650;
	var _titleText:String;
	var _menu:Menu;
	var _grpMenuItems:FlxSpriteGroup;
	var _controls:Controls;


	public function new(PlayerDied:Bool = false, LevelString:String) {
		super();
		var _boxXPos:Float = (FlxG.width / 2) - (_menuWidth / 2);
		_grpMenuItems = new FlxSpriteGroup();

		// Opaque black background overlay
		_gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
		_grpMenuItems.add(_gameOverlay);

		// Menu bounding box
		_boundingBox = new FlxShapeBox(
			_boxXPos,
			(FlxG.height / 2) - (_menuHeight / 2),
			_menuWidth,
			_menuHeight,
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor			
		);
		_grpMenuItems.add(_boundingBox);

		_titleText = PlayerDied ? "GAME OVER" : "GAME PAUSED";
		_menuTitle = new FlxText(20, 250, 0, _titleText);
		_menuTitle.setFormat(Constants.squareFont, Constants.lrgFont);
		_menuTitle.alignment = CENTER;
		_menuTitle.screenCenter(X);
		_grpMenuItems.add(_menuTitle);

		// Maps string to class from `levelNames` in constants
		var levelToRestart:Class<LevelState> = Constants.levelNames[LevelString];

		var _menuData:Array<MenuData> = [
			{
				title: "Resume",
				func: togglePauseMenu
			},			
			{
				title: "Restart",
				func: () -> {
					FlxG.sound.music = null;
					FlxG.switchState(Type.createInstance(levelToRestart, [null, false]));
				}
			},
			{
				title: "Instructions",
				func: () -> {
					var _instructions:Instructions = new Instructions(1, 2, false); // Should be 1, 4
					openSubState(_instructions);
				}
			},
			{
				title: "Quit",
				func: () -> FlxG.switchState(new MainMenu())
			}
		];

		if (PlayerDied) _menuData.shift(); // Remove `RESUME` options if player died

		_menu = new Menu(_boxXPos, _menuTitle.y + 150, _menuWidth, _menuData, true);

		// Fix members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});

		_menu.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});		

		add(_grpMenuItems);
		add(_menu);

		// Intialise controls
		_controls = new Controls();
		
	}

	override public function update(Elapsed:Float) {
		// Exit pause menu
		if (_controls.start.check()) {
			togglePauseMenu();
		}

		super.update(Elapsed);
	}

	function togglePauseMenu() {
		FlxG.sound.music.play();
		close();
	}
}
