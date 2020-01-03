package characters;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxSprite;

class CagedPangolin extends FlxSprite {
  var _playerHit:Bool = false;
  public var sndCrash:FlxSound;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic("assets/images/characters/caged_pango.png", true, 315, 416);

    animation.add("crying", [for (i in 0...4) i], 8, true);
    animation.add("breakUp", [for (i in 5...9) i], 8, false);

    sndCrash = FlxG.sound.load("assets/sounds/environment/crash.ogg", .75);
  }

  override public function kill() {
    _playerHit = true;
		alive = false;
    haxe.Timer.delay(() -> {
      exists = false;
    }, 500);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    (_playerHit) ? animation.play("breakUp") : animation.play("crying");
  }
}