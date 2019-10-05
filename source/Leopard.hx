package;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxVelocity;


class Leopard extends Enemy {
  var _seconds:Float = 0;
  var _enemyDying:Bool = false;
  var _leopardRoared:Bool = false;
  var _leopardAttacked:Bool = false;
  var _hitLeftBoundary:Bool = false;
  var _attackMode:Bool = false; // When leapord has seen player for first time
  var _randomJumpNumber:Int = 0;
  var _secondsVal:Int = 0;

  static var runningSpeed:Int = 800;

  public function new(X:Float, Y:Float) {
    super(X, Y + 55);
    health = 15;
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
    acceleration.y = Constants.worldGravity;
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

  function repeat() {
    var secondsInt:Int = Std.int(_seconds);
    if (secondsInt != _secondsVal) {
      _secondsVal = secondsInt;
      _randomJumpNumber = Std.random(120);
    }
  };  

  function running() {  
    // repeat();
     _randomJumpNumber = Std.random(50);
    // Initate running back and forth
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
        _roarTimer.start(2, (_) -> {_leopardRoared = true;}, 1);	
      }
    } else {
      pacing();
    }
  }

  /**
   * Trigger enemy attacked animation and kill enemy if health is 0 or below.
   */
  override public function hurt(Damage:Float) {
    _leopardAttacked = true;
		health = health - Damage;
		if (health <= 0) kill();   
  }

  /**
   * Play death animation when player dies.
   */
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
    } : inAttackMode();

    if (_randomJumpNumber == 5 && velocity.y <= 0) {
      js.Browser.console.log("leopard should jump");
      FlxTween.tween(velocity, {y: -800}, 0.2); 
    }

    if (_leopardAttacked) {
      var _attackedTimer:FlxTimer = new FlxTimer();
      animation.play("attacked");
      _attackedTimer.start(0.25, (_) -> {_leopardAttacked = false;}, 1);      
    }
  }
}