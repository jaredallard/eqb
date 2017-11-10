## Content Packs

We use content packs to be able to easily ship code and keep it independent from
the game engine -- this promotes forking the engine for changes, and keeps the
code (hopefully) non specific.


## Structure

A typical content pack looks like this:


```sh
.
├── Content-Pack_Doc.txt
├── includes
├── info
│   ├── info
│   └── manifest
├── init
│   ├── load.bash
│   ├── menus.bash
│   └── splash.bash
├── items
│   ├── sword.itm
├── levels
│   └── 1_1
└── sounds

6 directories, 11 files
```

Let's break this down.

`includes` is a to-be implemented folder for level specific code.

`info` contains information on the content pack, including the `name=value` info
file called `info/info`. It also contains a *manifest file* which is used to validate
if this is a real content pack or not.

`init` contains code that the engine will run before loading levels, and other things.

  * `load.bash` is run before loading any levels.
  * `menus.bash` contains all the code for menus that the engine calls.
  * `splash.bash` is run before showing any menus, as 'splash screen'.

`items` contains all items in the eqb item format.

`levels` contains all the levels code, written in a `major_minor` format, i.e `1_1`

`sounds` is a to-be implemented folder for possible songs / etc being played.


## Building a Content Pack

Following the structure above, you just zip it up and place it in the content folder!
It can be loaded in via `--content=path/to/file.zip` or just replace the default.zip.

Pretty simple.
