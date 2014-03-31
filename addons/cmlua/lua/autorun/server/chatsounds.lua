--TTTPlayerRadioCommand
--ply:EmitSound(path,distancepct,pitchpct)
--RealTime() - seconds since server start

local sounds = {}
sounds[quick_yes] = {"vo/npc/male01/yeah02.wav", "vo/npc/female01/yeah02.wav", "/bot/yesss.wav"}

sounds[quick_no] = {"vo/Citadel/br_no.wav", "vo/Citadel/eli_nonever.wav", "/bot/no.wav"}

sounds[quick_help] = {"vo/npc/male01/help01.wav", "vo/npc/female01/help01.wav", "vo/npc/male01/strider_run.wav", "vo/npc/female01/strider_run.wav"}

sounds[quick_imwith] = {"vo/npc/male01/answer13.wav", "vo/npc/female01/answer13.wav"}

sounds[quick_see] = {"vo/NovaProspekt/al_gladtoseeyou.wav", "vo/Streetwar/nexus/ba_seeyou.wav"}

sounds[quick_innocent] = {}

sounds[quick_traitor] = {"vo/npc/male01/wetrustedyou01.wav", "vo/npc/male01/wetrustedyou02.wav", "vo/npc/female01/wetrustedyou01.wav", "vo/npc/female01/wetrustedyou03.wav", "vo/npc/male01/notthemanithought01.wav", "vo/npc/male01/notthemanithought02.wav", "vo/npc/female01/notthemanithought01.wav", "vo/npc/female01/notthemanithought02.wav"}

sounds[quick_suspect] = {"vo/trainyard/al_suspicious.wav", "vo/trainyard/al_suspicious_b.wav", "vo/ravenholm/yard_suspect.wav"}

sounds[quick_check] = {"vo/npc/male01/squad_reinforce_single01.wav", "/bot/report_in_team.wav"}

function CheckChat(ply, cmd_name, cmd_target)
	if(ply:Alive() and RealTime() - ply.LastChatSound >= 5)then
		ply.LastChatSound = RealTime()
		ply:EmitSound(table.Random(sounds[cmd_name]),200,100)
	end
	--return true to block command
end

hook.Add("TTTPlayerRadioCommand", "ChatSounds", CheckChat)