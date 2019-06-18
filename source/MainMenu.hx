package;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// Typedefs
import Menu.MenuData;

class MainMenu extends FlxState {
	var _gameTitle:FlxText;
	var _startText:FlxText;
	var _gameSave:FlxSave;
	var _continueColor:FlxColor;
	var _showChoices:Bool = false;
	var _menu:Menu;
	var _titleWidth:Int = 450; // Worked thous out through trail and error
	var _controls:Controls;

	override public function create():Void {
		FlxG.autoPause = false;
		#if !debug
		FlxG.mouse.visible = false; // Hide the mouse cursor
		#end
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		// Save data
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot

		FlxG.sound.music = null; // Make sure there's no music
		bgColor = 0xff181818; // Game background color

		_gameTitle = new FlxText((FlxG.width / 2) - (_titleWidth / 2), (FlxG.height / 2) - 100, _titleWidth, "Project Pangolin", 48);
		add(_gameTitle);

		_startText = new FlxText(0, _gameTitle.y + 200, 0, "Press ENTER to start", 22);
		_startText.screenCenter(X);
		add(_startText);

		_continueColor = _gameSave.data.levelName == null ? 0x777777 : 0xffffff;

		var _menuData:Array<MenuData> = [
			{
				title: "Continue",
				func: selectContinue
			},
			{
				title: "New Game",
				func: selectNewGame
			}
		];

		_menu = new Menu(_gameTitle.x, _gameTitle.y + 200, _titleWidth, _menuData, true);
		_menu.hide();
		add(_menu);

		// Intialise controls
		_controls = new Controls();		
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		if (_controls.cross.check()) {
			if (!_showChoices) {
				_showChoices = true;
				_startText.alpha = 0;
				_menu.show();
			}
		}
	}

	function selectContinue():Void {
		if (_gameSave.data.levelName == null) { // No saved game
			showModal('You have no saved games');
		} else {
			var levelNames:Map<String, Class<GameLevel>> = ["Level-1-0" => LevelOne, "Level-1-A" => LevelOneA];
			loadLevel(_gameSave, levelNames[_gameSave.data.levelName]);
		}
	}

	function selectNewGame():Void {
		if (_gameSave.data.levelName == null) { // No saved game
			initNewGame();
		} else {
			showModal('This will erase your saved games. Do you want to continue?', () -> initNewGame(true), true);
		}
	}

	function initNewGame(?EraseSave:Bool = false):Void {
		if(EraseSave) _gameSave.erase();
		FlxG.switchState(new LevelOne(0, 3, null, false, _gameSave));
	}

	function showModal(
		Text:String, 
		?ConfirmCallback:Void->Void, 
		?ShowOptions:Bool
	):Void {
		var _modal:MainMenuModal = new MainMenuModal(Text, ConfirmCallback, ShowOptions);
		openSubState(_modal);
	}

	function loadLevel(GameSave:FlxSave, Level:Class<GameLevel>) {
		FlxG.switchState(Type.createInstance(Level, [GameSave.data.playerScore, 3, GameSave.data.collectablesMap, null, GameSave]));
	}
}
