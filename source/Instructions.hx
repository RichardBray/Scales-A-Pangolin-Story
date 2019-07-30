package;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxG;

class Instructions extends FlxSubState {
  var _gameOverlay:FlxSprite;
  var _controls:Controls;
  var _grpPages:FlxSpriteGroup;
  var _currentPage:Int = 1;
  var _startPage:Int;
  var _endPage:Int;  
  var _closeText:FlxText;
  
  public var menuViewed:Bool; // Used in specific level classes to check if instructions have been viewed

  /**
   * Shows game instructions at the start of a level
   *
   * @param StartPage   Page instrcutions should start on
   * @param Endpage     Page instrcutions should end on
   * @param ShowOverlay To show background overlay or not, helpful when coming from pause menu
   */
  public function new(StartPage:Int, EndPage:Int, ShowOverlay:Bool = true) {
    super();

    // Assign start and end pages numbers
    _endPage = EndPage;
    _startPage = StartPage;

    // Opaque black background overlay
    if (ShowOverlay) {
      _gameOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x9c000000);
      _gameOverlay.scrollFactor.set(0, 0);
      add(_gameOverlay);
    }

    // Init pages group
    _grpPages = new FlxSpriteGroup();
    add(_grpPages);

    // Create pages, hides all the pages that aren't currently selected    
    for (i in StartPage...(EndPage + 1)) {
      var _page = new FlxSprite(160, 90).loadGraphic('assets/images/instructions/page$i.png', false, 1600, 900);
      if (i != _currentPage) _page.alpha = 0;
      _grpPages.add(_page);
    }

    // Show instructions controls
    

    // next prev flxtext
  
		// Intialise game controls
		_controls = new Controls();  

		// Fix all pages to a certain position on the screen
		_grpPages.forEach((Page:FlxSprite) -> {
			Page.scrollFactor.set(0, 0);
		});      
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);    

		// Exit instructions
		if (_controls.start.check() || _controls.triangle.check()) closeInstructionsMenu();

    // Go to previous page
    if (_controls.left.check() && _currentPage != _startPage) {
      _currentPage--;
      trace("left pressed");
      updateShownPage();
    } 

    // Go to next page
    if (_controls.right.check() && _currentPage != _endPage) {
      _currentPage++;
      trace("right pressed");
      updateShownPage();
    }       
  }

  /**
   * Add `alpha = 0` to pages that arent current and add `alpha = 1` to current page
   */
  function updateShownPage() {
    var index:Int = 1;
		_grpPages.forEach((Page:FlxSprite) -> {
			if (index == _currentPage) {
        Page.alpha = 1;
      } else {
        Page.alpha = 0;
      }
      index++;
		});     
  }
  
  /**
   * Close subState
   */
	function closeInstructionsMenu() {
		FlxG.sound.music.play();
    menuViewed = true;
    // @todo play sound
		close();
	}  
}