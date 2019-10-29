package substates;

import flixel.addons.display.shapes.FlxShapeBox;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.FlxG;

// Typedefs
import Menu.MenuData;

class QuitMenu extends FlxSubState {
  var _boundingBox:FlxShapeBox;
	var _menuWidth:Int = 750;
	var _menuHeight:Int = 650;
  var _quitMenu:Menu;
	var _controls:Controls;

  /**
   * Menu specific to quiting
   */
  public function new() {
    super();
    var boxXPos:Float = (FlxG.width / 2) - (_menuWidth / 2);
		var quitMenuData:Array<MenuData> = [
			{
				title: "Yes",
				func: () -> {
						FlxG.switchState(new MainMenu());
					}
			},
			{
				title: "No",
				func: () -> { close(); }
			},			
		];    

		// Bounding box
		_boundingBox = new FlxShapeBox(
			boxXPos,
			(FlxG.height / 2) - (_menuHeight / 2),
			_menuWidth,
			_menuHeight - 50,
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor			
		);
    _boundingBox.scrollFactor.set(0, 0);
		add(_boundingBox);  

    // Quit menu
		_quitMenu = new Menu(boxXPos, 500, _menuWidth, quitMenuData, true);
    _quitMenu.scrollFactor.set(0, 0);
		add(_quitMenu);

    // Quit title
		var quitText:FlxText = new FlxText(boxXPos, 350, _menuWidth, "Are you sure you want to quit?");
		quitText.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, CENTER);
    quitText .scrollFactor.set(0, 0);
		add(quitText);

		// Intialise controls
		_controls = new Controls();    
  }

	override public function update(Elapsed:Float) {
		// Exit pause menu
		if (_controls.start.check()) close();
		super.update(Elapsed);
	}  
}