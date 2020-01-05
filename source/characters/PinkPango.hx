package characters;

import flixel.FlxObject;
import flixel.FlxSprite;

class PinkPango extends FlxSprite {
  var _unwravelPango:Bool = false;
  var _pangoUnwravelled:Bool = false;

  public function new(X:Float = 0, Y:Float = 0, ?FlipX:Null<Bool>) {
    super(X, Y);

    loadGraphic("assets/images/characters/scales_pinkpango72.png", true, 282, 298);

    // Animations
    animation.add("hanging", [for (i in 0...3) i], 8, true);
    animation.add("unwravelling", [for (i in 14...27) i], 8, true); 
    animation.add("standing", [for (i in 28...33) i], 8, true);

    // Flips
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);   

    if (FlipX) facing = FlxObject.LEFT;
  }

  public function unwravel() {
    _unwravelPango = true;
  }


  function comingOut() {
    _pangoUnwravelled
      ? animation.play("standing")
      : {
          animation.play("unwravelling");
          haxe.Timer.delay(() -> {
            _pangoUnwravelled = true;
          }, 1500);	
        }
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    if (_unwravelPango) {
      comingOut();
    } else {
      animation.play("hanging");
    }
  }
}