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
  ?onSelect:Void -> Void,
  ?stars:Int
};

class LevelSelect extends GameState {
  var _grpLevelIndicators:FlxSpriteGroup;
	var _bottomLeft:FlxText;  
  var _controls:Controls;
  var _gameSave:FlxSave;
  var _grpLevelNames:FlxTypedGroup<FlxText>;
  var _grpLevelPadlocks:FlxSpriteGroup;
  var _grpLevelStars:FlxTypedGroup<FlxSprite>;
  var _lastSelected:Int = 0;
  var _levelPointer:FlxShapeCircle; //FlxSprite;
  var _mapBg:FlxSprite;
  var _modalNum:Null<Int>;
  var _playerHasPango:Bool = false;
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

    // Where to put the level selction pointer after leaving a certian level
    _pointerPosition = [
      "Level-1-0" => 0, 
      "Level-2-0" => 0,
      "Level-3-0" => 0,
      "Level-4-0" => 0,
      "Level-5-0" => 1,
      "Level-6-0" => 1,
      "Level-h-0" => 2	
    ]; 
  }

  override public function create() {
    super.create();
    FlxG.sound.playMusic("assets/music/level_select.ogg", 0.6, true);
    FlxG.sound.music.persist = false;
  
    _mapBg = new FlxSprite(0, 0).loadGraphic("assets/images/backgrounds/level_select.png", false, 1920, 1080);
    add(_mapBg);

    _grpLevelIndicators = new FlxSpriteGroup();
    _grpLevelPadlocks = new FlxSpriteGroup();
    _grpLevelNames = new FlxTypedGroup<FlxText>(); 
    _grpLevelStars = new FlxTypedGroup<FlxSprite>();   

    add(_grpLevelIndicators);
    add(_grpLevelPadlocks);
    add(_grpLevelNames);
    add(_grpLevelStars);

    final savedStars:Array<String> = _gameSave.data.levelStars.split("/");
    _levelPointer = new FlxShapeCircle(
        0, 
        0, 
        80, 			
        { thickness:10, color:Constants.secondaryColor }, 
			  Constants.slimeGreenColor);
    add(_levelPointer);

    _levelPos = [
      {
        x: 493,
        y: 563,
        name: "Level 1",
        locked: _playerHasPango,
        onSelect:() -> FlxG.switchState(new LevelOne(_gameSave)),
        stars: Std.parseInt(savedStars[0])
      },
      {
        x: 872,
        y: 563,
        name: "Level 2",
        locked: _playerHasPango,
        onSelect:() -> {
          (_gameSave.data.introTwoSeen)
          ? FlxG.switchState(new LevelFive(_gameSave))
          : FlxG.switchState(new LevelFive.IntroFive(_gameSave));
        },
        stars: Std.parseInt(savedStars[1])
      },
      {
        x: 1251,
        y: 563,
        name: "Home",
        locked: false,
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

      if (level.stars != null) {
        for (i in 0...level.stars) {
          var levelStar:FlxSprite = new FlxSprite(((level.x - 20) + i * 50), (level.y + 150));
          levelStar.loadGraphic("assets/images/icons/star_yellow.png", false, 100, 95);
          levelStar.scale.set(0.4, 0.4);
          _grpLevelStars.add(levelStar);
        }
      }
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
    final totalStarsCreate:Int = countStarTotal();
		_starsTotal = new FlxText((FlxG.width - 120), 70, 'x $totalStarsCreate');
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
        "Welcome to the level select screen.",
        "Congratulations! You've completed the game!! \nYou're free to go back and redo any level you want.",
        "Well done you have saved a pangolin!! Return it to it's mother by going to the 'HOME' level",
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

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    final levelPointerIsOn:LevelData = _levelPos[_lastSelected];
    // Initial level pointer position
    _levelPointer.setPosition(levelPointerIsOn.x, levelPointerIsOn.y);

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