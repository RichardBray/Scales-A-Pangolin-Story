package characters;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class ZenMonkey extends FlxSprite {
  var _isTalking:Bool = false;
  var _downYPos:Float;
  var _normalYPos:Float;

  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);
    _downYPos = Y + 20;
    _normalYPos = Y;

    loadGraphic("assets/images/characters/L1_Monkey_72.png", true, 145, 136);

    // Animations
    animation.add("meditating", [for (i in 9...16) i], 8, true);
    animation.add("talking", [for (i in 0...8) i], 8, true);
  }

  public function toggleTalkingAnim(Value:Bool) {
    _isTalking = Value;  
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

    (_isTalking) ? {
      animation.play("talking");
      FlxTween.tween(this, {y: _downYPos}, .2);
    } : {
      animation.play("meditating");
      FlxTween.tween(this, {y: _normalYPos}, .2);
    }
  }
}