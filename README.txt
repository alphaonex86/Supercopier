Supercopier 3
====================

Supercopier is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

Supercopier is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Website:
  http://ultracopier.first-world.info/supercopier.html

E-Mail:
  alpha_one_x86@first-world.info

Staff:
  Alpha_one_x86: new dev, packager, dev of Ultracopier
  GliGli: Main code,
  Yogi: Original NT Copier,
  ZeuS: Graphical components.

Special thanks to:
  TntWare http://www.tntware.com/ (unicode components),
  Tal Sella http://www.virtualplastic.net/scrow/ (icons).

Description:
============

Supercopier replaces Windows explorer file copy and adds many features:
    - Transfer resuming
    - Copy speed control
    - No bugs if You copy more than 2GB at once
    - Copy speed computation
    - Better copy progress display
    - A little faster
    - Copy list editable while copying
    - Error log
    - Copy list saving/loading
    - ...
    
Compatibility: Windows NT4/2000/XP/Vista/Seven/8 and 64 bit/Server flavors.

History:
========

- v3.0.0.3
    - Don't install into Program files (x86) for the 64Bits version.
    - Don't call 2x the UAC at the startup
    - Work better when have space into the path

- v3.0.0.2
    - Add german translation
    - Fix some crash
    - Improve the uninstall

- v3.0.0.1
    - Fix crash on some windows
    - Fix translation for some button

- v3.0.0.0
    - Rewrite for lazarus
    - Rewrite of the copy interception system
    - Native/full unicode support

- v2.3 RC:
    New packaging

- v2.2 beta:
    - Complete rewrite of the copy interception system, adds support for
      Windows Vista, Seven and all 64 bit Windows. For now, compatibility with 
      Windows 95, 98 and Millenium has been dropped and 'handled processes' is 
      deactivated.
    - Added options to sort the copy list. You can either click on the column headers
      or use the 'Sort' context menu item.
    - Separated attributes copy from security copy.
    - User interface improvements, including: 
        - Reintroduced Supercopier 1.35 like cursor for copy speed limitation.
        - Popup menus from file collision and file error windows now automatically
          popup when the button is hovered.
	- Copy window is no more a tool window, so now it has standard buttons like
          minimize, maximize and system menu. This should also fix problems with
          non standard themes.
    - Many bugfixes (about 100 bugs were treated).