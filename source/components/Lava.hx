package components;


import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;

class Lava extends FlxSprite {
  var _sndLava:FlxSound;
  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    loadGraphic("assets/images/components/lava.png", true, 358, 124);

    // Animations
    animation.add("flow", [for (i in 0...10) i], 8, true);
    _sndLava = FlxG.sound.load("assets/sounds/lava_loop.ogg"); 
    _sndLava.proximity(X, Y, FlxG.camera.target, FlxG.width *.1);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    _sndLava.play();
    animation.play("flow");
  }
}