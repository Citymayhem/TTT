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


##Installing
* Download and install the following addons:
  * Pointshop- https://github.com/adamdburton/pointshop
  * Mapvote- https://github.com/tyrantelf/gmod-mapvote
  * ULX and ULib- https://github.com/Nayruden/Ulysses/
  * Spraymon- http://steamcommunity.com/sharedfiles/filedetails/?id=105463332
* Install the contents of this repository into your garrysmod directory.
  * Some files and directories will need to be overwritten.
* If you want to use the custom weapons and have them spawn on the CS:S maps:  
  * Delete all the map spawns in /gamemodes/terrortown/content/maps/
