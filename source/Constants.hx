package;

import flixel.util.FlxColor;

// Internal
import states.LevelState;


class Constants {
	// general
	public static final projectVersion:String = "v0.9.0";
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
	public static final start:String = "ESC";
	public static final cross:String = "SPACE";
	public static final triangle:String = "E";
	
	// Sounds
	public static final sndMenuMove:String = "assets/sounds/menu_move.wav";
	public static final sndMenuSelect:String = "assets/sounds/menu_selected.wav";	
	public static final sndMenuClose:String = "assets/sounds/menu_close.ogg";

	// Music lengths
	public static final levelSelectMusic:Int = 61902;

	// Used to load levels from saves and restart levels
	public static final levelNames:Map<String, Class<LevelState>> = [
		"Level-1-0" => levels.LevelOne, 
		"Level-2-0" => levels.LevelTwo,
		"Level-3-0" => levels.LevelThree,
		"Level-4-0" => levels.LevelFour,
		"Level-5-0" => levels.LevelFive
	];
}
