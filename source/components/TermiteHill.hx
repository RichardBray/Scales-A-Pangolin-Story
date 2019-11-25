package components;

import flixel.FlxSprite;
import flixel.FlxG;

class TermiteHill extends FlxSprite {
  var _seconds:Float;

  public var playerDigging:Bool = false;

  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    loadGraphic("assets/images/environments/L2_ANTHILL_01.png", true, 271, 345);
    animation.add("breakUp", [for (i in 0...13) i], 8, true);  
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    if (playerDigging) {
      animation.play("breakUp");
      _seconds += Elapsed;
    }

    // Remove termite hill after one second
    if (Std.int(_seconds) == 1) this.kill();
  }
}