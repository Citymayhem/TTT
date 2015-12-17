concommand.Add("testchat", function()
	ShowChatWindow()
end)

function CreateChatMessage(messageText)	
	local message = vgui.Create("DLabel")
	message:SetText(messageText)
	message:SetWrap(true)
	message:SetAutoStretchVertical(true)
	
	return message
end

function AddVerticalDivider(parentPanel)
	local divider = vgui.Create("DVerticalDivider")
	divider:SetSize(0, 5)
	
	parentPanel:Add(divider)
end

function ShowChatWindow()
	local anyMessages = false

	local chatWindow = vgui.Create("DFrame")
	chatWindow:SetPos(ScrW() / 2 - 200, ScrH() / 2 - 200)
	chatWindow:SetSize(400, 400)
	chatWindow:SetTitle("Reports")
	chatWindow:SetVisible(true)
	chatWindow:SetDraggable(true)
	chatWindow:SetSizable(true)
	chatWindow:SetMinHeight(400)
	chatWindow:SetMinWidth(400)
	chatWindow:ShowCloseButton( true )
	chatWindow:MakePopup()
	chatWindow.Paint = function(self, width, height)
		draw.RoundedBox(0, 0, 0, width, height, Color(30, 30, 30, 255))
	end
	
	local chatContainer = vgui.Create("DScrollPanel", chatWindow)
	chatContainer:SetPos(0, 25)
	chatContainer:SetSize(390, 345)
	
	local messageList = vgui.Create("DListLayout", chatContainer)
	messageList:SetPos(5, 0)
	messageList:SetWidth(390)
	
	local textInput = vgui.Create("DTextEntry", chatWindow)
	textInput:SetPos(5, 375)
	textInput:SetSize(390, 20)
	textInput.OnEnter = function(self)
		local message = LocalPlayer():GetName() .. ": " .. self:GetValue()
		local chatMessage = CreateChatMessage(message)
		
		if anyMessages then
			AddVerticalDivider(messageList)
		end
		anyMessages = true
		
		messageList:Add(chatMessage)
		
		chatContainer:ScrollToChild(chatMessage)
		
		self:SetText("")
		self:RequestFocus()
	end
	
	textInput:RequestFocus()
end
