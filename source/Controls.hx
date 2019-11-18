package;

import flixel.input.actions.FlxAction.FlxActionDigital;

class Controls {
  public var cross:FlxActionDigital;
  public var triangle:FlxActionDigital;

  public var left:FlxActionDigital;
  public var right:FlxActionDigital;
  public var up:FlxActionDigital;
  public var down:FlxActionDigital;

  public var start:FlxActionDigital;

  /**
   * Sets up all the player controls in the game.
   *
   * @param InMenu if the controls are in the menu or not
   */
  public function new() {
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
    start = new FlxActionDigital(); 
  }

  function addKeys() {
    cross.addKey(SPACE, JUST_PRESSED);
    cross.addKey(ENTER, JUST_PRESSED);
  
    triangle.addKey(E, JUST_PRESSED); 

    left.addKey(LEFT, PRESSED);
    left.addKey(A, PRESSED);

    right.addKey(RIGHT, PRESSED);
    right.addKey(D, PRESSED); 

    up.addKey(UP, PRESSED);
    up.addKey(W, PRESSED); 

    down.addKey(DOWN, PRESSED);
    down.addKey(S, PRESSED);    
  
    start.addKey(ESCAPE, JUST_PRESSED);  
  }

  function addGamepad() {
    cross.addGamepad(A, JUST_PRESSED);
    triangle.addGamepad(Y, JUST_PRESSED);

    left.addGamepad(DPAD_LEFT, PRESSED);
    left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);

    right.addGamepad(DPAD_RIGHT, PRESSED);
    right.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED);  

    up.addGamepad(DPAD_UP, PRESSED);
    up.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED);  

    down.addGamepad(DPAD_DOWN, PRESSED);
    down.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED);          

    start.addGamepad(START, JUST_PRESSED);
  }
}

