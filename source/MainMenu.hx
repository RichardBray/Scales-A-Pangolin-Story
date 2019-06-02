package;

// - Flixel
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;

// - OpenFL
class MainMenu extends FlxState {
	var _gameTitle:FlxText;
	var _choices:Array<FlxText>;
	var _pointer:FlxSprite;
	var _selected:Int = 0;
	var _startText:FlxText;

	override public function create():Void {
		FlxG.autoPause = false;
		#if !debug
		FlxG.mouse.visible = false; // Hide the mouse cursor
		#end
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in

		var titleWidth:Int = 450; // Worked thous out through trail and error
		bgColor = 0xff181818; // Game background color

		_gameTitle = new FlxText((FlxG.width / 2) - (titleWidth / 2), (FlxG.height / 2) - 100, titleWidth, "Pangolin Panic!", 48);
		add(_gameTitle);

		_pointer = new FlxSprite(_gameTitle.x, _gameTitle.y + 200);
		_pointer.makeGraphic(titleWidth, 40, 0xffdc2de4);
		// add(_pointer);

		_startText = new FlxText(0, _gameTitle.y + 200, 0, "Press ENTER to start", 22);
		_startText.screenCenter(X);
		add(_startText);

		_choices = new Array<FlxText>();
		_choices.push(new FlxText(0, _gameTitle.y + 200, 0, "New Game", 22));
		_choices.push(new FlxText(0, _gameTitle.y + 250, 0, "Load Game").setFormat(22, 0x777777));

		// Adds text to screen
		// _choices.map((_choice:FlxText) -> {
		// 	_choice.screenCenter(X);
		// 	add(_choice);
		// });
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		
		
		if (FlxG.keys.anyJustPressed([SPACE, ENTER, ANY])) {
			FlxG.switchState(new PlayState());
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
