import flixel.FlxSprite;
import flixel.FlxG;

class Player extends FlxSprite {
  public static var GRAVITY:Float = 600;

  public function new(X:Float = 0, Y:Float = 0) {
    super(X,Y) // Pass X and Y arguments back to FlxSprite
  }
}