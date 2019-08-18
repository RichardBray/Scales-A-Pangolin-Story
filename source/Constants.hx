package;

import flixel.util.FlxColor;
// Typedefs
import LevelState.CollMap;

class Constants {
	// general
	public static var projectVersion:String = "v0.6.0";
	public static var worldGravity:Int = 1500;
	public static var squareFont:String = "assets/fonts/Square.ttf";

	// Fonts
	public static var smlFont:Int = 20;
	public static var medFont:Int = 33;
	public static var lrgFont:Int = 48;

	// Colours
	public static var primaryColor:FlxColor = 0xff0F272C; // Dark background green
	public static var primaryColorLight:FlxColor = 0xff29706F; // Muted primary colour
	public static var secondaryColor:FlxColor = 0xffF73156; // Hot pink
	public static var slimeGreenColor:FlxColor = 0xff77AD0D; // Slime green

	// Controler strings
	// @todo different controler strings for gamepads
	public static var start:String = "ESC";

	// Collectables map for bugs
	public static var initialColMap:Void->CollMap = () -> [
		"Level-1-0" => [], 
		"Level-1-A" => [],
		"Level-2-0" => []
	];

	// Used to load levels from saves and restart levels
	public static var levelNames:Map<String, Class<LevelState>> = [
		"Level-1-0" => LevelOne, 
		"Level-2-0" => LevelTwo
	];
}
