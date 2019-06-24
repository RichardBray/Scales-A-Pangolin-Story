package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// Typedefs
import Menu.MenuData;

class MainMenu extends GameState {
	var _gameTitle:FlxText;
	var _startText:FlxText;
	var _gameSave:FlxSave;
	var _continueColor:FlxColor;
	var _showChoices:Bool = false;
	var _menu:Menu;
	var _titleWidth:Int = 800; // Worked thous out through trail and error
	var _controls:Controls;
	var _timer:FlxTimer;
	var _bottomLeft:FlxText;
	var _bottomRight:FlxText;

	override public function create():Void {
		// Save data
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot

		FlxG.sound.music = null; // Make sure there's no music
		bgColor = 0xff000000; // Game background color

		_gameTitle = new FlxText((FlxG.width / 2) - (_titleWidth / 2), (FlxG.height / 2) - 200, _titleWidth, "Sacles: A Pangolin Story", 72);
		add(_gameTitle);

		_startText = new FlxText(0, _gameTitle.y + 200, 0, "Press SPACE to start", Constants.medFont);
		_startText.screenCenter(X);
		_startText.alpha = 1;
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
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		_bottomLeft = new Menu.BottomLeft();
		add(_bottomLeft);
		_bottomLeft.alpha = 0;

		_bottomRight = new Menu.BottomRight();
		add(_bottomRight);
		_bottomRight.alpha = 0;		
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
	
		if (!_showChoices) {
			_timer = new FlxTimer();
			_timer.start(2, flashingText, 2);		
		} else {
			_startText.alpha = 0;
			_bottomLeft.alpha = 1;
			_bottomRight.alpha = 1;
		}

		if (_controls.cross.check()) {
			if (!_showChoices) {
				_showChoices = true;
				_startText.alpha = 0;
				_menu.show();
			}
		}
	}

	function flashingText(T:FlxTimer):Void {
		if (!_showChoices) {
			var alphaValue = T.finished ? 1 : 0;
			FlxTween.tween(_startText, {alpha: alphaValue}, T.time / 4);
		}
	}

	function selectContinue():Void {
		if (_gameSave.data.levelName == null) { // No saved game
			showModal('You have no saved games');
		} else {
			var levelNames:Map<String, Class<LevelState>> = ["Level-1-0" => LevelOne, "Level-1-A" => LevelOneA];
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
		if (EraseSave) _gameSave.erase();
		FlxG.switchState(new LevelOne.Intro(_gameSave));
	}

	function showModal(
		Text:String, 
		?ConfirmCallback:Void->Void, 
		?ShowOptions:Bool
	):Void {
		var _modal:MainMenuModal = new MainMenuModal(Text, ConfirmCallback, ShowOptions);
		openSubState(_modal);
	}

	function loadLevel(GameSave:FlxSave, Level:Class<LevelState>) {
		FlxG.switchState(Type.createInstance(Level, [GameSave.data.playerScore, 3, GameSave.data.collectablesMap, null, GameSave]));
	}
}

class HLScreen extends GameState {
	var _logo:FlxSprite;
	var _timer:FlxTimer;
	var _controls:Controls;

	override public function create():Void {
		bgColor = FlxColor.WHITE;
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in
		_controls = new Controls();
		_logo = new FlxSprite(0, 0);
		_logo.loadGraphic("assets/images/hl_logo.png", false, 535, 239);
		_logo.x = (FlxG.width / 2) - (_logo.width / 2);
		_logo.y = (FlxG.height / 2) - (_logo.height / 2);
		add(_logo);
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		_timer = new FlxTimer();
		_timer.start(2, finishTimer, 1);

		if(_controls.cross.check() || _controls.start.check()) goToMainMenu();
	}

	function finishTimer(_) { 
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, goToMainMenu);
	}	

	function goToMainMenu() {
		FlxG.switchState(new MainMenu());
	}
}
