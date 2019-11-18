package levels;

import states.GameState;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.shapes.FlxShapeCircle;


typedef LevelData = {
  x:Int,
  y:Int,
  locked:Bool,
  ?onSelect:Void -> Void
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
    // Initial level pointer position
    _levelPointer.setPosition(_levelPos[_lastCompletedLevel].x, _levelPos[_lastCompletedLevel].y);

    if (_controls.right.check()) {
      (_lastCompletedLevel == (_levelPos.length -1))
        ? _lastCompletedLevel = 0
        : _lastCompletedLevel++;
    }

    if (_controls.left.check()) {
      (_lastCompletedLevel == 0) 
        ? _lastCompletedLevel = (_levelPos.length - 1)
        : _lastCompletedLevel--;
    }    
  }
}