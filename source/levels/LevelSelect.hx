package levels;

import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.FlxSave;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.shapes.FlxShapeCircle;

import levels.LevelFive.IntroFive;
import states.GameState;


using Lambda;

typedef LevelData = {
  x:Int,
  y:Int,
  name:String,
  locked:Bool,
  ?onSelect:Void -> Void
};

class LevelSelect extends GameState {
  var _grpLevelIndicators:FlxSpriteGroup;
  var _controls:Controls;
  var _levelPointer:FlxShapeCircle; //FlxSprite;
  var _gameSave:FlxSave;
  var _mapBg:FlxSprite;
  var _grpLevelNames:FlxTypedGroup<FlxText>;
  var _grpLevelPadlocks:FlxSpriteGroup;
	var _bottomLeft:FlxText;  
  var _modalNum:Null<Int>;
  var _pointerPosition:Map<String, Int>; // Where to put pointer when level loads  

	// Sounds
	var _sndMove:FlxSound;
	var _sndSelect:FlxSound;

  // Remove after save game is added START
  var _lastCompletedLevel:Int = 0;
  var _savedLevelData:Dynamic = [
    {
      locked: false,
      stars: 3
    }
  ];  

  var _levelPos:Array<LevelData>;
  // Remove after save game is added END

  public function new(?GameSave:FlxSave, ?ModalNum:Int) {
    super();
    if (GameSave != null) {
      _gameSave = GameSave;
      _gameSave.data.enableLevelSelect = true;
      _gameSave.flush();
    }
    if (ModalNum != null) _modalNum = ModalNum; 

    _pointerPosition = [
      "Level-1-0" => 0, 
      "Level-2-0" => 0,
      "Level-3-0" => 0,
      "Level-4-0" => 0,
      "Level-5-0" => 1,
      "Level-6-0" => 1,
      "Level-h-0" => 5	
    ]; 
    
  }

  override public function create() {
    super.create();
    FlxG.sound.playMusic("assets/music/level_select.ogg", 0.6, true);
    FlxG.sound.music.persist = false;
  
    _mapBg = new FlxSprite(0, 0).loadGraphic("assets/images/backgrounds/test_map.jpg", false, 1920, 1080);
    add(_mapBg);

    _grpLevelIndicators = new FlxSpriteGroup();
    _grpLevelPadlocks = new FlxSpriteGroup();
    _grpLevelNames = new FlxTypedGroup<FlxText>();    

    add(_grpLevelIndicators);
    add(_grpLevelPadlocks);
    add(_grpLevelNames);

    _levelPointer = new FlxShapeCircle(
        0, 
        0, 
        80, 			
        { thickness:10, color:Constants.secondaryColor }, 
			  Constants.primaryColor);
    add(_levelPointer);

    _levelPos = [
      {
        x: 230,
        y: 544,
        name: "Level 1",
        locked:false,
        onSelect:() -> FlxG.switchState(new LevelOne(_gameSave))
      },
      {
        x: 118,
        y: 114,
        name: "Level 2",
        locked:false,
        onSelect:() -> {
          (_gameSave.data.introTwoSeen)
          ? FlxG.switchState(new LevelFive(_gameSave))
          : FlxG.switchState(new LevelFive.IntroFive(_gameSave));
        }
      },
      {
        x: 594,
        y: 207,
        name: "Level 3",
        locked:true,
        onSelect:() -> trace("level three")
      },
      {
        x: 1251,
        y: 567,
        name: "Level 4",
        locked:true,
        onSelect:() -> trace("level four")
      },
      {
        x: 1561,
        y: 307,
        name: "Level 5",
        locked:true,
        onSelect:() -> trace("level five")
      },
      {
        x: 1610,
        y: 778,
        name: "Home",
        locked:false, // lock this FORDEMO
        onSelect:() -> FlxG.switchState(new LevelHome(_gameSave))
      }                     
    ];  

    _levelPos.mapi((idx:Int, level:LevelData) -> {
      // Level circle shape
      var levelIndicator:FlxShapeCircle = new FlxShapeCircle(
        level.x, 
        level.y, 
        80, 			
        { thickness:6, color:FlxColor.WHITE }, 
			  FlxColor.TRANSPARENT);
      levelIndicator.scrollFactor.set(0, 0);
      // Add data from save
      _grpLevelIndicators.add(levelIndicator); 

      // Level text 
      var levelName:FlxText = new FlxText(
        level.x, 
        (level.y - 50), 
        150, 
        level.name
      );
      levelName.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, CENTER);
      _grpLevelNames.add(levelName); 

      // Level padlocks
      // once saved data is in ternary line will be _savedLevelData[idx].locked
      final padImgWidth:Int = 30;
      final padImgHeight:Int = 42; 
      var levelPadlock:FlxSprite = new FlxSprite(
        level.x + (_levelPointer.width / 2) - (padImgWidth / 2), 
        level.y + (_levelPointer.height / 2) - (padImgHeight / 2)).loadGraphic(
          "assets/images/icons/padlock.png", false, padImgWidth, padImgHeight);
      levelPadlock.alpha = level.locked ? 1 : 0;
      _grpLevelPadlocks.add(levelPadlock);
    });        

		_bottomLeft = new Menu.BottomLeft();
		add(_bottomLeft);

		//Sounds
		_sndMove = FlxG.sound.load(Constants.sndMenuMove);
		_sndSelect = FlxG.sound.load(Constants.sndMenuSelect);   
    
    // Intialise controls
    _controls = new Controls();

    // Start modals
    startModal();

    // Set pointer position
    _lastCompletedLevel = _pointerPosition[_gameSave.data.levelName];
  }

  function startModal() {
    if (_modalNum != null) {
      var modalText:Array<String> = [
        "Welcome to the level select screen. Here you will be able to freely roam the jungle and pick whatever level you want.",
        "You have a pangolin. You have to deliver these to the mother to unlock the other levels",
        "Congratulations! You've completed all the levels",
        "You have saved a pangolin. Return it to it's mother by going to the HOME level",
        "Congratulations! you've finished the demo for Scales: A Pangolin Story \n
         The full game will be out very soon."
      ];    
      var jump:String = Constants.cross;  
      var _modal:MainMenuModal = new MainMenuModal(modalText[_modalNum], null, true, 'Press $jump to close', true);
      openSubState(_modal);   
    }   
  }

  /**
   * Specific controls for certain level positions.
   */
  function specificControls() {
    if (_lastCompletedLevel == 0 && _controls.up.check()) {
      _lastCompletedLevel = 1;
    }

    if (_lastCompletedLevel == 1 && _controls.down.check()) {
      _lastCompletedLevel = 0;
    }  

    if (_lastCompletedLevel == 4 && _controls.down.check()) {
      _lastCompletedLevel = 5;
    }   
  
    if (_lastCompletedLevel == 5 && _controls.up.check()) {
      _lastCompletedLevel = 4;
    }   
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    // Initial level pointer position
    _levelPointer.setPosition(_levelPos[_lastCompletedLevel].x, _levelPos[_lastCompletedLevel].y);

    specificControls();

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

    if (
      _controls.left_jp.check() || 
      _controls.right_jp.check() ||
      _controls.up.check() ||
      _controls.down.check()
    ) _sndMove.play(true);

		// Paused game state
		if (_controls.start.check()) {
			_sndSelect.play();
			// SubState needs to be recreated here as it will be destroyed
			var _pauseMenu:PauseMenu = new PauseMenu(false, null, _gameSave);
			openSubState(_pauseMenu);
		}        
  }
}