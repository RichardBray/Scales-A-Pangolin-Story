package components;


import flixel.FlxSprite;
import flixel.FlxObject;

class LevelSprite extends FlxSprite {
  public function new(X:Float, Y:Float, ?Orientation:Null<String>) {
    super(X, Y);
		setFacingFlip(FlxObject.RIGHT, true, false);
		setFacingFlip(FlxObject.LEFT, false, false); 

    facing = (Orientation == null) ? FlxObject.LEFT : FlxObject.RIGHT;
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  }
}