package;

import flixel.util.FlxColor;
// Typedefs
import LevelState.CollMap;

class Constants {
  // Fonts
  public static var smlFont:Int = 20;
  public static var medFont:Int = 33;
  public static var lrgFont:Int = 48;

  // Colours
  public static var primaryColor:FlxColor = 0xff0F272C;     // Dark background green
  public static var secondaryColor:FlxColor = 0xffF73156;   // Hot pink
  public static var slimeGreenColor:FlxColor = 0xff77AD0D;   // Slime green

  public static var initialColMap:Void->CollMap = () -> [
    "Level-1-0" => [], 
    "Level-1-A" => []
  ];
}