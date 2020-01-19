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
  var _playerHasPango:Bool = false;
  var _lastSelected:Int = 0;
  var _pointerPosition:Map<String, Int>; // Where to put pointer when level loads  
  // - Total Stars
  var _starSprt:FlxSprite;
  var _starsTotal:FlxText;

	// Sounds
	var _sndMove:FlxSound;
	var _sndSelect:FlxSound;
  var _levelPos:Array<LevelData>;
  // Remove after save game is added END

  public function new(?GameSave:FlxSave, ?ModalNum:Int) {
    super();
    if (GameSave != null) {
      _gameSave = GameSave;
      _gameSave.data.enableLevelSelect = true;
      _gameSave.flush();
      _playerHasPango = _gameSave.data.playerHasPango != null; // The value from saved game could be null
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
        locked: _playerHasPango,
        onSelect:() -> FlxG.switchState(new LevelOne(_gameSave))
      },
      {
        x: 118,
        y: 114,
        name: "Level 2",
        locked: _playerHasPango,
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
        locked: true,
        onSelect:() -> trace("level three")
      },
      {
        x: 1251,
        y: 567,
        name: "Level 4",
        locked: true,
        onSelect:() -> trace("level four")
      },
      {
        x: 1561,
        y: 307,
        name: "Level 5",
        locked: true,
        onSelect:() -> trace("level five")
      },
      {
        x: 1610,
        y: 778,
        name: "Home",
        locked: false, // lock this FOR DEMO
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

    // Stars Sprint
		_starSprt = new FlxSprite((FlxG.width - 250), 40);
    _starSprt.loadGraphic("assets/images/icons/star_yellow.png", false, 100, 95);
		add(_starSprt);

		// Stars Total
    final totalStars = countStarTotal();
		_starsTotal = new FlxText((FlxG.width - 120), 70, 'x $totalStars');
		_starsTotal.setFormat(Constants.squareFont, Constants.lrgFont, FlxColor.WHITE);
		_starsTotal.scrollFactor.set(0, 0);
    add(_starsTotal);
    
		_bottomLeft = new Menu.BottomLeft();
    add(_bottomLeft);

		//Sounds
		_sndMove = FlxG.sound.load(Constants.sndMenuMove);
		_sndSelect = FlxG.sound.load(Constants.sndMenuSelect);   
    
    checkPlayerWithPangoFinishedLevel();
      
    // Intialise controls
    _controls = new Controls();

    // Start modals
    startModal();

    // Set pointer position
    _lastSelected = _pointerPosition[_gameSave.data.levelName];
  }

  /**
   * Count total stars.
   */
  function countStarTotal():Int {
    var totalStars:Int = 0;
    final stars:Array<String> = _gameSave.data.levelStars.split("/");
    for (star in stars) {
			totalStars = totalStars + Std.parseInt(star);
    }
		return totalStars;
  }

  function startModal() {
    if (_modalNum != null) {
      var modalText:Array<String> = [
        "Welcome to the level select screen. Here you will be able select newly unlocked levels and replay completed ones.",
        "You have a pangolin. You have to deliver these to the mother to unlock the other levels",
        "Congratulations! You've completed all the levels",
        "Well done you have saved a pangolin!! Return it to it's mother by going to the 'HOME' level",
        "Congratulations! you've finished the demo for Scales: A Pangolin Story \n
         The full game will be out very soon."
      ];    
      var jump:String = Constants.cross;  
      var _modal:MainMenuModal = new MainMenuModal(modalText[_modalNum], null, true, 'Press $jump to close', true);
      openSubState(_modal);   
    }   
  }

  /**
   * Method to make sure player that has saved a pangolin finished the level before they get to this screen.
   */
  function checkPlayerWithPangoFinishedLevel() {
    if (_gameSave.data.playerHasPango != null) {
      final savedStars:Array<String> = _gameSave.data.levelStars.split("/");
      switch(_gameSave.data.playerHasPango) {
        case "purple":
          if (savedStars[1] == "0") _gameSave.data.playerHasPango = null;
      }
    }
  }

  /**
   * Specific controls for certain level positions.
   */
  function specificControls() {
    if (_lastSelected == 0 && _controls.up.check()) {
      _lastSelected = 1;
    }

    if (_lastSelected == 1 && _controls.down.check()) {
      _lastSelected = 0;
    }  

    if (_lastSelected == 4 && _controls.down.check()) {
      _lastSelected = 5;
    }   
  
    if (_lastSelected == 5 && _controls.up.check()) {
      _lastSelected = 4;
    }   
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    final levelPointerIsOn:LevelData = _levelPos[_lastSelected];
    // Initial level pointer position
    _levelPointer.setPosition(levelPointerIsOn.x, levelPointerIsOn.y);

    specificControls();

    if (_controls.cross.check()) {
      _sndSelect.play(); 

      // So that sound plays before action happens
      haxe.Timer.delay(() -> {
        if (!levelPointerIsOn.locked) levelPointerIsOn.onSelect();
      }, 350);	      
    }
  
    if (_controls.right_jp.check()) {
      (_lastSelected == (_levelPos.length -1))
        ? _lastSelected = 0
        : _lastSelected++;
    }

    if (_controls.left_jp.check()) {
      (_lastSelected == 0) 
        ? _lastSelected = (_levelPos.length - 1)
        : _lastSelected--;
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