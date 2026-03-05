I'm creating my own M1 combat system, but there are a couple of bugs that i don't know how to fix them because i don't know why they happen. 
For example there's a "Dash grab attack" where the defender and the attacker should move the same, it likely looks like this:
```lua
attacker_humanoid.AutoRotate = false
		task.delay(context.dashing.lifetime, function()
			attacker_humanoid.AutoRotate = true
		end)
		local attachmentAlignPos = Instance.new("Attachment")
		attachmentAlignPos.Name = "attachmentDash"
		attachmentAlignPos.Visible = true
		attachmentAlignPos.Parent = attacker_hrp

		local alignPos = Instance.new("AlignPosition")
		alignPos.Attachment0 = attachmentAlignPos
		alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPos.MaxForce = math.huge
		alignPos.MaxVelocity = math.huge
		alignPos.Position = context.dashing.direction
		-- testPart({Position = context.dashing.direction, Size = Vector3.new(5,5,5)})
		alignPos.Responsiveness = 5
		alignPos.ApplyAtCenterOfMass = true
		alignPos.Parent = attacker_hrp
		Debris:AddItem(alignPos, context.dashing.lifetime)
		Debris:AddItem(attachmentAlignPos, context.dashing.lifetime)
```
If attacker_hrp suddenly collide with another basepart it fails to the ground.
The issue that worry me the most though is another one, in some cases where i uses the knockback, the knocked back guy falls from the ground, reaching since -500 Y vector: 
```lua
local force = context.knockback
local mass = defender_hrp.AssemblyMass
local normalizedForce = force * mass
local offset = enemy.CFrame.RightVector * 2 -- sideways
	enemy:ApplyImpulseAtPosition(force, enemy.Position + offset)
local attachment = enemy:FindFirstChildOfClass("Attachment")

	local av = Instance.new("AngularVelocity")
	av.Attachment0 = attachment
	av.MaxTorque = math.huge
	av.AngularVelocity = angularVel
	av.RelativeTo = Enum.ActuatorRelativeTo.World
	av.Parent = enemy

	Debris:AddItem(av, 0.25)
	Debris:AddItem(attachment, 0.25)
```
Can you help me to understand why this two things happen?