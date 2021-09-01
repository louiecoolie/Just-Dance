
local RunService = game:GetService("RunService")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local luaClassModule = ReplicatedStorage.Common.Modules:WaitForChild("LuaClass")
local luaClass = require(luaClassModule)

local BaseSingleton = require(luaClassModule:WaitForChild("BaseSingleton"))

local MarketService, get, set = luaClass("MarketService", BaseSingleton)

function MarketService.__initSingleton(prototype)
    local self = BaseSingleton.__initSingleton(MarketService) -- get singleton by calling super init

    self._developerProducts = {} -- create a dictionary for developer products
    self._productStores = {} -- create a dictionary for different product stores



    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)

        local productAvailable = self._developerProducts[receiptInfo.ProductId]
        if productAvailable then
            local purchaseSuccessful, errmsg = pcall(function() productAvailable(player, receiptInfo) end)
            if not purchaseSuccessful then 
                warn("Purchase Unsuccessful", errmsg)  -- actually we should log this to discord
                return Enum.ProductPurchaseDecision.NotProcessedYet 
            end
            return Enum.ProductPurchaseDecision.PurchaseGranted

        else
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end

    MarketplaceService.PromptProductPurchaseFinished:Connect(function(player, assetId, isPurchased)
        if self._productStores[assetId] then
            if isPurchased then
			    self._productStores[assetId](player, true)
            else
                self._productStores[assetId](player, false)
            end
        else
            warn("product handler not set for", assetId)
		end

    end)

    return self
end



function MarketService:AddProductMap(productMap)
    for productId, productProcess in pairs(productMap) do
        self._developerProducts[productId] = productProcess
    end

end

function MarketService:AddConfirmationHandle(storeMap)
    for productId, dispatch in pairs(storeMap) do
        self._productStores[productId] = dispatch
    end
end


return MarketService