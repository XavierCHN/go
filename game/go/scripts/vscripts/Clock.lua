Clock = class({})

---在围棋比赛中用的表
---@param baseTime 基本时间
---@param bonusTime 读秒时间
---@param bonusCount 读秒次数
function Clock:constructor(baseTime, bonusTime, bonusCount)
    self.baseTime = baseTime
    self.bonusCount = bonusCount
    self.bonusTime = bonusTime
    self.baseBonusTime = bonusTime
end

function Clock:Start()
    self.bActive = true
end

function Clock:Stop()
    self.bActive = false
end

function Clock:Tick()
    if not self.bActive then return end

    if self.baseTime > 1 then
        self.baseTime = self.baseTime - 1
        return
    end
    if self.bonusTime > 1 then
        self.bonusTime = self.bonusTime - 1
    else
        self.bonusCount = self.bonusCount - 1
        if self.bonusCount <= 0 then
            -- todo 设置敌方获胜
        else
            self.bonusTime = self.baseBonusTime
        end

    end
end

function Clock:GetBaseTime()
    return self.baseTime
end

function Clock:GetBonusTime()
    return self.bonusTime
end

function Clock:GetBonusCount()
    return self.bonusCount
end