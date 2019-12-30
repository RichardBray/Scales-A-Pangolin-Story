package;


import openfl.display.StageQuality;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		#if !debug
		addChild(new FlxGame(1920, 1080, MainMenu.HLScreen, 1, 60, 60, true));
		#else 
		addChild(new FlxGame(1920, 1080, levels.LevelFive, 1, 60, 60, true));
		#end
		FlxG.game.stage.quality = StageQuality.LOW;
	}
}
