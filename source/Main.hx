package;


import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
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
		addChild(new FlxGame(1920, 1080, levels.LevelSix, 1, 60, 60, true));
		#end
		// Make sure the game renders at 1080 with a 720 window
		FlxG.game.setFilters([new ShaderFilter(new FlxShader())]);
		// FlxG.game.stage.quality = StageQuality.LOW;					
	}
}
