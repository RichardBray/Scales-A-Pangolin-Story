package;

import flixel.input.actions.FlxAction.FlxActionDigital;

class Controls {
  public var cross:FlxActionDigital;
  public var cross_jr:FlxActionDigital; // Created to fix issue with main menu with controller
  public var triangle:FlxActionDigital;

  public var left:FlxActionDigital;
  public var left_jp:FlxActionDigital;
  public var right:FlxActionDigital;
  public var right_jp:FlxActionDigital;
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
    cross_jr = new FlxActionDigital();
    triangle = new FlxActionDigital();  
    left = new FlxActionDigital();
    left_jp = new FlxActionDigital();
    right = new FlxActionDigital();
    right_jp = new FlxActionDigital();
    up = new FlxActionDigital();
    down = new FlxActionDigital();
    start = new FlxActionDigital(); 
  }

  function addKeys() {
    cross.addKey(SPACE, JUST_PRESSED);
    cross.addKey(ENTER, JUST_PRESSED);

    cross_jr.addKey(SPACE, JUST_RELEASED);
    cross_jr.addKey(ENTER, JUST_RELEASED);
  
    triangle.addKey(E, JUST_PRESSED); 

    left_jp.addKey(LEFT, JUST_PRESSED);
    left_jp.addKey(A, JUST_PRESSED);

    left.addKey(LEFT, PRESSED);
    left.addKey(A, PRESSED);    

    right_jp.addKey(RIGHT, JUST_PRESSED);
    right_jp.addKey(D, JUST_PRESSED);

    right.addKey(RIGHT, PRESSED);
    right.addKey(D, PRESSED);     

    up.addKey(UP, JUST_PRESSED);
    up.addKey(W, JUST_PRESSED); 

    down.addKey(DOWN, JUST_PRESSED);
    down.addKey(S, JUST_PRESSED);    
  
    start.addKey(ESCAPE, JUST_PRESSED);  
  }

  function addGamepad() {
    cross.addGamepad(A, JUST_PRESSED);
    cross_jr.addGamepad(A, JUST_RELEASED);

    triangle.addGamepad(Y, JUST_PRESSED);

    left.addGamepad(DPAD_LEFT, PRESSED);
    left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);
  
    left_jp.addGamepad(DPAD_LEFT, JUST_PRESSED);
    left_jp.addGamepad(LEFT_STICK_DIGITAL_LEFT, JUST_PRESSED);    

    right_jp.addGamepad(DPAD_RIGHT, JUST_PRESSED);
    right_jp.addGamepad(LEFT_STICK_DIGITAL_RIGHT, JUST_PRESSED); 

    right.addGamepad(DPAD_RIGHT, PRESSED);
    right.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED);       

    up.addGamepad(DPAD_UP, JUST_PRESSED);
    up.addGamepad(LEFT_STICK_DIGITAL_UP, JUST_PRESSED);  

    down.addGamepad(DPAD_DOWN, JUST_PRESSED);
    down.addGamepad(LEFT_STICK_DIGITAL_DOWN, JUST_PRESSED);          

    start.addGamepad(START, JUST_RELEASED);
  }
}

