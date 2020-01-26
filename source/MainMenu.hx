package;

import openfl.system.System;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;

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
	var _openCloseText:String = "Press SPACE to continue, E to close";
	var _showDemoModal:Bool = false;

	// Sound
	var _sndSelect:FlxSound;

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
		_gameTitle.offset.set(25, 0);
		_gameTitle.loadGraphic("assets/images/main_menu/scales_logo.png", false, 848, 347);
		add(_gameTitle);

		_gameSubTitle = new FlxText(0, _gameTitle.y + 395, 0, "A Pangolin Story");
		_gameSubTitle.setFormat(Constants.squareFont, 75, Constants.slimeGreenColor);
		_gameSubTitle.screenCenter(X);
		add(_gameSubTitle);

		_startText = new FlxText(0, _gameTitle.y + 520, 0, "Press SPACE to start");
		_startText.setFormat(Constants.squareFont, Constants.medFont);
		_startText.screenCenter(X);
		_startText.alpha = 1;
		add(_startText);

		var _continueOption:Array<MenuData> = [
			{
				title: "Continue",
				func: selectContinue
			},
		];
	
		var _otherOptions:Array<MenuData> = [
			{
				title: "Start Demo", // New Game
				func: selectNewGame
			},
			{
				title: "Exit game",
				func: () -> System.exit(0)
			}			
		];

		_menu = new Menu(_gameTitle.x, _gameTitle.y + 520, _titleWidth, menuData(_continueOption, _otherOptions), true);
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

		// Sounds
		_sndSelect = FlxG.sound.load(Constants.sndMenuSelect);

		super.create();	

		FlxG.sound.playMusic("assets/music/title_music.ogg", 0.9, false);	
		FlxG.sound.music.persist = false;
	}

	/**
	 * This method checks if there is any saved data and displays the continue option if there is.
	 *
	 * @param ContinueOption	Menu option for continue only
	 * @param	OtherOptions	Other menu options, start game, instuctions...
	 */
	function menuData(ContinueOption:Array<MenuData>, OtherOptions:Array<MenuData>):Array<MenuData> {
		return _gameSave.data.levelName == null
			? OtherOptions
			: ContinueOption.concat(OtherOptions);		
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

		if (_controls.cross_jr.check()) {
			if (!_showChoices) {
				_sndSelect.play();
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
			showModal("You have no saved games :(", null, true, "Press E to close");
		} else {
			loadLevel(_gameSave, Constants.levelNames[_gameSave.data.levelName]);
		}
	}

	function selectNewGame() {
		if (_gameSave.data.levelName == null) { // No saved game
			// Below line is shown for demo only
			showModal(
				"Welcome to the Scales demo. There is a lot to do before this game is finished, even this demo isn't complete. We just wanted to give you a glimpse of what we've been working on.\n\rHave fun :)", 
				() -> initNewGame(), 
				true,
				_openCloseText
			);
			// initNewGame();
		} else {
			showModal('This will erase your saved games. Do you want to continue?', () -> initNewGame(true), true, _openCloseText);
		}
	}

	function initNewGame(?EraseSave:Bool = false) {
		if (EraseSave) _gameSave.erase();
		FlxG.switchState(new levels.LevelOne.Intro(_gameSave));
	}

	/**
	 * Shows the menu page modal.
	 *
	 * @param Text						Text to show in the modal
	 * @param ConfirmCallback	Function to run when confirm option is chosen
	 * @param ShowOptions			Whether the modal has `press button for yes` text
	 * @param OptionsText			Text for `press button for yes` if something different is desired
	 */
	function showModal(
		Text:String, 
		?ConfirmCallback:Void->Void,
		?ShowOptions:Bool,
		?OptionsText:String
	) {
		var _modal:MainMenuModal = new MainMenuModal(Text, ConfirmCallback, ShowOptions, OptionsText);
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
		_logo.loadGraphic("assets/images/misc/hl_logo.png", false, 535, 239);
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
