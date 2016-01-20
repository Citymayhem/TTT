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
	textInput:SetUpdateOnType(true)
	textInput.OnEnter = function(self)
		local message = self:GetValue()
		
		if(message:len() > 500) then 
			self:SetText(message:sub(0, 499))
		end
		
		local chatMessage = LocalPlayer():GetName() .. ": " .. message
		local chatBoxMessage = CreateChatMessage(chatMessage)
		
		if anyMessages then
			AddVerticalDivider(messageList)
		end
		anyMessages = true
		
		messageList:Add(chatBoxMessage)
		
		chatContainer:ScrollToChild(chatBoxMessage)
		
		self:SetText("")
		self:RequestFocus()
	end
	textInput.OnValueChange = function(newValue)
		local oldValue = self:GetValue()
		print("Old: " .. oldValue .. ", new: " .. newValue)
		--if(newValue:len() > 500) then
		--	self:SetText()
		--end
	end
	
	textInput:RequestFocus()
end
