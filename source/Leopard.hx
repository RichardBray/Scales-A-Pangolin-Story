package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

class Leopard extends Enemy {
  var _seconds:Float = 0;
  var _enemyDying:Bool = false;

  public function new(X:Float, Y:Float) {
    super(X, Y + 55);
    health = 4;

    loadGraphic("assets/images/leopard.png", true, 338, 170);
    updateSpriteHitbox(78, 55, this);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);  

		// Animations
		animation.add("walking", [for (i in 0...5) i], 6, true);
    animation.add("running", [for (i in 6...11) i], 12, true); 
    animation.add("dying", [for (i in 12...17) i], 6, true);      
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

  function running() {
    animation.play("running");
  }

  function movingLeft(FaceLeft:Bool = true) {
    var walkingDistance:Int = 200;
		velocity.x = FaceLeft ? -walkingDistance: walkingDistance;
		facing = FaceLeft ? FlxObject.LEFT : FlxObject.RIGHT;
  }

	override public function kill() {
    _enemyDying = true;
		dieSlowly();
  }

  override public function update(Elapsed:Float):Void {
    super.update(Elapsed);
    _seconds += Elapsed;
    _enemyDying ? {
      animation.play("dying");
      velocity.x = 0;
    } : pacing();
  }
}