package;

import flixel.system.FlxSound;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class LevelEnd extends FlxState {
	var _playerScore:Int;
	var _endHeading:FlxText;
	var _txtPlayerScore:FlxText;
	var _choices:Array<FlxText>;
	var _pointer:FlxSprite;
	var _selected:Int = 0;
	var _gameMusic:FlxSound;

	/**
	 * @param PlayerScore Show on end screen
	 * @param GameMusic   End previous level music
	 */
	public function new(PlayerScore:Int = 0, GameMusic:FlxSound = null):Void {
		super();
		_playerScore = PlayerScore;
		_gameMusic = GameMusic;
	}

	override public function create():Void {
		bgColor = 0xff181818; // Game background color
		js.Browser.console.log(_gameMusic, '_gameMusic');
		_gameMusic.pause();
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // State fades in

		_endHeading = new FlxText(30, 30, 300, "Level 1 clear!!", 32);
		add(_endHeading);

		_txtPlayerScore = new FlxText(30, 120, 300, "You scored: " + _playerScore + "/25", 25);
		add(_txtPlayerScore);

		_pointer = new FlxSprite(30, 350);
		_pointer.makeGraphic(150, 40, 0xffdc2de4);
		add(_pointer);

		_choices = new Array<FlxText>();
		_choices.push(new FlxText(30, 350, 0, "Try Again", 22));
		_choices.push(new FlxText(30, 400, 0, "Quit", 22));

		// Adds text to screen
		_choices.map((_choice:FlxText) -> {
			add(_choice);
		});
		super.create();
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			switch _selected {
				case 0:
					// Restarts the game / level
					FlxG.switchState(new PlayState());
				case 1:
					FlxG.switchState(new MainMenu());
				default:
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
}
