package;

import flixel.util.FlxColor;

// Internal
import states.LevelState;


class Constants {
	// general
	public static final projectVersion:String = "v0.11.0";
	public static final worldGravity:Int = 1500;
	public static final squareFont:String = "assets/fonts/Square.ttf";

	// Fontse
	public static final smlFont:Int = 20;
	public static final hudFont:Int = 26;
	public static final medFont:Int = 33;
	public static final lrgFont:Int = 48;

	// Colours
	public static final primaryColor:FlxColor = 0xff0F272C; // Dark background green
	public static final primaryColorLight:FlxColor = 0xff29706F; // Muted primary colour
	public static final secondaryColor:FlxColor = 0xffF73156; // Hot pink
	public static final slimeGreenColor:FlxColor = 0xff77AD0D; // Slime green

	// Controler strings
	// @todo different controler strings for gamepads
	public static final start:String = "PAUSE";
	public static final cross:String = "JUMP";
	public static final triangle:String = "ACTION";
	
	// Sounds
	public static final sndMenuMove:String = "assets/sounds/sfx/menu_move.ogg";
	public static final sndMenuSelect:String = "assets/sounds/sfx/menu_selected.ogg";	
	public static final sndMenuClose:String = "assets/sounds/sfx/menu_close.ogg";

	// Ambient sounds
	public static final jungleMusic:String = "assets/music/jungle-sound.ogg";
	public static final caveMusic:String = "assets/sounds/environment/cave.ogg";

	/** Used to load levels from saves and restart levels */
	public static final levelNames:Map<String, Class<LevelState>> = [
		"Level-1-0" => levels.LevelOne, 
		"Level-2-0" => levels.LevelTwo,
		"Level-3-0" => levels.LevelThree,
		"Level-4-0" => levels.LevelFour,
		"Level-5-0" => levels.LevelFive,
		"Level-6-0" => levels.LevelSix		
	];
}
