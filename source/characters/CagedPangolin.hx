package characters;

import flixel.FlxSprite;

class CagedPangolin extends FlxSprite {
  var _playerHit:Bool = false;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic("assets/images/characters/caged_pango.png", true, 315, 523);

    animation.add("crying", [for (i in 0...4) i], 8, true);
    animation.add("breakUp", [for (i in 5...9) i], 8, false);
    // animation.play("crying");
  }

  override public function kill() {
    _playerHit = true;
		alive = false;
    haxe.Timer.delay(() -> {
      exists = false;
    }, 1000);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    (_playerHit) ? animation.play("breakUp") : animation.play("crying");
  }
}