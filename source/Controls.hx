package;

import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction.FlxActionDigital;

class PlayerControls {
  var _actionManager:FlxActionManager;

  public var cross:FlxActionDigital;

  public var left:FlxActionDigital;
  public var right:FlxActionDigital;
  public var up:FlxActionDigital;
  public var down:FlxActionDigital;

  public var start:FlxActionDigital;

  /**
   * Sets up all the player controls in the game.
   *
   * @param ActionManager State required aciton manager for controls.
   */
  public function new(ActionManager:FlxActionManager):Void {
    _actionManager = ActionManager;
    initInputs();
    addKeys();
    addGamepad();
  }

  function initInputs() {
    cross = new FlxActionDigital();
    left = new FlxActionDigital();
    right = new FlxActionDigital();
    up = new FlxActionDigital();
    down = new FlxActionDigital();
    start = new FlxActionDigital();

    _actionManager.addActions([cross, left, right, up, down, start]);     
  }

  function addKeys() {
    cross.addKey(SPACE, JUST_PRESSED);
    cross.addKey(W, JUST_PRESSED);
    cross.addKey(UP, JUST_PRESSED);

    start.addKey(SPACE, JUST_PRESSED); 
    start.addKey(ENTER, JUST_PRESSED);

    left.addKey(LEFT, PRESSED);
    left.addKey(A, PRESSED);

    right.addKey(RIGHT, PRESSED);
    right.addKey(D, PRESSED); 
  }

  function addGamepad() {
    cross.addGamepad(A, JUST_PRESSED);

    left.addGamepad(DPAD_LEFT, PRESSED);
    left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);

    right.addGamepad(DPAD_RIGHT, PRESSED);
    right.addGamepad(RIGHT_STICK_DIGITAL_LEFT, PRESSED);   
  }
}

class NPCControls {
  var _actionManager:FlxActionManager;

  public var triangle:FlxActionDigital;

  public function new(ActionManager:FlxActionManager):Void {
    triangle = new FlxActionDigital();

    ActionManager.addAction(triangle); 
    triangle.addKey(E, JUST_PRESSED); 
    triangle.addGamepad(Y, JUST_PRESSED); 
  }
}

class DialogueControls {

}
class MenuControls {

}
