package components;

import flixel.FlxSprite;
import flixel.FlxG;

class TermiteHill extends FlxSprite {
  var _playerDigging:Bool;

  public function new(X:Float = 0, Y:Float = 0, PlayerDigging:Bool = false) {
    super(X, Y);
    loadGraphic("assets/images/environments/L2_ANTHILL_01.png", true, 271, 345);
    animation.add("breakUp", [for (i in 0...13) i], 8, true);  
    _playerDigging = PlayerDigging;
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    if (_playerDigging) {
      animation.play("breakUp");
    }
  }
}