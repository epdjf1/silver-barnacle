-- Version 1.1	
-- ShopClient: EŰ(ShopPrompt)�� ���� UI ���� + ǰ�� ���� ���� + ������ Buy/Sell ��û
-- �ʺ�����:
--  - UI�� �ڵ�� �Ｎ ����(ScreenGui) �� ����� �ı�/�����.
--  - RemoteFunction���� ��� �޾Ƽ� ��� ����.

-- Version 1.1 (������)
-- RemoteEvent ������ ���� �����ϰ� �����մϴ�.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Shared/Config �ε� (�ε� ���� �̽� ����)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("ShopConfig"))

-- Remotes/Shop/Buy Sell�� RemoteEvent
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopFolder = Remotes:WaitForChild("Shop")
local BuyRemote  = ShopFolder:WaitForChild("Buy")  :: RemoteEvent
local SellRemote = ShopFolder:WaitForChild("Sell") :: RemoteEvent

local localPlayer = Players.LocalPlayer

-- ���� UI ����
local function buildUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ShopGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundColor3 = Color3.fromRGB(20,20,24)
	root.BackgroundTransparency = 0.1
	root.Size = UDim2.fromScale(0.42, 0.52)
	root.Position = UDim2.fromScale(0.29, 0.24)
	root.Parent = gui

	local title = Instance.new("TextLabel")
	title.Text = "����"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -40, 0, 36)
	title.Position = UDim2.new(0, 20, 0, 10)
	title.Parent = root

	local close = Instance.new("TextButton")
	close.Text = "X"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.TextColor3 = Color3.new(1,1,1)
	close.BackgroundColor3 = Color3.fromRGB(60,60,70)
	close.Size = UDim2.fromOffset(30, 30)
	close.Position = UDim2.new(1, -40, 0, 10)
	close.Parent = root

	local money = Instance.new("TextLabel")
	money.Name = "Money"
	money.Text = "Coins: 0"
	money.Font = Enum.Font.Gotham
	money.TextSize = 16
	money.TextXAlignment = Enum.TextXAlignment.Left
	money.TextColor3 = Color3.fromRGB(190,255,190)
	money.BackgroundTransparency = 1
	money.Size = UDim2.new(1, -40, 0, 20)
	money.Position = UDim2.new(0, 20, 0, 46)
	money.Parent = root

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.BackgroundTransparency = 0.2
	list.BackgroundColor3 = Color3.fromRGB(32,32,38)
	list.Size = UDim2.new(1, -40, 1, -90)
	list.Position = UDim2.new(0, 20, 0, 76)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.ScrollBarThickness = 6
	list.Parent = root

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 8)
	uiList.Parent = list

	-- ǰ�� ��ư ����
	for _, it in ipairs(Config.Items) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 56)                 -- �� �� ���̡�
		row.BackgroundColor3 = Color3.fromRGB(40,40,50)
		row.Parent = list
		
		--V1.0.2
		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Text = it.name
		name.Font = Enum.Font.Gotham
		name.TextSize = 16
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextColor3 = Color3.fromRGB(235, 235, 235)  -- �� ���� ���ڻ�
		name.TextStrokeTransparency = 0.5                 -- (����) �׵θ��� ��������
		name.ZIndex = 2                                   -- ��ư ���� ������(����)
		name.Size = UDim2.new(0.5, -10, 1, 0)
		name.Position = UDim2.new(0, 10, 0, 0)
		name.Parent = row


		local buyBtn = Instance.new("TextButton")
		buyBtn.Text = it.buy and ("���� +"..it.buy) or "���źҰ�"
		buyBtn.AutoButtonColor = it.buy ~= nil
		buyBtn.BackgroundColor3 = it.buy and Color3.fromRGB(66,194,105) or Color3.fromRGB(70,70,70)
		buyBtn.TextColor3 = Color3.new(0,0,0)
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.TextSize = 20                               -- �� ���� ũ��
		buyBtn.Size = UDim2.new(0, 120, 0, 36)             -- (��¦ �а�/����)
		buyBtn.Position = UDim2.new(1, -250, 0.5, -18)
		buyBtn.Parent = row
		
		-- RemoteEvent�� ��ȯ���� �����Ƿ� FireServer�� ȣ���մϴ�.
		buyBtn.MouseButton1Click:Connect(function()
			if not it.buy then return end         -- ���� ������ ���źҰ�
			buyBtn.Active = false                 -- ���� ��Ÿ ����(����)
			BuyRemote:FireServer(it.id, 1)        -- �� InvokeServer(X), FireServer(O)
			task.delay(0.2, function()
				if buyBtn then buyBtn.Active = true end
			end)
		end)


		local sellBtn = Instance.new("TextButton")
		sellBtn.Text = it.sell and ("�Ǹ� +"..it.sell) or "�ǸźҰ�"
		sellBtn.AutoButtonColor = it.sell ~= nil
		sellBtn.BackgroundColor3 = it.sell and Color3.fromRGB(255,210,100) or Color3.fromRGB(70,70,70)
		sellBtn.TextColor3 = Color3.new(0,0,0)
		sellBtn.Font = Enum.Font.GothamBold
		sellBtn.TextSize = 20                               -- �� ���� ũ��
		sellBtn.Size = UDim2.new(0, 120, 0, 36)
		sellBtn.Position = UDim2.new(1, -120, 0.5, -18)
		sellBtn.Parent = row

		sellBtn.MouseButton1Click:Connect(function()
			if not it.sell then return end
			sellBtn.Active = false                          -- ���� ��Ÿ ����(����)
			SellRemote:FireServer(it.id, 1)                 -- �� InvokeServer �� FireServer
			task.delay(0.2, function()
				if sellBtn then sellBtn.Active = true end
			end)
			-- ���� ���� Attribute ��ȭ�� ���� �ڵ� ���ŵ�(updateCoins ����)
		end)

	end

	-- �ݱ�
	close.MouseButton1Click:Connect(function() gui.Enabled = false end)
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Escape then
			gui.Enabled = false
		end
	end)

	gui.Parent = localPlayer:WaitForChild("PlayerGui")
	return gui
end

local gui = buildUI()

-- ���� ǥ�� �ǽð� ������Ʈ
local function updateCoins()
	local v = localPlayer:GetAttribute(Config.CurrencyName) or 0
	local lbl = gui.Root.Money
	lbl.Text = ("Coins: %d"):format(v)
end
localPlayer:GetAttributeChangedSignal(Config.CurrencyName):Connect(updateCoins)
task.defer(updateCoins)

-- EŰ ��ȣ�ۿ�(ShopPrompt)�� ����
ProximityPromptService.PromptTriggered:Connect(function(prompt, plr)
	if plr ~= localPlayer then return end
	if prompt.Name ~= "ShopPrompt" then return end
	gui.Enabled = true
	updateCoins()
end)
