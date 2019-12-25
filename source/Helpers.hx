package;

import flixel.FlxG;
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

	/**
	 * Helper function to play level environment sounds.
	 *
	 * @param SoundFile	Location of sound file `assets/sounds/environment/[value].ogg`
	 * @param XPos	Horizontal position of sound, should prefably be in the middle or object
	 * @param YPos	Vertical position of sound, should prefably be in the middle or object
	 * @param Player Instance of player
	 * @param Volumne	What max volume of sound should be
	 * @param Radius	How much space the sound shoud take up in the environment
	 */
	public static function playProximitySound(
		SoundFile:String, 
		XPos:Float, 
		YPos: Float, 
		Player: Player,
		Volume:Float = 0.8,		
		Radius:Int = 2000
	) {
		FlxG.sound.load(
			'assets/sounds/environment/$SoundFile.ogg', 
			Volume, 
			true
		).proximity(XPos, YPos, Player, Radius, false).play();			
	} 
}