package;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.util.FlxTimer;


class Leopard extends Enemy {
  var _seconds:Float = 0;
  var _enemyDying:Bool = false;
  var _leopardRoared:Bool = false;
  var _leopardAttacked:Bool = false;
  var _hitLeftBoundary:Bool = false;
  var _attackMode:Bool = false; // When leapord has seen player for first time
  var _randomJumpNumber:Int = 0;
  var _jumpNmber:Int = 100;

  static var runningSpeed:Int = 800;
  static var _movementDistance:Int = 1000;

  public function new(X:Float, Y:Float) {
    super(X, Y + 55);
    health = 25;
    hasCollisions = true;
    
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

    // Leopard gravity   
    acceleration.y = Constants.worldGravity;
  }

  /**
   * Pacing before seeing player. 
   */
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
    var walkingDistance:Int = 200;
		velocity.x = FaceLeft ? -walkingDistance: walkingDistance;
		facing = FaceLeft ? FlxObject.LEFT : FlxObject.RIGHT;
  }

  /**
   * Place running animation, start jumping and cause leopard to go back and forth 
   * based on the boundaries.
   */
  function running() {  
     _randomJumpNumber = Std.random(_jumpNmber);
    animation.play("running");

    if (!_hitLeftBoundary) {
      facing = FlxObject.LEFT;
       if (Std.int(this.getPosition().x) <= Std.int(boundaryLeft.x)) _hitLeftBoundary = true;
       velocity.x = -_movementDistance;
    } else {
      facing = FlxObject.RIGHT;
      if (Std.int(this.getPosition().x) > (Std.int(boundaryRight.x) - this.width)) _hitLeftBoundary = false;
      velocity.x = _movementDistance;
    }
  }

  /**
   * Causes player to jump only when leopard is on the ground 
   * and random number is hit. `5` in this case.
   */
  function jumping() {
    if (_randomJumpNumber == 5 && velocity.y == 25) {
      FlxTween.tween(velocity, {y: -400}, 0.2); 
    }   
  }

  /**
   * Leopart has spotted player, so it roars and starts attacking.
   */
  function inAttackMode() {
    if (attacking && facing == FlxObject.LEFT) _attackMode = true;
    if (_attackMode) {
      if (_leopardRoared) {
        jumping();
        running();
      } else {
        // Leopard roars
        var _roarTimer:FlxTimer = new FlxTimer();
        animation.play("roaring");
        velocity.x = 0; // Stop moving
        _roarTimer.start(1.5, (_) -> {_leopardRoared = true;}, 1);	
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
      // Make sure leopard is on the ground before playing dying anim
      if (velocity.y <= 25) animation.play("dying");
      velocity.x = 0;
    } : inAttackMode();

    // Make leopard jump more when health is low
    if (health <= 10) _jumpNmber = Std.int(_jumpNmber / 2);

    // Play attack anim when player gets hit.
    if (_leopardAttacked) {
      var _attackedTimer:FlxTimer = new FlxTimer();
      animation.play("attacked");
      _attackedTimer.start(0.25, (_) -> {_leopardAttacked = false;}, 1);      
    }
  }
}