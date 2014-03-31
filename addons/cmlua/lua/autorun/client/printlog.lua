hook.Add("TTTEndRound","DamageLog",function()
	RunConsoleCommand("ttt_print_damagelog")
end)
hook.Add("TTTBeginRound","SteamIDs",function()
	local ptable = {}
	print("\n=========================================================")
	for _, v in ipairs( player.GetAll() ) do
		ptable[v:Nick()] = v:SteamID()
	end
	PrintTable(ptable)
	print("=========================================================\n")
end)