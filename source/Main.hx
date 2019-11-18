package;


import openfl.display.StageQuality;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
// import net.lion123dev.GameAnalytics;

class Main extends Sprite {
	public function new() {
		super();
		#if !debug
		addChild(new FlxGame(1920, 1080, MainMenu.HLScreen, 1, 60, 60, true));
		#else 
		addChild(new FlxGame(1920, 1080, levels.LevelSelect, 1, 60, 60, true));
		#end
		FlxG.game.stage.quality = StageQuality.LOW;


		// var ga:GameAnalytics = new GameAnalytics("0123456789abcdef0123456789abcdef", "0123456789abcdef0123456789abcdef01234567", false);

		// function onSuccess() {
		// 	trace("it worked!");
		// }	

		// function onFail(error:String) {
		// 	trace(error);
		// }	

		// ga.Init(onSuccess, onFail, GAPlatform.WINDOWS, GAPlatform.WINDOWS + " 10", "unknown", "manufacturer");	
		// ga.StartPosting();
		// ga.SendBusinessEvent("gems", "green_gem", 1, "USD");
		// ga.EndSession();
		// ga.ForcePost();					
	}
}
