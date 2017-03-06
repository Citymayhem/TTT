-- From the guide here- https://facepunch.com/showthread.php?t=1296365
-- Thanks an.droid
-- LocalPlayer = Player who clicked
-- menu.Player = Player clicked on

local panelfont = "HudHintTextLarge"
local panelpadding = 25
local panelitemmargin = 10

--[[
===================================================================================================
Adds the right-click context menu to the TTT menu
===================================================================================================
--]]
hook.Add("TTTScoreboardMenu","cmscoreboardcontextmenu", function(menu)
    local menuSections = {}

    -- Add sections here
    AddMenuSection(menuSections, BuildGeneralSection())
    AddMenuSection(menuSections, BuildGeneralAdminSection())
    AddMenuSection(menuSections, BuildSlaySection())
    AddMenuSection(menuSections, BuildChatSection())
    AddMenuSection(menuSections, BuildKickSection(menu.Player))
    AddMenuSection(menuSections, BuildBanSection(menu.Player))

    RenderMenuSections(menu, menuSections)
end)
--[[
===================================================================================================
--]]



--[[
===================================================================================================
Builds the right click menu
===================================================================================================
--]]

function BuildGeneralSection()

    local menuItem = {
        text = "Information",
        icon = "icon16/user.png",
        subMenu = {}
    }

    table.insert(menuItem.subMenu, { text = "Copy Name",
                                     icon = "icon16/user_edit.png",
                                     onClick = function(target) SetClipboardText(target:Nick()) end
                                     })

    table.insert(menuItem.subMenu, { text = "Copy SteamID",
                                     icon = "icon16/tag_blue.png",
                                     onClick = function(target) SetClipboardText(target:SteamID()) end
                                     })

    table.insert(menuItem.subMenu, { text = "Open Profile",
                                     icon = "icon16/world.png",
                                     onClick = function(target) target:ShowProfile() end
                                     })
    return { options = { menuItem }, addSpacerAfter = true }
end


function BuildGeneralAdminSection()

    local menuItem = {
        text = "General Administration",
        icon = "icon16/shield.png",
        subMenu = {}
    }
    
    if PlayerHasRequiredPermission("ulx spectate") then
        table.insert(menuItem.subMenu, { text = "Spectate",
                                         icon = "icon16/zoom.png",
                                         onClick = function(target) RunConsoleCommand("ulx","spectate", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx fspec") then
        table.insert(menuItem.subMenu, { text = "Force Spectate",
                                         icon = "icon16/zoom.png",
                                         onClick = function(target) RunConsoleCommand("ulx","fspec", target:Nick()) end
                                         })
    end
    
    if PlayerHasRequiredPermission("ulx goto") then
        table.insert(menuItem.subMenu, { text = "Teleport To",
                                         icon = "icon16/arrow_up.png",
                                         onClick = function(target) RunConsoleCommand("ulx","goto", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx teleport") then
        table.insert(menuItem.subMenu, { text = "Bring (To where you're aiming)",
                                         icon = "icon16/arrow_up.png",
                                         onClick = function(target) RunConsoleCommand("ulx","teleport", target:Nick()) end
                                         })
    end

    return { options = { menuItem } }
end


function BuildSlaySection()

    local menuItem = {
        text = "Slaying",
        icon = "icon16/user_red.png",
        subMenu = {}
    }
    
    if PlayerHasRequiredPermission("ulx slay") then
        table.insert(menuItem.subMenu, { text = "Slay",
                                         icon = "icon16/user_red.png",
                                         onClick = function(target) RunConsoleCommand("ulx","slay", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx slaynr") then
        table.insert(menuItem.subMenu, { text = "Slay Next Round(s)",
                                         icon = "icon16/clock_red.png",
                                         onClick = function(target) OpenSlayNRDialog(target) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx rslaynr") then
        table.insert(menuItem.subMenu, { text = "Remove Next Round Slay(s)",
                                         icon = "icon16/clock_stop.png",
                                         onClick = function(target) OpenRSlayNRDialog(target) end
                                         })
    end

    return { options = { menuItem } }
end


function BuildChatSection()

    local menuItem = {
        text = "Chat Administration",
        icon = "icon16/comments.png",
        subMenu = {}
    }
    
    if PlayerHasRequiredPermission("ulx psay") then
        table.insert(menuItem.subMenu, { text = "Private Message",
                                         icon = "icon16/user_comment.png",
                                         onClick = function(target) OpenPrivateMessageDialog(target) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx mute") then
        table.insert(menuItem.subMenu, { text = "Mute",
                                         icon = "icon16/comment_delete.png",
                                         onClick = function(target) RunConsoleCommand("ulx","mute", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx unmute") then
        table.insert(menuItem.subMenu, { text = "Unmute",
                                         icon = "icon16/comment_add.png",
                                         onClick = function(target) RunConsoleCommand("ulx","unmute", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx gag") then
        table.insert(menuItem.subMenu, { text = "Gag",
                                         icon = "icon16/sound_mute.png",
                                         onClick = function(target) RunConsoleCommand("ulx","gag", target:Nick()) end
                                         })
    end

    if PlayerHasRequiredPermission("ulx ungag") then
        table.insert(menuItem.subMenu, { text = "Ungag",
                                         icon = "icon16/sound_low.png",
                                         onClick = function(target) RunConsoleCommand("ulx","ungag", target:Nick()) end
                                         })
    end
    
    return { options = { menuItem } }
end


function BuildKickSection(target)

    if not PlayerHasRequiredPermission("ulx kick") then
        return {}
    end

    -- If the player disconnects, this should fail gracefully. We need to record their name and steam Id in-case this happens for the error message
    local targetName = target:Nick()
    local targetSteamId = target:SteamID()
    local onPlayerDisconnect = function() LocalPlayer():ChatPrint(targetName .. " (" .. targetSteamId .. ") disconnected before you could kick them.") end

    local menuItem = {
        text = "Kick",
        icon = "icon16/door_in.png",
        subMenu = {}
    }

    table.insert(menuItem.subMenu, { text = "AFK",
                                     onClick = function(target) RunConsoleCommand("ulx", "kick", targetName, "AFK") end,
                                     onFail = onPlayerDisconnect
                                     })

    table.insert(menuItem.subMenu, { text = "Final warning",
                                     onClick = function(target) RunConsoleCommand("ulx", "kick", targetName, "Final warning") end,
                                     onFail = onPlayerDisconnect
                                     })

    table.insert(menuItem.subMenu, { text = "Other (specify)",
                                     icon = "icon16/textfield.png",
                                     onClick = function(target) OpenKickReasonDialog(target, targetName, onPlayerDisconnect) end,
                                     onFail = onPlayerDisconnect
                                     })

    return { options = { menuItem } }
end


function BuildBanSection(target)

    if not PlayerHasRequiredPermission("ulx banid") then
        return {}
    end

    -- Even if the player disconnects, we want the ban to succeed
    local targetName = target:Nick()
    local targetSteamId = target:SteamID()
    local menuItem = {
        text = "Ban",
        icon = "icon16/stop.png",
        subMenu = {}
    }

    table.insert(menuItem.subMenu, { text = "Other (specify)",
                                     icon = "icon16/textfield.png",
                                     onClick = function(target) OpenBanPlayerDialog(targetName, targetSteamId) end,
                                     disableClickTargetValidation = true
                                     })

    return { options = { menuItem } }
end





--[[
===================================================================================================
Render functions
===================================================================================================
--]]


function RenderMenuSections(menu, menuSections)

    local addSpacer = false
    for sectionKey, section in pairs(menuSections) do
        if addSpacer then
            menu:AddSpacer()
        end

        addSpacer = section.addSpacerAfter
        
        RenderMenuSectionOptions(menu, menu.Player, section.options)
    end

end


function RenderMenuSectionOptions(menu, target, sectionOptions)

    for _, option in pairs(sectionOptions) do
        if option.subMenu == nil then
            local onClick = option.onClick

            if option.disableClickTargetValidation ~= true and onClick ~= nil then
                if option.onFail == nil then
                    onClick = WrapOnClickPlayer(target, onClick)
                else
                    onClick = WrapOnClickPlayerWithFailCallback(target, onClick, option.onFail)
                end
            end

            AddMenuOption(menu, option.text, option.icon, onClick)
        else
            local subMenu = AddSubMenuOption(menu, option.text, option.icon)
            RenderMenuSectionOptions(subMenu, target, option.subMenu)
        end
    end

end


function AddMenuOption(menu, text, icon, onClick)

    local menuOption = menu:AddOption(text, function() onClick(menu) end)
    
    if not (icon == "" or icon == nil) then 
        menuOption:SetImage(icon)
    end
end


function AddSubMenuOption(menu, text, icon)

    local subMenu, parentMenuOption = menu:AddSubMenu(text)

    if not (icon == "" or icon == nil) then 
        parentMenuOption:SetImage(icon)
    end
    
    return subMenu
end


function WrapOnClickPlayer(target, onClick)

    return function()
        if IsValid(target) then
            onClick(target)
        end
    end
end

function WrapOnClickPlayerWithFailCallback(target, onClick, onFail)

    return function()
        if IsValid(target) then
            onClick(target)
        else
            onFail()
        end
    end
end





--[[
===================================================================================================
Utility functions
===================================================================================================
--]]

function AddMenuSection(menu, section)
    local isSectionEmpty = next(section.options) == nil
    if isSectionEmpty then return end

    for k, option in pairs(section.options) do
        -- Remove options with empty submenus
        local optionHasSubmenu = option.subMenu ~= nil
        if optionHasSubmenu and (next(option.subMenu) == nil) then
            section.options[k] = nil
        end
    end

    isSectionEmpty = next(section.options) == nil
    if isSectionEmpty then return end

    table.insert(menu, section)
end


function PlayerHasRequiredPermission(requiredPermission)
    return ULib and ULib.ucl.query(LocalPlayer(), requiredPermission)
end


--[[
===================================================================================================
--]]





--[[
===================================================================================================
Dialog Functions
===================================================================================================
--]]
function OpenPrivateMessageDialog(target)
    ShowMessagePanel("Private Message", "Enter a private message to send to " .. target:Nick(), function(message)
        if IsValid(target) then
            RunConsoleCommand("ulx", "psay", target:Nick(), message)
        end
    end)
end

function OpenSlayNRDialog(target)
    ShowMessagePanel("Slay", "Number of rounds to slay " .. target:Nick() .. ": ", function(numSlays)
        if IsValid(target) then
            RunConsoleCommand("ulx", "slaynr", target:Nick(), numSlays)
        end
    end)
end

function OpenRSlayNRDialog(target)
    ShowMessagePanel("Slay", "Number of round slays to remove for " .. target:Nick() .. ": ", function(numSlays)
        if IsValid(target) then
            RunConsoleCommand("ulx", "rslaynr", target:Nick(), numSlays)
        end
    end)
end

function OpenKickReasonDialog(target, targetName, failureCallback)
    ShowMessagePanel("", "Reason for kicking " .. targetName, function(reason)
        WrapOnClickPlayerWithFailCallback(target, function(target) RunConsoleCommand("ulx", "kick", target:Nick(), reason) end, failureCallback)
    end) 
end

function OpenBanPlayerDialog(targetName, targetSteamId)
    ShowMessagePanel("Ban Length", "Length (minutes). 0 is permanent. Use h (hours), d (days) or w (weeks) for different lengths e.g. 1d = 1 day", function(banLength)
        
        local validBanLength = string.match(string.lower(string.Trim(banLength)), "^([0-9]+) *([hdmy]?)$")
        if validBanLength then
            ShowMessagePanel("Ban Reason", "Reason for banning " .. targetName, function(reason)
                RunConsoleCommand("ulx", "banid", targetSteamId, banLength, reason)
            end)
        else
            -- TODO: Remove this recursion and handle this better
            LocalPlayer():ChatPrint("Invalid ban length.")
            OpenBanPlayerDialog(targetName, targetSteamId)
        end
    end)
end


function ShowMessagePanel (panelTitle, inputLabel, successCallback)
    local curx = panelpadding
    local cury = panelpadding + panelitemmargin
    
    local pmsgpanel = vgui.Create("DFrame")
        pmsgpanel:SetTitle(panelTitle)
        pmsgpanel:ShowCloseButton(true)
        pmsgpanel:SetVisible(true)
        pmsgpanel:MakePopup()
        pmsgpanel:SetDraggable(true)
        
    local pmsglabel = vgui.Create("DLabel", pmsgpanel)
        pmsglabel:SetPos(curx,cury)
        pmsglabel:SetText(inputLabel)
        pmsglabel:SizeToContents()
    cury = cury + pmsglabel:GetTall() + panelitemmargin
    
    local pmsgtext = vgui.Create("DTextEntry", pmsgpanel)
        pmsgtext:SetPos(curx,cury)
        pmsgtext:SetTall(20)
        pmsgtext:SetWide(450)
        pmsgtext:SetEnterAllowed(true)
    
    pmsgpanel:SetSize(math.max(pmsglabel:GetSize(), pmsgtext:GetSize()) + panelpadding * 2, cury + pmsgtext:GetTall() + panelitemmargin)
    pmsgpanel:SetPos(ScrW() * 0.5 - (pmsgpanel:GetSize() / 2), ScrH() * 0.5 - (pmsgpanel:GetTall() / 2))
    -- center text box
    pmsgtext:SetPos(pmsgpanel:GetSize() / 2 - pmsgtext:GetSize() / 2, cury)
    
    pmsgtext:RequestFocus()
    
    pmsgtext.OnEnter = function()
        local message = pmsgtext:GetValue()
        if(message == "")then return end
        
        pmsgpanel:SetVisible(false)
        
        successCallback(message)
    end
end
--[[
===================================================================================================
--]]
