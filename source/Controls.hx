package;

import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.FlxG;

class Controls {
  var _actionManager:FlxActionManager;
  var _inMenu:Bool;

  public var cross:FlxActionDigital;
  public var triangle:FlxActionDigital;

  public var left:FlxActionDigital;
  public var right:FlxActionDigital;
  public var up:FlxActionDigital;
  public var down:FlxActionDigital;


  public var start:FlxActionDigital;

  /**
   * Sets up all the controls in the game.
   *
   * @param InMenu Keyboard controls are different if the player is in a menu.
   */
  public function new(?InMenu:Bool = false):Void {
    initInputs();
    addKeys();
    addGamepad();
  }

  function initInputs() {
    cross = new FlxActionDigital();
    triangle = new FlxActionDigital();
    left = new FlxActionDigital();
    right = new FlxActionDigital();
    up = new FlxActionDigital();
    down = new FlxActionDigital();

    _actionManager = new FlxActionManager();
    FlxG.inputs.add(_actionManager);    
    _actionManager.addActions([cross, triangle, left, right, up, down]);    
  }

  function addKeys() {
    cross.addKey(SPACE, JUST_PRESSED);
    cross.addKey(W, JUST_PRESSED);
    cross.addKey(UP, JUST_PRESSED);

    if (_inMenu) {
      triangle.addKey(ESCAPE, JUST_PRESSED); 
      start.addKey(SPACE, JUST_PRESSED); 
      start.addKey(ENTER, JUST_PRESSED); 
    } else {
      triangle.addKey(E, JUST_PRESSED); 
    }

    left.addKey(LEFT, PRESSED);
    left.addKey(A, PRESSED);

    right.addKey(RIGHT, PRESSED);
    right.addKey(D, PRESSED); 
  }

  function addGamepad() {
    cross.addGamepad(A, JUST_PRESSED);
    triangle.addGamepad(Y, JUST_PRESSED); 

    left.addGamepad(DPAD_LEFT, PRESSED);
    left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);

    right.addGamepad(DPAD_RIGHT, PRESSED);
    right.addGamepad(RIGHT_STICK_DIGITAL_LEFT, PRESSED);   
  }
}
