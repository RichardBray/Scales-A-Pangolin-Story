package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Typedefs
import Menu.MenuData;

class LevelEnd extends FlxState {
	var _playerScore:Int;
	var _endHeading:FlxText;
	var _txtPlayerScore:FlxText;
	var _gameSave:FlxSave;
	var _menu:Menu;

	/**
	 * @param PlayerScore Show on end screen
	 */
	public function new(PlayerScore:Int = 0):Void {
		super();
		_playerScore = PlayerScore;
	}

	override public function create():Void {
		super.create();
		bgColor = 0xff181818; // Game background color

		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // State fades in

		FlxG.sound.music.stop();
		FlxG.sound.music = null; // Make sure there's no music

		_endHeading = new FlxText(30, 30, 300, "Level 1 clear!!", 32);
		add(_endHeading);

		_txtPlayerScore = new FlxText(30, 120, 300, "You scored: " + _playerScore + "/25", 25);
		add(_txtPlayerScore);

		var _menuData:Array<MenuData> = [
			{
				title: "Try Again",
				func: () -> FlxG.switchState(new LevelOne(0, 3, null, false, _gameSave))
			},
			{
				title: "Quit",
				func: () -> FlxG.switchState(new MainMenu())
			}
		];

		_menu = new Menu(30, 350, 150, _menuData);
		add(_menu);
	}
}
