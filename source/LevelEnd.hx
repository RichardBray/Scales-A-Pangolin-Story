package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class LevelEnd extends FlxState {
	var _playerScore:Int;
	var _endHeading:FlxText;
	var _txtPlayerScore:FlxText;

	public function new(PlayerScore:Int = 0):Void {
		super();
		_playerScore = PlayerScore;
	}

	override public function create():Void {
		bgColor = 0xff181818; // Game background color

		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // State fades in

		_endHeading = new FlxText(10, 10, 300, "Level 1 clear", 32);
		add(_endHeading);

		_txtPlayerScore = new FlxText(10, 50, 300, "You scored: " + _playerScore, 16);
		add(_txtPlayerScore);
	}
}
