package levels;

import levels.LevelFive.IntroFive;
import flixel.util.FlxColor;
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
  var _grpLevelIndicators:FlxSpriteGroup;
  var _controls:Controls;
  var _levelPointer:FlxShapeCircle; //FlxSprite;
  var _gameSave:FlxSave;
  var _mapBg:FlxSprite;

	// Sounds
	var _sndMove:FlxSound;
	var _sndSelect:FlxSound;

  // Remove after save game is added START
  var _lastCompletedLevel:Int = 1;
  var _savedLevelData:Dynamic = [
    {
      locked: false,
      stars: 3
    }
  ];  
  var _levelSelect:Map<String, Bool> = [
    "firstTime" => true,
    "hasPangolin" => false,
    "allLevelsFinished" => false
  ];

  var _levelPos:Array<LevelData>;
  // Remove after save game is added END

  public function new(?GameSave:FlxSave) {
    super();
    if (GameSave != null) _gameSave = GameSave;

		//Sounds
		_sndMove = FlxG.sound.load(Constants.sndMenuMove);
		_sndSelect = FlxG.sound.load(Constants.sndMenuSelect);    
  }

  override public function create() {
    super.create();
    FlxG.sound.music.play();
    FlxG.sound.playMusic("assets/music/level_select.ogg", 0.6, true);
  
    _mapBg = new FlxSprite(0, 0).loadGraphic("assets/images/backgrounds/test_map.jpg", false, 1920, 1080);
    add(_mapBg);

    _grpLevelIndicators = new FlxSpriteGroup();

    _levelPos.mapi((idx:Int, level:LevelData) -> {
      var levelIndicator:FlxShapeCircle = new FlxShapeCircle(
        level.x, 
        level.y, 
        80, 			
        { thickness:6, color:FlxColor.WHITE }, 
			  Constants.primaryColor);
      levelIndicator.scrollFactor.set(0, 0);
      // Add data from save
      _grpLevelIndicators.add(levelIndicator);        
    });

    add(_grpLevelIndicators);

    _levelPointer = new FlxShapeCircle(
        0, 
        0, 
        80, 			
        { thickness:10, color:Constants.secondaryColor }, 
			  FlxColor.TRANSPARENT);
    add(_levelPointer);

    _levelPos = [
      {
        x: 230,
        y: 544,
        locked:true,
        onSelect:() -> FlxG.switchState(new LevelOne(_gameSave))
      },
      {
        x: 118,
        y: 114,
        locked:true,
        onSelect:() -> FlxG.switchState(new LevelFive.IntroFive(_gameSave))
      },
      {
        x: 594,
        y: 207,
        locked:true,
        onSelect:() -> trace("level three")
      },
      {
        x: 1251,
        y: 567,
        locked:true,
        onSelect:() -> trace("level four")
      },
      {
        x: 1561,
        y: 307,
        locked:true,
        onSelect:() -> trace("level five")
      },
      {
        x: 1610,
        y: 778,
        locked:true,
        onSelect:() -> trace("level six")
      }                     
    ];      

    // Intialise controls
    _controls = new Controls();

    // Start modals
    startModal();
  }

  function startModal() {
    var trueValue:Null<Int> = 0;

    for (levelBool in _levelSelect) {
      if (!levelBool) {
        trueValue++;
      }
    }    

    if (trueValue != null) {
      var modalTest:Array<String> = [
        "Welcome to the level select screen",
        "You have a pangolin. You have to deliver these to the mother to unlock the other levels",
        "Congratulations! You've completed all the levels"
      ];      
      var _modal:MainMenuModal = new MainMenuModal(modalTest[trueValue], null, true, "Press E to close");
      openSubState(_modal);      
    }
  }


  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    // Initial level pointer position
    _levelPointer.setPosition(_levelPos[_lastCompletedLevel].x, _levelPos[_lastCompletedLevel].y);

    if (_controls.cross.check()) {
      _sndSelect.play(); 

      // So that sound plays before action happens
      haxe.Timer.delay(() -> {
        _levelPos[_lastCompletedLevel].onSelect();
      }, 350);	      
    }
  
    if (_controls.right_jp.check()) {
      (_lastCompletedLevel == (_levelPos.length -1))
        ? _lastCompletedLevel = 0
        : _lastCompletedLevel++;
    }

    if (_controls.left_jp.check()) {
      (_lastCompletedLevel == 0) 
        ? _lastCompletedLevel = (_levelPos.length - 1)
        : _lastCompletedLevel--;
    }   

    if (_controls.left_jp.check() || _controls.right_jp.check()) _sndMove.play(true);

		// Paused game state
		if (_controls.start.check()) {
			_sndSelect.play();
			// SubState needs to be recreated here as it will be destroyed
			var _pauseMenu:PauseMenu = new PauseMenu(false, null, _gameSave);
			openSubState(_pauseMenu);
		}        
  }
}