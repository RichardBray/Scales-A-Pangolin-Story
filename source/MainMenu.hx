package;

// - Flixel
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
// - OpenFL
import openfl.Lib;
import flash.system.System;

class MainMenu extends FlxState {
	var _gameTitle:FlxText;
	var _choices:Array<FlxText>;
	var _pointer:FlxSprite;
	var _selected:Int = 0;

	override public function create():Void {
		FlxG.autoPause = false;
		#if !debug
		FlxG.mouse.visible = false; // Hide the mouse cursor
		#end

		var titleWidth:Int = 450; // Worked thous out through trail and error
		bgColor = 0xff181818; // Game background color

		_gameTitle = new FlxText((FlxG.width / 2) - (titleWidth / 2), (FlxG.height / 2) - 100, titleWidth, "Pangolin Panic!", 48);
		add(_gameTitle);

		_pointer = new FlxSprite(_gameTitle.x, _gameTitle.y + 200);
		_pointer.makeGraphic(titleWidth, 40, 0xffdc2de4);
		add(_pointer);

		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_gameTitle.x, _gameTitle.y + 200, 0, "New Game", 22));
		_choices.push(new FlxText(_gameTitle.x, _gameTitle.y + 250, 0, "Quit", 22));

		// Adds text to screen
		_choices.map((_choice:FlxText) -> {
			_choice.screenCenter(X);
			add(_choice);
		});
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			switch _selected {
				case 0:
					// Restarts the game / level
					FlxG.switchState(new PlayState());
				case 1:
					// Closes the game
					// Lib.close();
					System.exit(0);
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
