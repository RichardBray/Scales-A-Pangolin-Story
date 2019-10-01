package;

import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxVelocity;


class Leopard extends Enemy {
  var _seconds:Float = 0;
  var _enemyDying:Bool = false;
  var _leopardRoared:Bool = false;
  var _hitLeftBoundary:Bool = false;
  var _attackMode:Bool = false; // When leapord has seen player for first time

  static var runningSpeed:Int = 800;

  public function new(X:Float, Y:Float) {
    super(X, Y + 55);
    health = 20;
    loadGraphic("assets/images/leopard.png", true, 338, 170);
    updateSpriteHitbox(78, 55, this);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);  

		// Animations
		animation.add("walking", [for (i in 0...5) i], 6, true);
    animation.add("running", [for (i in 6...11) i], 10, true); 
    animation.add("dying", [for (i in 12...17) i], 6, true);   
    animation.add("roaring", [0], 6, true);
    animation.add("attacked", [1], 6, true);
    // Leopard jumping   
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
    if (!_hitLeftBoundary) {
      FlxVelocity.moveTowardsPoint(this, boundaryLeft, runningSpeed);
      facing = FlxObject.LEFT;
      if (Std.int(this.getPosition().x) <= Std.int(boundaryLeft.x)) _hitLeftBoundary = true;
    } else {
      FlxVelocity.moveTowardsPoint(this, boundaryRight, runningSpeed);
      facing = FlxObject.RIGHT;
      if (Std.int(this.getPosition().x) > (Std.int(boundaryRight.x) - this.width)) _hitLeftBoundary = false;
    }
  }

  function movingLeft(FaceLeft:Bool = true) {
    var walkingDistance:Int = 200;
		velocity.x = FaceLeft ? -walkingDistance: walkingDistance;
		facing = FaceLeft ? FlxObject.LEFT : FlxObject.RIGHT;
  }

  /**
   * Leopart has spotted player, so it roars and starts attacking.
   */
  function inAttackMode() {
    if (attacking && facing == FlxObject.LEFT) _attackMode = true;
    if (_attackMode) {
      if (_leopardRoared) {
        running();
      } else {
        var _roarTimer:FlxTimer = new FlxTimer();
        animation.play("roaring");
        velocity.x = 0;
        _roarTimer.start(2, (_) -> {
          _leopardRoared = true;
        }, 1);	
      }
    } else {
      pacing();
    }
  }

	override public function kill() {
    _enemyDying = true;
		dieSlowly();
  }

  override public function update(Elapsed:Float):Void {
    super.update(Elapsed);
    trace(this.health, "Leopard health");
    _seconds += Elapsed;
    _enemyDying ? {
      animation.play("dying");
      velocity.x = 0;
    } : inAttackMode();
  }
}