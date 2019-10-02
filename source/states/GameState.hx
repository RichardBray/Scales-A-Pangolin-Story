package states;

import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxG;

class GameState extends FlxState {
  override public function create() {
		FlxG.autoPause = false;
		#if !debug
		FlxG.mouse.enabled = false; // Hide the mouse cursor
		#end
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in    
  }
}