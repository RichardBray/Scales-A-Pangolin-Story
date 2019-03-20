# Pangolin game

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
watchman-make -p '**/*.hx' -r 'sh watcher.sh'
```
To rebuild the game when a .hx file has been changed.


## Notes

### Color

AARRGGBB

Hex is  =  RRGGBB
AA for transparency
0x prefix indicates it's a hexidecimal number