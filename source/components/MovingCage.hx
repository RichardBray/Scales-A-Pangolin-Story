package components;


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

  public var cageCatchCollision:FlxObject;

  var _seconds:Float = 0;
  var _startFromTop:Bool;

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
    _actualCage.alpha = 0.2;
    add(_actualCage);

    _cageTopCollision = new FlxObject(X, Y, CAGE_WIDTH, 40);
    _cageTopCollision.immovable = true;
    add(_cageTopCollision);

    cageCatchCollision = new FlxSprite((X + (CAGE_WIDTH / 2)), (Y - 90)).makeGraphic(30, 180, FlxColor.RED);
    cageCatchCollision.immovable = true;
    add(cageCatchCollision);

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

  override public function update(Elapsed:Float) {
    _seconds += Elapsed;
    super.update(Elapsed);

    cageMovement(_actualCage, _startFromTop);
    _cageTopCollision.y = _actualCage.y;
    cageCatchCollision.y = _actualCage.y + 20;

    FlxG.collide(_player, _cageTopCollision);
    FlxG.collide(_playerFeetCollision, _cageTopCollision);

    FlxG.overlap(_player, cageCatchCollision, (_, _) -> _player.resetPlayer());
  }
}