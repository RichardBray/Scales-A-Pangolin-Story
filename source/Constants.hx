package;

import flixel.util.FlxColor;
// Typedefs
import LevelState.CollMap;

class Constants {
  // Fonts
  public static var smlFont:Int = 20;
  public static var medFont:Int = 33;

  // Colours
  public static var primaryColor:FlxColor = 0xff205ab7;
  public static var secondaryColor:FlxColor = 0xffdc2de4;

  public static var initialColMap:Void->CollMap = () -> [
    "Level-1-0" => [], 
    "Level-1-A" => []
  ];
}