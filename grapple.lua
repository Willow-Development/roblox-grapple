local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local grappling = false
local targetPosition = nil
local rope = nil
local ropeConstraint = nil
local attachment0 = nil
local bodyVelocity = nil
local bodyGyro = nil

local grappleSpeed = 55

local function fireGrapple()
    local mouse = player:GetMouse()
    targetPosition = mouse.Hit.p

    local hitPart = mouse.Target
    if not hitPart or not hitPart.CanCollide then
        print("Error: Target position is not on a solid surface.")
        return
    end

    if rope then
        rope:Destroy()
        rope = nil
    end

    rope = Instance.new("Part")
    rope.Anchored = false
    rope.CanCollide = false
    rope.Material = Enum.Material.Neon
    rope.BrickColor = BrickColor.new("Really black")
    rope.Size = Vector3.new(0.2, 0.2, (character.Head.Position - targetPosition).magnitude)
    rope.CFrame = CFrame.new((character.Head.Position + targetPosition) / 2, targetPosition)
    rope.Parent = workspace

    if attachment0 then
        attachment0:Destroy()
    end
    attachment0 = Instance.new("Attachment", character.HumanoidRootPart)
    local attachment1 = Instance.new("Attachment", rope)

    ropeConstraint = Instance.new("RopeConstraint", rope)
    ropeConstraint.Attachment0 = attachment0
    ropeConstraint.Attachment1 = attachment1
    ropeConstraint.Length = (character.Head.Position - targetPosition).magnitude
    ropeConstraint.Visible = true
    ropeConstraint.Thickness = 0.2

    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(2000, 2000, 2000)
    bodyVelocity.Velocity = (targetPosition - character.HumanoidRootPart.Position).unit * grappleSpeed
    bodyVelocity.Parent = character.HumanoidRootPart

    if bodyGyro then
        bodyGyro:Destroy()
    end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(2000, 2000, 2000)
    bodyGyro.CFrame = CFrame.new(character.HumanoidRootPart.Position, targetPosition)
    bodyGyro.Parent = character.HumanoidRootPart

    grappling = true
end

local function stopGrapple()
    grappling = false

    if rope then
        rope:Destroy()
        rope = nil
    end
    if ropeConstraint then
        ropeConstraint:Destroy()
        ropeConstraint = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if attachment0 then
        attachment0:Destroy()
        attachment0 = nil
    end
end

local function updateGrapple()
    if grappling and targetPosition then
        local direction = (targetPosition - character.HumanoidRootPart.Position).unit
        local distance = (targetPosition - character.HumanoidRootPart.Position).magnitude

        if bodyVelocity then
            bodyVelocity.Velocity = direction * grappleSpeed
        end

        if rope then
            rope.Size = Vector3.new(0.2, 0.2, distance)
            rope.CFrame = CFrame.new((character.HumanoidRootPart.Position + targetPosition) / 2, targetPosition)
        end

        if distance < 5 then
            stopGrapple()
        end
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        fireGrapple()
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        stopGrapple()
    end
end)

-- ///
--  Made by your favorite, Jae
-- ///

runService.RenderStepped:Connect(updateGrapple)
