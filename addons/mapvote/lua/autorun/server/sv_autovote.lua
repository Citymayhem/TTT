hook.Add( "Initialize", "AutoTTTMapVote", function()
      if GAMEMODE_NAME == "terrortown" then
        function CheckForMapSwitch()
           -- Check for mapswitch
           local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
           SetGlobalInt("ttt_rounds_left", rounds_left)
           local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
           
		   if rounds_left <= 0 then
		      timer.Stop("end2prep")
			  local mapskip = GetConVar("mapvote_maps_til_vote")
			  local mapsleft = mapskip:GetInt() - 1
			  if(mapsleft <= 0)then
			     print("[MAPVOTE] Time for map vote. Mapsleft is <= 0")
				 MapVote.Start(nil, nil, nil, nil)
			  else
			     RunConsoleCommand("mapvote_maps_til_vote",mapsleft)
				 Msg(mapsleft," maps(s) remaining before a map vote.")
				 
				 local nextmap = string.upper(game.GetMapNext())
				 if rounds_left <= 0 then LANG.Msg("limit_round", {mapname = nextmap})
				 elseif time_left <= 0 then LANG.Msg("limit_time", {mapname = nextmap}) end
				 timer.Simple(28,game.LoadNextMap)
              end
            end
        end
      end
      
      if GAMEMODE_NAME == "deathrun" then
          function RTV.Start()
            MapVote.Start(nil, nil, nil, nil)
          end
      end
      
      if GAMEMODE_NAME == "zombiesurvival" then
        hook.Add("LoadNextMap", "MAPVOTEZS_LOADMAP", function()
          MapVote.Start(nil, nil, nil, nil)
          return true   
        end )
      end

end )


