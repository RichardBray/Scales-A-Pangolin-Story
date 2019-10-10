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
  var _startPage:Int;
  var _endPage:Int;  
  var _totalPages:Int;
  var _closeText:FlxText;
  var _pagePosition:FlxText;
  // Page controls
  var _currentPage:Int = 1;
  var _leftArrow:FlxSprite;
  var _rightArrow:FlxSprite;
  var _exitText:FlxText;
  
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
      var widthApart:Int = 80; // Pixel size gap for left and right
      var heightApart:Int = 45;
      var _page = new FlxSprite(widthApart*2, heightApart*2);
      _page.loadGraphic('assets/images/instructions/page$i.png', false, 1600, 900);
      if (i != _currentPage) _page.alpha = 0;
      _grpPages.add(_page);
    }

    // Exit test
    var start:String = Constants.start;
    _exitText = new FlxText(1480, 120, 'Press $start to Exit');
    _exitText.setFormat(Constants.squareFont, Constants.smlFont);
    _exitText.scrollFactor.set(0, 0);
    add(_exitText);

    // Show instructions controls
    _totalPages = (EndPage + 1) - StartPage;
    _pagePosition = new FlxText(0, 925, 100, '$_currentPage/$_totalPages');
    _pagePosition.setFormat(Constants.squareFont, Constants.smlFont);
    _pagePosition.scrollFactor.set(0, 0);
    _pagePosition.screenCenter(X);
    add(_pagePosition);

    // Left arrow
    _leftArrow = new FlxSprite(190, 925).loadGraphic("assets/images/instructions/arrow.png", false, 18, 34);
    _grpPages.add(_leftArrow);

    // Right arrow
    _rightArrow = new FlxSprite(1702, 925).loadGraphic("assets/images/instructions/arrow.png", false, 18, 34);
    _rightArrow.flipX = true;
    _grpPages.add(_rightArrow);    


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
      updateShownPage();
    } 

    // Go to next page
    if (_controls.right.check() && _currentPage != _endPage) {
      _currentPage++;
      updateShownPage();
    }  

    // Change opacity of arrows based on if user is on first or last page
    if (_controls.left.check() || _controls.right.check()) {
      _leftArrow.alpha = 1;
      _rightArrow.alpha = 1;

      if (_currentPage == _endPage) _rightArrow.alpha = 0.2;
      if (_currentPage == _startPage) _leftArrow.alpha = 0.2;
    }     
  }

  /**
   * Add `alpha = 0` to pages that arent current and add `alpha = 1` to current page.
   * This also updates the page position at the bottom.
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
    _pagePosition.text = '$_currentPage/$_totalPages';  
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