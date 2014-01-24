local CATEGORY_NAME  = "TTT Admin"

-- If I make my own versions of the commands below, the required access will not be needed.
if SERVER then 
	ULib.ucl.registerAccess("ttt_print_traitors", "admin","Prints a list of players and their roles.",CATEGORY_NAME)
	ULib.ucl.registerAccess("ttt_print_adminreport", "admin","Prints a list of kills.",CATEGORY_NAME)
	ULib.ucl.registerAccess("ttt_print_karma", "admin","Prints a detailed list of up-to-date karma.",CATEGORY_NAME)
	ULib.ucl.registerAccess("ttt_print_damagelog", "admin","Prints a list of damage and kills.",CATEGORY_NAME)
end
--[[

--Roles
function PrintRoles(calling_ply)
	calling_ply:ConCommand("ttt_print_traitors")--Replace with code from that
end
local printroles = ulx.command(CATEGORY_NAME,"ulx printroles",PrintRoles,"!printroles")
printroles:defaultAccess("admin")
printroles:help("Prints a list of players and their roles. (In Console)")

--Admin report
function AdminReport(calling_ply)
	calling_ply:ConCommand("ttt_print_adminreport")--Replace with code from that
end
local adminreport = ulx.command(CATEGORY_NAME,"ulx adminreport",AdminReport,"!adminreport")
adminreport:defaultAccess("admin")
adminreport:help("Prints a list of kills. (In Console)")

--karma
function PrintKarma(calling_ply)
	calling_ply:ConCommand("ttt_print_karma")--Replace with code from that
end
local printkarma = ulx.command(CATEGORY_NAME,"ulx printkarma",PrintKarma,"!printkarma")
printkarma:defaultAccess("admin")
printkarma:help("Prints a detailed list of up-to-date karma (scoreboard karma updates at end of round). (In Console)")

--Damage log
function PrintDamagelog(calling_ply)
	calling_ply:ConCommand("ttt_print_damagelog")--Replace with code from that
end
local damagelog = ulx.command(CATEGORY_NAME,"ulx damagelog",PrintDamagelog,"!damagelog")
damagelog:defaultAccess("admin")
damagelog:help("Prints a list of damage and kills. (In Console)")
--]]