package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

// Internal
import states.GameState;
import states.LevelState;

// Typedefs
import Menu.MenuData;

using Lambda;


class MainMenu extends GameState {
	var _bgImg:FlxSprite;
	var _gameTitle:FlxSprite;
	var _gameSubTitle:FlxText;
	var _startText:FlxText;
	var _gameSave:FlxSave;
	var _showChoices:Bool = false;
	var _menu:Menu;
	var _titleWidth:Int = 848;
	var _controls:Controls;
	var _timer:FlxTimer;
	var _bottomLeft:FlxText;
	var _bottomRight:FlxText;
	var _grpCollectables:FlxTypedGroup<CollectableBug.Bug>;

	var _showDemoModal:Bool;

	public function new() {
		super();
	}

	override public function create() {
		// Save data
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot

		FlxG.sound.music = null; // Make sure there's no music
		bgColor = 0xff000000; // Game background color

		_bgImg = new FlxSprite(0, 0);
		_bgImg.loadGraphic("assets/images/main_menu/scales_bg.jpg", false, 1920, 1080);
		add(_bgImg);

		_gameTitle = new FlxSprite((FlxG.width / 2) - (_titleWidth / 2), (FlxG.height / 2) - 350);
		_gameTitle.loadGraphic("assets/images/main_menu/scales_logo.png", false, 848, 347);
		add(_gameTitle);

		_gameSubTitle = new FlxText(0, _gameTitle.y + 365, 0, "A Pangolin Story");
		_gameSubTitle.setFormat(Constants.squareFont, 75, Constants.slimeGreenColor);
		_gameSubTitle.screenCenter(X);
		add(_gameSubTitle);

		_startText = new FlxText(0, _gameTitle.y + 500, 0, "Press SPACE to start");
		_startText.setFormat(Constants.squareFont, Constants.medFont);
		_startText.screenCenter(X);
		_startText.alpha = 1;
		add(_startText);

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

		_menu = new Menu(_gameTitle.x, _gameTitle.y + 500, _titleWidth, _menuData, true);
		_menu.hide();
		add(_menu);

		// Render flying stag beetles
		_grpCollectables = new FlxTypedGroup<CollectableBug.Bug>();
		add(_grpCollectables);
		var bugPositions:Array<Array<Int>> = [
			[384, 493],
			[1444, 132],
		];

		bugPositions.mapi((Idx:Int, BugPos:Array<Int>) -> {
			var bugDirection:String = Idx == 1 ? "left" : "right";
			var bug:CollectableBug.Bug = new CollectableBug.StagBeetle(BugPos[0], BugPos[1], bugDirection, "1");
			_grpCollectables.add(bug);
		});


		// Intialise controls
		_controls = new Controls();		
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		_bottomLeft = new Menu.BottomLeft();
		add(_bottomLeft);
		_bottomLeft.alpha = 0;

		_bottomRight = new Menu.BottomRight();
		add(_bottomRight);
		_bottomRight.alpha = 0;		

		super.create();
	}

	override public function update(Elapsed:Float) {
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

	function flashingText(T:FlxTimer) {
		if (!_showChoices) {
			var alphaValue = T.finished ? 1 : 0;
			FlxTween.tween(_startText, {alpha: alphaValue}, T.time / 4);
		}
	}

	function selectContinue() {
		if (_gameSave.data.levelName == null) { // No saved game
			// showModal('You have no saved games');
			showModal("Save states have are not in this build yet");
		} else {
			loadLevel(_gameSave, Constants.levelNames[_gameSave.data.levelName]);
		}
	}

	function selectNewGame() {
		if (_gameSave.data.levelName == null) { // No saved game
			initNewGame();
		} else {
			showModal('This will erase your saved games. Do you want to continue?', () -> initNewGame(true), true);
		}
	}

	function initNewGame(?EraseSave:Bool = false) {
		if (EraseSave) _gameSave.erase();
		FlxG.switchState(new levels.LevelOne.Intro(_gameSave));
	}

	function showModal(
		Text:String, 
		?ConfirmCallback:Void->Void,
		?ShowOptions:Bool
	) {
		var _modal:MainMenuModal = new MainMenuModal(Text, ConfirmCallback, ShowOptions);
		openSubState(_modal);
	}

	function loadLevel(GameSave:FlxSave, Level:Class<LevelState>) {
		FlxG.switchState(Type.createInstance(Level, [GameSave, false]));
	}
}

class HLScreen extends GameState {
	var _logo:FlxSprite;
	var _timer:FlxTimer;
	var _controls:Controls;

	override public function create() {
		super.create();
		bgColor = FlxColor.WHITE;
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in
		_controls = new Controls();
		_logo = new FlxSprite(0, 0);
		_logo.loadGraphic("assets/images/hl_logo.png", false, 535, 239);
		_logo.x = (FlxG.width / 2) - (_logo.width / 2);
		_logo.y = (FlxG.height / 2) - (_logo.height / 2);
		add(_logo);
		FlxG.camera.antialiasing = true;
	}

	function finishTimer(_) { 
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, goToSaveScreen);
	}	

	function goToSaveScreen() {
		FlxG.switchState(new SaveWarning());
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_timer = new FlxTimer();
		_timer.start(2, finishTimer, 1);
		if (_controls.cross.check() || _controls.start.check()) goToSaveScreen();
	}
}

class SaveWarning extends GameState {
	var _gameSaveText:FlxText;
	var _timer:FlxTimer;
	var _spinner:FlxSprite;
	var _controls:Controls;

	override public function create() {
		super.create();
		bgColor = FlxColor.BLACK;

		_controls = new Controls();
		// Add loading spinner
		_spinner = new FlxSprite(
			(FlxG.width / 2) - (67 / 2), 
			300).loadGraphic("assets/images/icons/loading_spinner.png", false, 67, 67);
		_spinner.angularVelocity = 200;
		add(_spinner);

		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		_gameSaveText = new FlxText(0, (FlxG.height / 2), FlxG.width,"
			This game saves automatically at certain points. \n
			Please do not switch off power when the above icon is displayed.");
		_gameSaveText.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, CENTER);
		add(_gameSaveText);
	}

	function goToMainMenu() {
		FlxG.switchState(new MainMenu());
	}

	function finishTimer(_) { 
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, goToMainMenu);
	}	

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_timer = new FlxTimer();
		_timer.start(4, finishTimer, 1);
		if (_controls.cross.check() || _controls.start.check()) goToMainMenu();
	}
}
