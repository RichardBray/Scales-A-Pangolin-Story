package levels;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.FlxSave;
import states.GameState;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.shapes.FlxShapeCircle;

using Lambda;

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
      locked:true,
      onSelect:() -> trace("level one")
    },
    {
      x: 400,
      y: 150,
      locked:true,
      onSelect:() -> trace("level two")
    },
    {
      x: 680,
      y: 230,
      locked:true,
      onSelect:() -> trace("level three")
    },
    {
      x: 980,
      y: 200,
      locked:true,
      onSelect:() -> trace("level four")
    }             
  ];
  var _grpLevelIndicators:FlxSpriteGroup;
  var _controls:Controls;
  var _levelPointer:FlxSprite;
  var _gameSave:FlxSave;

	// Sounds
	var _sndMove:FlxSound;
	var _sndSelect:FlxSound;

  // Remove after save game is added
  var _lastCompletedLevel:Int = 1;
  var _savedLevelData:Dynamic;  


  public function new(?GameSave:FlxSave) {
    super();
    if (GameSave != null) _gameSave = GameSave;

		//Sounds
		_sndMove = FlxG.sound.load(Constants.sndMenuMove);
		_sndSelect = FlxG.sound.load(Constants.sndMenuSelect);    
  }

  override public function create() {
    super.create();
    bgColor = 0xffBDEDE1;
  
    _grpLevelIndicators = new FlxSpriteGroup();

    _levelPos.mapi((idx:Int, level:LevelData) -> {
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

    if (_controls.cross.check()) {
      _sndSelect.play(true); 

      // So that sound plays before action happens
      haxe.Timer.delay(() -> {
        _levelPos[_lastCompletedLevel].onSelect();
      }, 350);	      
    }
  
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

    if (_controls.left.check() || _controls.right.check()) {
      _sndMove.play(true);
    } 

		// Paused game state
		if (_controls.start.check()) {
			_sndSelect.play();
			// SubState needs to be recreated here as it will be destroyed
			var _pauseMenu:PauseMenu = new PauseMenu(false, null, _gameSave);
			openSubState(_pauseMenu);
		}        
  }
}