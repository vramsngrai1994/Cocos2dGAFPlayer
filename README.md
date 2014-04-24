Cocos2dGAFPlayer
================

Play GAF format on iOS via cocos2d

Howto:
-----------------------
   * Menu: File -> Add to -> select GAFPlayer.xcodeproj;
   * Menu: File -> Add to -> select cocos2d-ios.xcodeproj;
   * Header Search Paths: path to GAFPlayer/Library/Sources and cocos2d/cocos2d folders;
   * Other Linker Flags: -ObjC -lz;
   * add a shaders folder to the project.
   
Please see a demo from Examples/Demo.xcodeproj
   
Download from Github
--------------------

    $ git clone git://github.com/CatalystApps/Cocos2dGAFPlayer.git
    $ git submodule update --init

Note fore pure Objective-C projects
-----------------------------------

  As GAFPlayer uses standard C++ library and by default Objective-C progect does not link it, one should link it manually. To do this follow these steps:
  * Select your project in project navigator;
  * Go to 'Build Phases';
  * In 'Link Binary With Libraries' section press '+' and add 'libstdc++.dylib'.
