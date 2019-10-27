package;

import flixel.util.FlxSave;
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
	var _quitMenu:Menu;
	var _grpMenuItems:FlxSpriteGroup;
	var _controls:Controls;

	var _grpQuitItems:FlxSpriteGroup;
	var _allowQuitting:Bool = true;
	

	/**
	 * @param PlayerDied	If player died or not
	 * @param LevelString	Name of the level
	 */
	public function new(PlayerDied:Bool = false, LevelString:String, ?GameSave:Null<FlxSave>) {
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
			_menuHeight - 50,
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
		var sectionToRestart:Class<states.LevelState> = Constants.levelNames[LevelString];

		var _menuData:Array<MenuData> = [
			{
				title: "Resume",
				func: togglePauseMenu
			},			
			{
				title: "Restart Section",
				func: () -> {
					FlxG.sound.music = null;
					FlxG.switchState(Type.createInstance(sectionToRestart, [GameSave, false]));
				}
			},			
			{
				title: "Instructions",
				func: () -> {
					var _instructions:Instructions = new Instructions(1, 2, false); // Should be 1, 4
					if (_allowQuitting) openSubState(_instructions);
				}
			},
			{
				title: "Quit",
				func: toggleLevelQuit
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

		// Quit screen

		_grpQuitItems = new FlxSpriteGroup();
		add(_grpQuitItems);

		var quitMenuData:Array<MenuData> = [
			{
				title: "Yes",
				func: () -> {
						if (!_allowQuitting) FlxG.switchState(new MainMenu()) ;
					}
			},
			{
				title: "No",
				func: toggleLevelQuit
			},			
		];

		_quitMenu = new Menu(_boxXPos, _menuTitle.y + 150, _menuWidth, quitMenuData, true);
		_grpQuitItems.add(_quitMenu);

		var quitText:FlxText = new FlxText(_boxXPos, _menuTitle.y + 150, 0, "Are you sure you want to quit?");

		_grpQuitItems.add(quitText);

		_grpQuitItems.forEach((_member:FlxSprite) -> {
		 	_member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});			
	
		// Intialise controls
		_controls = new Controls();
	}

	function toggleLevelQuit() {
		trace(_allowQuitting);
		if (_allowQuitting) {
			_grpQuitItems.forEach((_member:FlxSprite) -> {
				_member.alpha = 1;
			});	

			_menu.forEach((_member:FlxSprite) -> {
				_member.alpha = 0;
			});		
			_allowQuitting = false;
		} else {
			trace("you can't quit stuff");
		}
	
	}

	function togglePauseMenu() {
		FlxG.sound.music.play();
		close();
	}

	override public function update(Elapsed:Float) {
		// Exit pause menu
		if (_controls.start.check()) {
			togglePauseMenu();
		}

		super.update(Elapsed);
	}	
}
