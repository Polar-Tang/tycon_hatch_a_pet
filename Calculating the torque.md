### THe method from roblox template to steer
So this is from a code example from roblox team, i'm analyzing it to learn mode about racing logic, specifically how to spin the wheels. This file is from the Car model
checking on `updateEngine`, let's see a summarized version from the function:
```lua
-- Car/Scripts/Server/Controllers.luau
local wheelRadius = wheelParts[1].Size.Y / 2

local function updateEngine(deltaTime: number)
	local engineSpeed = engine:GetAttribute(Constants.ENGINE_SPEED_ATTRIBUTE)

	local chassisSpeed = getChassisForwardSpeed()
	local torqueAlpha = math.min(chassisSpeed, maxSpeed) / maxSpeed

	local studsSpeed = Units.milesPerHourToStudsPerSecond(engineSpeed)
	local angularVelocity = studsSpeed / wheelRadius
	
	engine.WheelFRMotor.AngularVelocity = angularVelocity
	engine.WheelFRMotor.MotorMaxTorque = torque
	engine.WheelFLMotor.AngularVelocity = -angularVelocity
	engine.WheelFLMotor.MotorMaxTorque = torque
```
Angular velocity get by studs per second divided wheel radius. Interesting.
```lua
local car = script.Parent.Parent
local steering = car.Steering -- Stering.SteringRack is a PrismaticContraint

local function updateSteering()
	-- Get attribute fast replication
	local steeringInput = math.clamp(inputs:GetAttribute(Constants.STEERING_INPUT_ATTRIBUTE), -1, 1)
	-- idk the phisics logic behind this
	local maxSpeed = math.max(engineParameters.forwardMaxSpeed, engineParameters.reverseMaxSpeed)
	-- realtime speed
	local speed = math.min(getChassisForwardSpeed(), maxSpeed)
	-- Steering is reduced at higher speeds to provide smoother handling
	local steeringFactor = math.max(1 - (speed / maxSpeed) * steeringParameters.steeringReduction, 0)
	local steeringAmount = steeringInput * steeringFactor

	-- this is left or right, isn't it?
	if steeringAmount > 0 then
		steering.SteeringRack.TargetPosition = steeringAmount * steering.SteeringRack.LowerLimit
	else
		steering.SteeringRack.TargetPosition = -steeringAmount * steering.SteeringRack.UpperLimit
	end
end
```
These two function are called per frame during Car:Update()
```lua
function Controller:update(deltaTime: number)
	updateNitro(deltaTime)
	updateEngine(deltaTime)
	updateSteering()
	updateWheelFriction()
end
```
You were right that only front wheels rotate, i have car license even though i don't realize it rn, the four wheels have ActuatorType motor and are Cylindrical constraints, however `updateSteering` changes the SteringRack's properties, a PrismaticContraint with actuator type set to Servo


Okay so this is my implementation to steer the cart wheels, i will commit my chain of though
uses this function
```
local function getChassisForwardSpeed(): number
	local relativeVelocity = chassis.CFrame:VectorToObjectSpace(chassis.AssemblyLinearVelocity)
	local milesPerHour = Units.studsPerSecondToMilesPerHour(-relativeVelocity.Z)
	return milesPerHour
end
```

So in order to understand this i will go documenting it. First i will talk about the roblox car building. As we aim to replicate the wheel rotation functionallity let's start talking about wheels, besides the part with the weld constraints and the models there are two importants parts that are not visible, **they are functional**. These part is **Mount**, above the wheel and the **knuckle** which is a likelly inside the wheel those are the position let's see their descendants 

##### Knuckle
HingeAttachment
HingeConstraint
MotorAttachment
SteeringAttachment

###### Mount
HingeAttachment
SpringAttachment
WeldConstraint

The attachments are likelly used to different constraints. For steering the wheels in our car we likelly we'll use SteeringAttachment and probably HingeAttachment. HingeConstraint constrains its attachments to rotate about a single axis and attachment0 is Mount.HingeAttachment and attachment1 is Knuckle.HingeAttachment, does this mean that Mount and knuckle rotates the same?
On the other hand Mount.WeldConstraint has part0 set to chasis and part1 is Mount, but i guess those are just joints

Now lets see SteeringRack
##### SteeringRack
LeftRodAttachment
RightRodAttachment
RodConstraint
RodConstraint
SteeringAttachment

A rodConstraint keeps two attachments separated by its defined Length and in this case those attachments are RightRodAttachment as 0 and Knuckle.SteeringAttachment (idk why) also RightRodAttachment has a cframe of 1,0,0 and LeftRodAttachment -1,0,0 and SteeringAttachment 0,0,0 thereby both RodAttachments has 1 stud of length. 
Finally SteeringRack, a PrismaticConstraint got attachment0 Chasis.SteeringAttachment and part1 SteeringRack.SteeringAttachment.
The understanding for this is at the tip of my tongue. The prismatic constraint, with servo motor, moves steering rack and it moves the wheels too, however i still dont get why he uses Chasis.SteeringAttachment