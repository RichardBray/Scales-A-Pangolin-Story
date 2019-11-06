package components;


import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;

class Lava extends FlxSprite {
  var _sndLava:FlxSound;

  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    loadGraphic("assets/images/components/SCALES_L1_LAVA.png", true, 358, 124);
    animation.add("flow", [for (i in 0...10) i], 8, true);

    // _sndLava = FlxG.sound.load("assets/sounds/lava_loop.ogg", 0, true, null, false);
    // _sndLava.proximity(x, y, FlxG.camera.target, FlxG.width *.1);
    // _sndLava.play().fadeIn(0.1, 0, 1);    
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    animation.play("flow");
  }
}