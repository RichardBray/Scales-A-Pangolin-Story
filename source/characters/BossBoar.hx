package characters;

import flixel.system.FlxSound;
import states.LevelState;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;


class BossBoar extends Enemy {
  var _seconds:Float = 0;
  var _enemyDying:Bool = false;
  var _hitLeftBoundary:Bool = false;
  var _boarAttacked:Bool = false;
  var _boarCharged:Bool = false;
  var _randomStopNumber:Int = 0; // Randomly generated number to decidee when boar stops running
  var _attackMode:Bool = false; // When Boar has seen player for first time  
  var _levelState:LevelState; // Used to trigger boss music
  var _playBossMusicOnce:Bool = false; // Hacky way to prevent music from playing multiple times  
  // Sounds
  var _startSnd:FlxSound;
  var _endSnd:FlxSound;
  var _hurtSnd:FlxSound;

  var _boarStartMusicPlayed:Bool = false; // Hacky way for preventing music played twice

  var _movementDistance:Int = 530;
  final _movementDistanceFast:Int = 700;

  public function new(X:Float, Y:Float, Parent:LevelState) {
    super(X, Y);

    _startSnd = FlxG.sound.load("assets/sounds/boar-boss/start.ogg");
    _endSnd = FlxG.sound.load("assets/sounds/boar-boss/end.ogg");
    _hurtSnd = FlxG.sound.load("assets/sounds/boar-boss/hit.ogg");

    #if debug
      health = 1;
    #else
      health = 7;
    #end
    hasCollisions = true; 
    _levelState = Parent;

    loadGraphic("assets/images/characters/BOARBOSS-01.png", true, 382, 154);
    updateSpriteHitbox(160, 55, this);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);   

    // Animations    
    animation.add("walking", [for (i in 0...6) i], 8, true); 
    animation.add("charging", [for (i in 32...48) i], 8, true); 
    animation.add("running", [for (i in 64...68) i], 8, true);  
    animation.add("attacked", [for (i in 69...70) i], 6, true);
    animation.add("dying", [for (i in 71...75) i], 6, true);

    // Needed for movement (for some reason)
    acceleration.y = Constants.worldGravity;
  }

  /**
   * Pacing before seeing player. 
   */
  function pacing() {
    final walkingTime:Int = 3;

    animation.play("walking");
    if (_seconds < walkingTime) {
      movingLeft(true);
    } else if (_seconds < (walkingTime * 2)) {
      movingLeft(false);
    } else if (Math.round(_seconds) == (walkingTime * 2)) {
      _seconds = 0;
    }
  }  

  /**
   * Flip sprite based on if they are pacing left or right
   *
   * @param FaceLeft If sprite is facing left or not
   */
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
   * Boar has spotted player, so it roars and starts attacking.
   */
  function inAttackMode() {
    if (attacking && facing == FlxObject.LEFT && isOnScreen()) _attackMode = true;

    if (_attackMode) {
      if (_boarCharged) {
        // Play boar music
        if (!_playBossMusicOnce) {
          _levelState.playMusic("assets/music/boss-fight.ogg", 0.7);
          _playBossMusicOnce = true;
        }
        running();
      } else {
        // Boar roars
        if (!_boarStartMusicPlayed) {
          _startSnd.play();
          _boarStartMusicPlayed = true;
        }
        var _chargeTimer:FlxTimer = new FlxTimer();
        animation.play("charging");
        velocity.x = 0; // Stop moving
        _chargeTimer.start(2, (_) -> {_boarCharged = true;}, 1);	
      }
    } else {
      pacing();
    }
  }

  /**
   * Trigger enemy attacked animation and kill enemy if health is 0 or below.
   */
  override public function hurt(Damage:Float) {
    _boarAttacked = true;
		health = health - Damage;
    _hurtSnd.play();
		if (health <= 0) kill();   
  } 

  /**
   * Play death animation when player dies.
   */
	override public function kill() {
    _enemyDying = true;
    FlxG.camera.flash(FlxColor.WHITE, 0.5, turnOffSlowMo);
    FlxG.timeScale = 0.35;
    _endSnd.play();
    _levelState.playMusic(Constants.jungleMusic);
		dieSlowly();
  }  

	function turnOffSlowMo() {
		FlxG.timeScale = 1.0;
	}  

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    _seconds += Elapsed;
    _enemyDying ? {
      animation.play("dying");
      velocity.x = 0;
    } : inAttackMode();

    // Make boar stop more when health is low
    if (health <= 3) {
      _movementDistance = _movementDistanceFast;
    }

    // Play attack anim when player gets hit.
    if (_boarAttacked) {
      var _attackedTimer:FlxTimer = new FlxTimer();
      animation.play("attacked");
      velocity.x = 0;
      _attackedTimer.start(0.25, (_) -> {_boarAttacked = false;}, 1);      
    }

    // Offset to prevent accidental player attacks
    if (facing == FlxObject.LEFT ) {
      offset.x = 90;
    } else {
      offset.x = 60;
    }    
  }     
}