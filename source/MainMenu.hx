package;

// - Flixel
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;


class MainMenu extends FlxState {
	var _gameTitle:FlxText;
	var _choices:Array<FlxText>;
	var _pointer:FlxSprite;
	var _selected:Int = 0;
	var _startText:FlxText;
	var _gameSave:FlxSave;
	var _continueColor:FlxColor;
	var _showChoices:Bool = false;

	override public function create():Void {
		FlxG.autoPause = false;
		#if !debug
		FlxG.mouse.visible = false; // Hide the mouse cursor
		#end
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		// Save data
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot

		var titleWidth:Int = 450; // Worked thous out through trail and error
		bgColor = 0xff181818; // Game background color

		_gameTitle = new FlxText((FlxG.width / 2) - (titleWidth / 2), (FlxG.height / 2) - 100, titleWidth, "Pangolin Panic!", 48);
		add(_gameTitle);

		_pointer = new FlxSprite(_gameTitle.x, _gameTitle.y + 200);
		_pointer.makeGraphic(titleWidth, 40, 0xffdc2de4);
		_pointer.alpha = 0;
		add(_pointer);

		_startText = new FlxText(0, _gameTitle.y + 200, 0, "Press ENTER to start", 22);
		_startText.screenCenter(X);
		add(_startText);

		_continueColor = _gameSave.data.levelName == null ? 0x777777 : 0xffffff;

		_choices = new Array<FlxText>();
		_choices.push(new FlxText(0, _gameTitle.y + 200, 0, "Continue").setFormat(22, _continueColor));
		_choices.push(new FlxText(0, _gameTitle.y + 250, 0, "New Game", 22));

		// Adds options to screen
		_choices.map((_choice:FlxText) -> {
			_choice.screenCenter(X);
			_choice.alpha = 0;
			add(_choice);
		});
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		if (FlxG.keys.anyJustPressed([SPACE, ENTER, ANY])) {
			if (!_showChoices) {
				_showChoices = true;
				_startText.alpha = 0;
				_pointer.alpha = 1;
				_choices.map((_choice:FlxText) -> {
					_choice.alpha = 1;
				});
			} else {
				switch _selected {
					case 0:
						if (_gameSave.data.levelName == null) { // No saved game
							showModal('You have no saved games');
						} else {
							var levelNames:Map<String, Class<GameLevel>> = ["Level-1-0" => LevelOne, "Level-1-A" => LevelOneA];
							loadLevel(_gameSave, levelNames[_gameSave.data.levelName]);
						}
					case 1:
						if (_gameSave.data.levelName == null) { // No saved game
							initNewGame();
						} else {
							showModal('This will erase your saved games. Do you want to continue?', initNewGame, true);
						}
				}
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
	}

	function initNewGame():Void {
		// _gameSave.erase();
		FlxG.switchState(new LevelOne(0, 3, null, false, _gameSave));
	}

	function showModal(Text:String, ?ConfirmCallback:Void->Void, ?ShowOptions:Bool):Void {
		var _modal:MainMenuModal = new MainMenuModal(Text, ConfirmCallback, ShowOptions);
		openSubState(_modal);
	}

	function loadLevel(GameSave:FlxSave, Level:Class<GameLevel>) {
		FlxG.switchState(Type.createInstance(Level, [GameSave.data.playerScore, 3, GameSave.data.collectablesMap, null, GameSave]));
	}
}
