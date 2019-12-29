package components;


import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;

class Lava extends FlxSprite {
  var _sndLava:FlxSound;

  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    loadGraphic("assets/images/environments/SCALES_L1_LAVA.png", true, 358, 124);
    animation.add("flow", [for (i in 0...11) i], 8, true); 
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    animation.play("flow");
  }
}