package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(1280, 720, MainMenu, 1, 60, 60, true));
	}
}
