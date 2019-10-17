package screens;


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

  var _bugsCollected:Int = 0;
  var _enemiesKilled:Int = 0;

  var _levelRating:FlxText;

  var _levelTotals:Map<String, Array<Int>>; 
  var _levelNames:Map<String, String>;
  var _totalBugsCollected:Int;
  var _totalEnemiesKilled:Int;

  public function new(?GameSave:FlxSave) {
    super();
    _gameSave = GameSave;

    _levelTotals = [
      "Level-4-0" => [74, 9] // [74, 10]
    ];

    _levelNames = [
      "Level-4-0" => "One"
    ];

    _totalBugsCollected = _levelTotals[_gameSave.data.levelName][0];
    _totalEnemiesKilled = _levelTotals[_gameSave.data.levelName][1];
  }

  function calculatePercentge():Int {
    var total = _totalBugsCollected + _totalEnemiesKilled;
    var value = _gameSave.data.totalBugs + _gameSave.data.totalEnemies;

    return Std.int(value / total * 100);
  }
  override public function create() {
    var levelToRestart:Class<states.LevelState> = Helpers.restartLevel(_gameSave.data.levelName);
    // Spaces before menu items is for menu pointer spacing
    var _menuData:Array<MenuData> = [
      {
        title: "  End Demo", // Continue
        func: () -> FlxG.switchState(new MainMenu())
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

    var levelTitle:String = _levelNames[_gameSave.data.levelName];

    _title = new FlxText(100, 70, FlxG.width, 'Level $levelTitle Complete!!');
    _title.setFormat(Constants.squareFont, Constants.medFont * 3, null, LEFT);
    _grpLeftSide.add(_title);

    _levelData = new FlxText(80, 230, FlxG.width);
    _levelData.setFormat(Constants.squareFont, Constants.medFont, null, LEFT);
    _grpLeftSide.add(_levelData);

    _grpLeftSide.alpha = 0;
    _grpLeftSide.forEach((_member:FlxSprite) -> {
      _member.scrollFactor.set(0, 0);
    });	 

    var levelPercentage:Int = calculatePercentge();
    _levelRating = new FlxText(120, 500, FlxG.width, '$levelPercentage% Complete'); 
    _levelRating.setFormat(Constants.squareFont, Constants.medFont * 2, null, LEFT);
    _levelRating.alpha = 0;  
    _levelRating.scrollFactor.set(0, 0);
    add(_levelRating);

    // Right side of level complete screen
    _rightSide = new FlxSprite(twoThirdsScreen, distanceOffScreen);
    _rightSide.loadGraphic("assets/images/level_comp/left_img.jpg", false, 640, FlxG.height);
    _rightSide.scrollFactor.set(0, 0);
    _rightSide.alpha = 0;
    add(_rightSide);

    _menu = new Menu(100, FlxG.height - 250, 350, _menuData, false);
    _menu.scrollFactor.set(0, 0);
    _menu.alpha = 0;
    add(_menu);
  }

  function incrementNumbers(TotalBugs:Int, TotalEnemies:Int) {
    // Increment numbers after 800ms
    haxe.Timer.delay(() -> {
      if (_bugsCollected != TotalBugs) _bugsCollected = Std.int(_bugsCollected % 360 + 1);
      if (_enemiesKilled != TotalEnemies) _enemiesKilled = Std.int(_enemiesKilled % 360 + 1);
    }, 800);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    incrementNumbers(_gameSave.data.totalBugs, _gameSave.data.totalEnemies);
    _levelData.text = '
    Bugs collected: $_bugsCollected/$_totalBugsCollected \n
    Enemies killed: $_enemiesKilled/$_totalEnemiesKilled';

    // Animate sides
    FlxTween.tween(_grpLeftSide, {y: 0, alpha: 1}, 1, {ease: FlxEase.backOut});
    FlxTween.tween(_rightSide, {y: 0, alpha: 1}, 1, {ease: FlxEase.backOut});

    // Show level rating
    haxe.Timer.delay(() -> { 
      FlxTween.tween(_levelRating, {alpha: 1, y: 470}, 1, {ease: FlxEase.backOut});
    }, 2000);

    // Show menu after a few seconds
      haxe.Timer.delay(() -> { _menu.fadeIn();}, 3200);
  }
}