package;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import flixel.addons.display.shapes.FlxShapeBox;
import substates.QuitMenu;
import flixel.system.FlxSound;

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
	var _gameSave:FlxSave;
	
	// Sounds
	var _sndClose:FlxSound;

	/**
	 * @param PlayerDied	If player died or not
	 * @param LevelString	Name of the level
	 */
	public function new(PlayerDied:Bool = false, ?LevelString:String, ?GameSave:Null<FlxSave>) {
		super();
		var _boxXPos:Float = (FlxG.width / 2) - (_menuWidth / 2);
		_grpMenuItems = new FlxSpriteGroup();
		_gameSave = GameSave;

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

		var restartMenuOption:Array<MenuData>;
		var levelSelectMenuOption:Array<MenuData>;
		// null means it's the level select screen
		if (LevelString != null) {
			// Maps string to class from `levelNames` in constants
			var sectionToRestart:Class<states.LevelState> = Constants.levelNames[LevelString];

			restartMenuOption = [{
				title: "Restart Section",
				func: () -> {
					FlxG.sound.music = null;
					FlxG.switchState(Type.createInstance(sectionToRestart, [GameSave, false]));
				},
				itemPos: 2
			}];
			// TODO Finish this
			levelSelectMenuOption = [{
				title: "Level Select",
				func: () -> {
					FlxG.switchState(new levels.LevelSelect(_gameSave));
				},
				itemPos: 3				
			}];
		}

		var _standardMenuItems:Array<MenuData> = [
			{
				title: "Resume",
				func: togglePauseMenu,
				soundOnSelect: false,
				itemPos: 1,
			},						
			{
				title: "Instructions",
				func: () -> {
					var _instructions:Instructions = new Instructions(1, 2, false); // Should be 1, 4
					openSubState(_instructions);
				},
				itemPos: 4
			},
			{
				title: "Quit",
				func: () -> {
					var quitMenu:QuitMenu = new QuitMenu();
					openSubState(quitMenu);
				},
				itemPos: 5
			}
		];

		// 
		var _menuData:Array<MenuData> = (LevelString != null)
			? _standardMenuItems.concat(restartMenuOption)
			: _standardMenuItems;

		if (_gameSave.data.enableLevelSelect && LevelString != null) _menuData = _menuData.concat(levelSelectMenuOption);

		if (PlayerDied) _menuData.shift(); // Remove `RESUME` options if player died

		// Reorder menu items mainly post concatination
		_menuData.sort((a:MenuData, b:MenuData) -> {
			return a.itemPos - b.itemPos;
		});

		_menu = new Menu(_boxXPos, _menuTitle.y + 120, _menuWidth, _menuData, true);

		// Fix members to the screen
		_grpMenuItems.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});

		_menu.forEach((_member:FlxSprite) -> {
			_member.scrollFactor.set(0, 0);
		});		

		add(_grpMenuItems);
		add(_menu);

		// Sound
		_sndClose = FlxG.sound.load(Constants.sndMenuClose);
	
		// Intialise controls
		_controls = new Controls();

		if (FlxG.sound.music != null) FlxG.sound.music.pause();
	}

	function togglePauseMenu() {
		if (FlxG.sound.music != null) FlxG.sound.music.play();
		_sndClose.play(); 
		close();
	}

	override public function update(Elapsed:Float) {
		// Exit pause menu
		if (_controls.start.check()) togglePauseMenu();
		super.update(Elapsed);
	}	
}
