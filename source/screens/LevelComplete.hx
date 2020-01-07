package screens;


import haxe.ds.Either;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.text.FlxText;
import flixel.FlxSubState;

// Typedefs
import Menu.MenuData;


class LevelComplete extends FlxSubState {
  var _title:FlxText;
  var _levelData:FlxText;
  var _menu:Menu;
  var _gameSave:FlxSave;
  var _grpLeftSide:FlxSpriteGroup;
  var _rightSide:FlxSprite;
  var _leftBg:FlxSprite;
  var _grpStars:FlxTypedGroup<FlxSprite>;

  var _bugsCollected:Int = 0;
  var _enemiesDefeated:Int = 0;

  var _levelTotals:Map<String, Array<Int>>; 
  var _levelNames:Map<String, Array<Dynamic>>; // Array<Either<String, Int>>>
  var _totalBugsCollected:Int;
  var _totalEnemiesDefeated:Int;
  var _levelSelectModalNum:Int;
  // - Stars
  var _levelStars:Int = 0;
  var _animateStarCount:Int = 0;
  var _starSoundPlayed:Bool = false;
  // - Level names
  final levelOneEnd:String = "Level-4-0";
  final levelTwoEnd:String = "Level-6-0";
  // Variables for showing bugs collected/enemites defeated after checking if they are more than the total
  var _actualBugs:Int;
  var _actualEnemies:Int;


  /**
   * @param GameSave saved game data
   * @param LevelSelectModalNum modal to have selected on the level complete page
   */
  public function new(?GameSave:FlxSave, ?LevelSelectModalNum:Int) {
    super();
    _gameSave = GameSave;
    _levelSelectModalNum = LevelSelectModalNum;

    _levelTotals = [
      levelOneEnd => [74, 10],
      levelTwoEnd => [42, 10]
    ];

    _levelNames = [
      levelOneEnd => ["One", 1],
      levelTwoEnd => ["Two", 2]
    ];   

    _totalBugsCollected = _levelTotals[_gameSave.data.levelName][0];
    _totalEnemiesDefeated = _levelTotals[_gameSave.data.levelName][1];

    _actualBugs = showTotalIfCollectedIsHigher(_totalBugsCollected, _gameSave.data.totalBugs);
    _actualEnemies = showTotalIfCollectedIsHigher(_totalEnemiesDefeated, _gameSave.data.totalEnemies);
  }

  /**
   * Sort of hacky way to fix a bug where the collected number is over the total.
   *
   * @param Total level total
   * @param Collected amount player has collected
   */
  function showTotalIfCollectedIsHigher(Total:Int, Collected:Int):Int {
    return Collected > Total
      ? Total
      : Collected;
  }

  function calculatePercentge():Int {
    var total = _totalBugsCollected + _totalEnemiesDefeated;
    var value = _actualBugs + _actualEnemies;

    return Std.int(value / total * 100);
  }

  override public function create() {
    var levelToRestart:Class<states.LevelState> = Helpers.restartLevel(_gameSave.data.levelName);

    // This needs to be before _menuData so that it gets the correct _levelStars value
    _grpStars = new FlxTypedGroup<FlxSprite>();    
    var levelPercentage:Int = calculatePercentge();
    createStars(levelPercentage);

    // Spaces before menu items is for menu pointer spacing
    var _menuData:Array<MenuData> = [
      {
        title: "  Continue",
        func: () -> {
          saveLevelStars();
          FlxG.switchState(new levels.LevelSelect(_gameSave, _levelSelectModalNum));
        }
      },
      {
        title: "  Restart Level",
         func: () -> FlxG.switchState(Type.createInstance(levelToRestart, [_gameSave, false]))
      },    
      {
        title: "  Main Menu",
        func: () -> FlxG.switchState(new MainMenu())
      }
    ];

    var twoThirdsScreen:Int = Std.int((FlxG.width / 3) * 2);
    var distanceOffScreen:Int = 300;

    // Left side of level complete screen
    _grpLeftSide = new FlxSpriteGroup(0, -distanceOffScreen);
    add(_grpLeftSide);

    _leftBg = new FlxSprite(0, 0).makeGraphic(twoThirdsScreen, FlxG.height, Constants.primaryColor);
    _grpLeftSide.add(_leftBg);

    var levelTitle:String = _levelNames[_gameSave.data.levelName][0];

    _title = new FlxText(100, 70, FlxG.width, 'Level $levelTitle Complete!!');
    _title.setFormat(Constants.squareFont, Constants.medFont * 3, FlxColor.WHITE, LEFT);
    _grpLeftSide.add(_title);

    _levelData = new FlxText(80, 230, FlxG.width);
    _levelData.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, LEFT);
    _grpLeftSide.add(_levelData);

    _grpLeftSide.alpha = 0;
    _grpLeftSide.forEach((_member:FlxSprite) -> {
      _member.scrollFactor.set(0, 0);
    });	 

    add(_grpStars);

    // Right side of level complete screen
    _rightSide = new FlxSprite(twoThirdsScreen, distanceOffScreen);
    _rightSide.loadGraphic("assets/images/level_comp/left_img.jpg", false, 640, FlxG.height);
    _rightSide.scrollFactor.set(0, 0);
    _rightSide.alpha = 0;
    add(_rightSide);

    _menu = new Menu(100, FlxG.height - 250, 350, _menuData, false);
    _menu.scrollFactor.set(0, 0);
    _menu.alpha = 0;
    _menu.exists = false;
    add(_menu);

    // Stop level music
    FlxG.sound.music.stop();

    // Play level complete music
    final levelNameLowercase:String = _levelNames[_gameSave.data.levelName][0].toLowerCase();
    final introMusic:String = 'assets/music/level-$levelNameLowercase-complete.ogg';
    FlxG.sound.playMusic(introMusic, 1, false);		
  }

  /**
   * Simply increments the numbers by one for animation reasons by a loop.
   * Pauses for 800ms inbetween increments.
   *
   * @param TotalBugs number of bugs collected from saved data.
   * @param TotalEnemies number of enemies defeated from saved data.
   */
  function incrementNumbers(TotalBugs:Int, TotalEnemies:Int) {
    haxe.Timer.delay(() -> {
      if (_bugsCollected != TotalBugs) _bugsCollected = Std.int(_bugsCollected % 360 + 1);
      if (_enemiesDefeated != TotalEnemies) _enemiesDefeated = Std.int(_enemiesDefeated % 360 + 1);
    }, 800);
  }

  /**
   * Render amount of stars out of three based on percentage value
   */
  function createStars(Percentage:Int) {
    if (Percentage > 40 && Percentage <= 70) _levelStars = 1;
    if (Percentage > 70 && Percentage <= 100) _levelStars = 2;

    // there should ONLY be three stars
    for (i in 0...3) {
      final spacing:Int = (120 * i) + (10 * i);
      var star:FlxSprite = new FlxSprite((120 + spacing), 500);
      var starType:String = "black";
      if (i <= (_levelStars - 1)) starType = "yellow";
      star.loadGraphic('assets/images/icons/star_$starType.png', false, 100, 95);
      star.scrollFactor.set(0, 0);
      star.alpha = 0;
      // Add star to group
      _grpStars.add(star);
    }
  }

  /**
   * Animate the stars coming in one by one and play the relvat sound.
   * Tehcnically all stars play at the samd time but animate at different speeds.
   */
  function animateStars() {
    _grpStars.forEach((Member:FlxSprite) -> {
      haxe.Timer.delay(
        () -> {
          if (!_starSoundPlayed) {
            final soundToPlay:Int = _levelStars + 1; 
            final starSound:FlxSound = FlxG.sound.load('assets/sounds/sfx/stars_$soundToPlay.ogg', 0.7);
            starSound.play();
            _starSoundPlayed = true; // To prevent repeated play
          }            
          FlxTween.tween(Member, {alpha: 1, y: 470}, 1, {ease: FlxEase.backOut});       
        }, 
        Std.int((_animateStarCount * 0.50) * 1000));
      if (_animateStarCount != _levelStars) _animateStarCount++;
    }); 
  }

  /**
   * Method used to save stars from level to game save data.
   */
  function saveLevelStars() {
    var savedGameStars:Null<String> = _gameSave.data.levelStars;
    final levelNumber:Int = _levelNames[_gameSave.data.levelName][1];

    if (savedGameStars == null) _gameSave.data.levelStars = "0/0/0/0/0";

    final savedStars:Array<String> = _gameSave.data.levelStars.split("/");
    savedStars[levelNumber - 1] = Std.string(_levelStars);
    _gameSave.data.levelStars = savedStars.join("/");  
    // Remove this when testing is done
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    incrementNumbers(_actualBugs, _actualEnemies);
    _levelData.text = '
    Bugs collected: $_bugsCollected/$_totalBugsCollected \n
    Enemies defeated: $_enemiesDefeated/$_totalEnemiesDefeated';

    // Animate sides
    FlxTween.tween(_grpLeftSide, {y: 0, alpha: 1}, 1, {ease: FlxEase.backOut});
    FlxTween.tween(_rightSide, {y: 0, alpha: 1}, 1, {ease: FlxEase.backOut});

    // Show level rating
    haxe.Timer.delay(() -> animateStars(), 2000);

  // Show menu after a few seconds
    haxe.Timer.delay(() -> { 
      _menu.exists = true;
      _menu.fadeIn();
    }, 3200);
  }
}