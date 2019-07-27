package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxSave;

// Typedefs
import Menu.MenuData;

class LevelEnd extends GameState {
	var _playerScore:Int;
	var _endHeading:FlxText;
	var _txtPlayerScore:FlxText;
	var _gameSave:FlxSave;
	var _menu:Menu;
	var _levelName:Array<String>;

	/**
	 * End level screen for game
	 *
	 * @param PlayerScore Show on end screen
	 * @param LevelName 	Unique name of the last level, used to reset game if player presses `Try again`
	 * @param GameSave		Current game save
	 */
	public function new(PlayerScore:Int = 0, LevelName:String, GameSave:FlxSave) {
		super();
		_playerScore = PlayerScore;
		_levelName = LevelName.split("-"); // Splits the string to start at first part of the level
		_gameSave = GameSave;
	}

	override public function create() {
		super.create();
		bgColor = 0xff181818; // Game background color

		FlxG.sound.music.stop();
		FlxG.sound.music = null; // Make sure there's no music

		_endHeading = new FlxText(30, 30, 300, "Level 1 clear!!", 32);
		add(_endHeading);

		_txtPlayerScore = new FlxText(30, 120, 300, "You scored: " + _playerScore + "/26", 25);
		add(_txtPlayerScore);

		var _menuData:Array<MenuData> = [
			{
				title: "Try Again",
				func: () -> FlxG.switchState(new LevelOne(0, 3, null, false, resetGameSave(_gameSave)))
			},
			{
				title: "Quit",
				func: () -> FlxG.switchState(new MainMenu())
			}
		];

		_menu = new Menu(30, 350, 150, _menuData);
		add(_menu);
	}

	function resetGameSave(GameSave:FlxSave):FlxSave {
		GameSave.data.levelName = _levelName[0] + "-" + _levelName[1] + "-0";
		GameSave.data.playerScore = 0;
		GameSave.data.collectablesMap = Constants.initialColMap();
		GameSave.flush();
		return GameSave;
	}

}
