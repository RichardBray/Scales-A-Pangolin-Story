package levels;

import states.GameState;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.shapes.FlxShapeCircle;


typedef LevelData = {
  x:Int,
  y:Int,
  locked:Bool
};

class LevelSelect extends GameState {
  var _levelPos:Array<LevelData> = [
    {
      x: 50,
      y: 200,
      locked:true
    },
    {
      x: 400,
      y: 150,
      locked:true
    },
    {
      x: 680,
      y: 230,
      locked:true
    },
    {
      x: 980,
      y: 200,
      locked:true
    }             
  ];
  var _grpLevelIndicators:FlxSpriteGroup;
  var _controls:Controls;
  var _levelPointer:FlxSprite;
  var _anyKeyPressed:Bool = false;
  var _seconds:Float = 0;

  // Remove after save game is added
  var _lastCompletedLevel:Int = 1;

  override public function create() {
    super.create();
    bgColor = 0xffBDEDE1;

    _grpLevelIndicators = new FlxSpriteGroup();

    _levelPos.map((level:LevelData) -> {
      var levelIndicator:FlxShapeCircle = new FlxShapeCircle(
        level.x, 
        level.y, 
        60, 			
        { thickness:6, color:Constants.primaryColorLight }, 
			  Constants.primaryColor);
    levelIndicator.scrollFactor.set(0, 0);
      _grpLevelIndicators.add(levelIndicator);        
    });

    add(_grpLevelIndicators);

    _levelPointer = new FlxSprite(0, 0);
    add(_levelPointer);

    // Intialise controls
    _controls = new Controls();
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    _seconds = _seconds + Elapsed;
    // Initial level pointer position
    _levelPointer.setPosition(_levelPos[_lastCompletedLevel].x, _levelPos[_lastCompletedLevel].y);
    var roundedSeconds = Std.int((_seconds * 10));
    trace(roundedSeconds);
    if (roundedSeconds % 10 == 0) {
      _anyKeyPressed = false;
      trace(_lastCompletedLevel);
    }

    if (!_anyKeyPressed) {
      if (_controls.right.check()) {
        if (_lastCompletedLevel == (_levelPos.length -1)) {
          _lastCompletedLevel = 0;
        } else {
          _lastCompletedLevel = _lastCompletedLevel+1;
        }
        _anyKeyPressed = true;
      }

      if (_controls.left.check()) {
        if (_lastCompletedLevel == 0) {
          _lastCompletedLevel = (_levelPos.length - 1);
        } else {
          _lastCompletedLevel--;
        }
        _anyKeyPressed = true;
      }   
    } 
  }
}