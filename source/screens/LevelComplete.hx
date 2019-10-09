package screens;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.text.FlxText;
import flixel.FlxState;

// Typedefs
import Menu.MenuData;

class LevelComplete extends FlxState {
  var _title:FlxText;
  var _levelData:FlxText;
  var _menu:Menu;
  var _gameSave:FlxSave;

  public function new(?GameSave:FlxSave) {
    super();

    _gameSave = GameSave;
  }

 override public function create() {

		var _menuData:Array<MenuData> = [
			{
				title: "Continue",
				func: () -> {}
			},
			{
				title: "Quit",
				func: () -> FlxG.switchState(new MainMenu())
			}
		];

    _title = new FlxText(0, 100, FlxG.width, "Level one Complete!");
    _title.setFormat(Constants.squareFont, Constants.lrgFont, null, CENTER);
    add(_title);

    _levelData = new FlxText(0, 250, FlxG.width, "
      Bugs collected: 0/50 \n
      Enemies killsed: 0/50 \n
      Rating: C"
    );
    _levelData.setFormat(Constants.squareFont, Constants.medFont, null, CENTER);
    add(_levelData);

    _menu = new Menu((FlxG.width / 2) - 150, FlxG.height - 200, 300, _menuData, true);
    add(_menu);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  }
}