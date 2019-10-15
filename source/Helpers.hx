package;

import flixel.FlxState;
import states.LevelState;

class Helpers {

	/**
	 * Get level number form game save levelName and returns the correct class to restart from.
	 *
	 * @param LevelName	Name from game save data.
	 */
	public static function restartLevel(LevelName:String):Class<LevelState> {
		var splitLevelName:Array<String> = LevelName.split("-");
		var levelNum:Int = Std.parseInt(splitLevelName[1]);

		if (levelNum <= 4) return levels.LevelOne;
		return levels.LevelOne;
	}  
}