package components;

import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MovingCage extends FlxTypedGroup<FlxObject> {
  var _actualCage:FlxSprite;
  var _player:Player;
  var _playerFeetCollision:FlxObject;
  var _cageTopCollision:FlxObject;
  var _sndCageHit:FlxSound;
  var _sndPlayed:Bool = false;
  var _cageCatchCollision:FlxObject;

  var _seconds:Float = 0;
  var _startFromTop:Bool;

  public var cageHit:Bool = false;

  final DISTANCE = 200;
  final MOVEMENT_SPEED:Int = 2;
  final CAGE_WIDTH:Int = 600;
  final CAGE_HEIGHT:Int = 200;

  /**
   * Moving drone cage to catch pangolin
   *
   * @param X X position
   * @param Y Y position
   * @param StartFromTop Position of where drone should shart from
   * @param Player Player sprite for collisions
   * @param PlayerFeetCollisions
   */
  public function new(
    X:Float = 0, 
    Y:Float = 0, 
    StartFromTop:Bool = false,
    Player:Player,
    PlayerFeetCollisions:FlxObject
  ) {
    super();
    _startFromTop = StartFromTop;

    _actualCage = new FlxSprite(X, Y).makeGraphic(CAGE_WIDTH, CAGE_HEIGHT, FlxColor.BLUE);
    _actualCage.alpha = 1;
    add(_actualCage);

    _cageTopCollision = new FlxObject(X, Y, CAGE_WIDTH, 10);
    _cageTopCollision.immovable = true;
    add(_cageTopCollision);

    _cageCatchCollision = new FlxSprite((X + (CAGE_WIDTH / 2)), (Y - 90)).makeGraphic(30, 180, FlxColor.TRANSPARENT);
    _cageCatchCollision.immovable = true;
    add(_cageCatchCollision);

    _sndCageHit = FlxG.sound.load("assets/sounds/environment/platform_hit.ogg", 0.6);
    _player = Player;
  }

  function cageMovement(Object:FlxObject, StartFromTop:Bool) {
    var movementDistance:Int = StartFromTop ? DISTANCE : -DISTANCE;
    final seconds = Math.floor(_seconds);

    if (seconds < MOVEMENT_SPEED) {
      Object.velocity.y = movementDistance;
    } else if (seconds < (MOVEMENT_SPEED * 2)) {
      Object.velocity.y = -movementDistance;
    } else if (seconds == (MOVEMENT_SPEED * 2)) {
      _seconds = 0;
    }
  } 

  function stickyAndSound(Player:FlxObject, Platform:FlxObject) {
    stickyPlatorm(Player, Platform);
    cageHit = true;
    if (!_sndPlayed && !_player.isAscending) {
      _sndCageHit.play(true);
      _sndPlayed = true;
    }    
  }

  function stickyPlatorm(Player:FlxObject, Platform:FlxObject) {
    Player.velocity.y = _actualCage.velocity.y;
  } 
 
  override public function update(Elapsed:Float) {
    _seconds += Elapsed;
    super.update(Elapsed);

    cageMovement(_actualCage, _startFromTop);
    _cageTopCollision.y = _actualCage.y;
    _cageCatchCollision.y = _actualCage.y + 20;

    FlxG.collide(_player, _cageTopCollision, stickyAndSound);
    FlxG.collide(_playerFeetCollision, _cageTopCollision, stickyPlatorm);

		// Moving cage sound reset
    if (_player.isJumping) { // Bit of a hack and might cause a bug?
      _sndPlayed = false;
		}    

    FlxG.overlap(_player, _cageCatchCollision, (_, _) -> _player.resetPlayer());
  }
}