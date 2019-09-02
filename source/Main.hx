package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(1920, 1080, MainMenu.HLScreen, 1, 60, 60, true));
		// addChild(new FlxGame(1920, 1080, LevelTwo, 1, 60, 60, true));
	}
}
