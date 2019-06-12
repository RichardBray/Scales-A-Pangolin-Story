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

In one terminal tab/pane
```bash
http-server export/html5/bin
```
To run the server for html5.

In another one
```bash
watchman-make -p 'source/*.hx' -r 'sh watcher.sh'
```
To rebuild the game when a .hx file has been changed.


## Notes

### Color

AARRGGBB

Hex is  =  RRGGBB
AA for transparency
0x prefix indicates it's a hexidecimal number

### Debugging
https://haxe.org/manual/debugging-javascript.html

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
`git tag -a v1.4 -m "my version 1.4"`

show tag
`git show v0.1.0`

push tag
`git push origin v0.1.0`

### Js let's you get away with
!!string