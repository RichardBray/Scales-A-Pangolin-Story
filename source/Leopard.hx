package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

class Leopard extends Enemy {
  var _seconds:Float = 0;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    health = 4;

    loadGraphic("assets/images/leopard.png", true, 338, 170);

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);  

		// Animations
		animation.add("walking", [for (i in 0...5) i], 5, true);
    animation.add("running", [for (i in 6...11) i], 12, true); 
    animation.add("dying", [for (i in 12...17) i], 12, true);      
  }

  function pacing() {
    animation.play("walking");
    var walkingTime:Int = 3;
    if (_seconds < walkingTime) {
      movingLeft(true);
    } else if (_seconds < (walkingTime * 2)) {
      movingLeft(false);
    } else if (Math.round(_seconds) == (walkingTime * 2)) {
      _seconds = 0;
    }
  }

  function movingLeft(FaceLeft:Bool = true) {
    var walkingDistance:Int = 30;
		velocity.x = FaceLeft ? -walkingDistance: walkingDistance;
		facing = FaceLeft ? FlxObject.LEFT : FlxObject.RIGHT;
  }

  override public function update(Elapsed:Float):Void {
    super.update(Elapsed);
    _seconds += Elapsed;
    pacing();
  }
}