local CATEGORY_NAME = "Other"

if SERVER then
	ULib.ucl.registerAccess("ulx seeallmaps","superadmin","See all available maps in the maps list, rather than only voteable ones.",CATEGORY_NAME)
end