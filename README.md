CM-TTT
======

Code developed for the GMod TTT community CityMayhem. Free to use for anyone.  
http://www.citymayhem.net  
http://www.badgercode.co.uk  

##Credit
* Massive thanks to Dangerous Dan for adding weapon spawns to the maps for these new weapons.  
* Thanks to SilentK, TC224, Maccat and Mr. R for their help
* Thanks to the rest of CityMayhem!


##Includes
* Adds more weapon spawns to the CS:S maps
	* addons/cmlua/lua/maps/
* Allows traitors to attach the default C4 weapon to innocent players
* Pointshop modifications
* Right-click menu for TTT: Adds ULX admin commands
  * addons/cmlua/lua/autorun/client/tttmenu.lua
* Pre-round player list printing and post-round damage log printing (in console)
  * addons/cmlua/lua/autorun/client/printlog.lua
* Legs (when you look down)
  * addons/cmlua/lua/autorun/client/legmodels.lua
* !Join command (opens up CityMayhem steam group)
  * addons/cmlua/lua/autorun/server/joincommand.lua
* Script for downloading custom content for maps which haven't packed them into the .bsp file 
  * addons/cmlua/lua/autorun/server/mapResources.lua
* Bans players who get around bans using family sharing
  * addons/cmlua/lua/ulx/modules/sh/accountsharing.lua


##Installing
1. Download and install the following addons:
  1. Pointshop- https://github.com/adamdburton/pointshop
  2. Mapvote- https://github.com/willox/gmod-mapvote
  3. ULX and ULib- https://github.com/Nayruden/Ulysses/
  4. Spraymon- http://steamcommunity.com/sharedfiles/filedetails/?id=105463332
2. Install the contents of this repository into your garrysmod directory.
  1. Some files and directories will need to be overwritten.
3. Delete all the map spawns in /gamemodes/terrortown/content/maps/
4. Add your Steam API key to addons/cmlua/lua/ulx/modules/sh/accountsharing.lua
	1. Replace APIKEYGOESHERE with it
	2. See http://steamcommunity.com/dev/apikey