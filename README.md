# Pangolin game

## Dependencies

- Haxe
- HaxeFlixel
- OpenFl
- Lime
- Facebook Watchman (https://facebook.github.io/watchman/docs/install.html)
- Node
- http-server (https://www.npmjs.com/package/http-server)

## Run the game

This games uses Lime by Openfl to run.
Command documentaiton is here https://lime.software/docs/command-line-tools/basic-commands/

### Run the latest build
```bash
lime run html5
```

### Run for development

```
yarn start
```
or

```
npm start
```

## Build for production
```
lime build mac -release
```

## Notes

### Probems
- slope collision
- moving sprite hitbox position
- neko on mac

### Haxe

cast
The `cast` keyword reinterprets the perceived type of an expression without changing its contents.

using

reload vs code

haxelib install hscript 

### Git Tagging commans
add tag
`git tag -a v0.11.0 -m "new version 0.11.0"`

show tag
`git show v0.1.0`

push tag
`git push origin v0.11.0`

Scales of Life: A Pangolin's story

### Potential articles
- Creating fading text in HaxeFlixel without Chaining tweens
- Multiple hitboxes in haxeflixel
- What is haxe and why should you care abou it?
- Using more maths in my code
- ESC

### Things I've learnt though gamedev
- Document everything
- I have a new appreciation for semicolons
- Difference between acceleration and velocity
-- speed: only magnitude not direction (Scalar)
-- velocity: speed of something in a given direction
- What a singketon is
- ESC
- Javascript is very forgiving
  - !!string


http://www.softschools.com/facts/animals/pangolin_facts/108/


### Testing code

```hx
#if debug
_gameSave = new FlxSave(); // initialize
_gameSave.bind("AutoSave"); // bind to the named save slot 
#end   
_gameSave = saveGame(_gameSave, [0, 0]);  
```

### Save game data structure

```js
data: {
  // Level specific / Resets / Changes
  levelName: "Level-5-0",  
  totalBugs: 0,
  totalEnemies: 0,  
  // General
  enableLevelSelect: false,
  totalInstructionPage: 0,
  // Abilities
  quickJumpEnabled: true,
  //Intros
  introTwoSeen: true,
  // Stars
  levelStars: [1, 2, 3, 3, 2] // Not yet implemented
}
```