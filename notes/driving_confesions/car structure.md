I finally rearrange most of the attachment but they aren't well aligned. I wonder about the following constraints so i want to understand them and know why these classes are utilized to simulate the car phisiscs mechanic. Here comes the list from the current classes and some usefult notes about the notation, for example suffix, SUFFIX, the case may vary, they represent "FR", "FL", "RR", "RL" meaning that for every somethingSUFFIX there are 
somethingFR
somethingFL
somethingRR
somethingRL
and F or R there are 
somethingF
somethingR

Car
[-] Redress<Folder>.RedressOrientation <AlignOrientation>
    (oneAttachment mode)
    Attachment0 = chassis.Flipper
[.] SteeringRack<Part>.SteeringRack <PrismaticConstraint>
    Attachment0 = Chassis.SteerAtt
    Attachment1 = SteeringRack.SteerAtt
    moves steering rack attachment to left or right
[-] Suspension<Folder>.SuspensionSUFFIX <SpringConstraint>
    Attachment0 = wheelMountSUffix.Mount.SpringAtt
    Attachment1 = wheelMountSUffix.Wheel.SpringAtt
[-] Engine<Folder>.WheelSuffixMotor <CylindricalConstraint>
    Attachment0 = if suffix.startWith("f") WheelSuffix.Knuckle.MotorAtt else WheelSuffix.Mount.MotorAtt
    Attachment1 = Wheels.WheelSuffix.Wheel
[-] Wheels<Folder>.WheelSUFFIX.Knuckle.HingeConstraint <HingeConstraint>
     Knuckle is holding the wheel hub and it rotated on Y by the steering rack, it allows wheels to rotate on Y axis while the wheel hub keeps spinning the wheels, that's why there are knuckles in the FR and FL wheel, they needs to steer and the hinge contraint is perfect for this task
    Attachment0 =  Wheels.Mount.HingeAtt
    Attachment1 = Wheels.Knuckle.HingeAtt
[-] SteringRack<Part>.RodConstraint <RodConstraint>
    Attachment0 = SteringRack[left or Right]RodAttachment
    Attachment1 = wheel[left or Right].Knuckle.SteeringAttachment
[-] Antirrol[F or R]<Part>.HingeConstraint <HingeConstraint>
     hinge constraint enforces the attachment distance and keep the constrained, locks all the axes except the rotational axes
    Attachment0 = chassis.AntiRollAttachment
    Attachment1 = Antirrol[F or R].AntiRollAttachment
[-] Antiroll<Folder>.AntirollSufix <SpringAttachment>
    Attachment0 = Antirrol[F or R].[left or right]SpringAttachment
    Attachment1 = wheelSufix.Wheel.MotorAtachment

- SteeringRack



The back wheels are spining by the wrong axis and i cannot understand why. Engine.WheelSuffixMotor is basically where the max torque is fully applied and it rotates the wheel which moves the car by the friction
```
local angularVelocity = studsSpeed / self._wheelRadius
	-- Update the wheel motor constraints
	local engine = self.engine
	engine.WheelFRMotor.AngularVelocity = angularVelocity
	engine.WheelFRMotor.MotorMaxTorque = torque
	engine.WheelFLMotor.AngularVelocity = -angularVelocity
	engine.WheelFLMotor.MotorMaxTorque = torque
	if handBrakeInput then
		engine.WheelRRMotor.AngularVelocity = 0
		engine.WheelRRMotor.MotorMaxTorque = self._engineParameters.handBrakeTorque
		engine.WheelRLMotor.AngularVelocity = 0
		engine.WheelRLMotor.MotorMaxTorque = self._engineParameters.handBrakeTorque
	else
		engine.WheelRRMotor.AngularVelocity = angularVelocity
		engine.WheelRRMotor.MotorMaxTorque = torque
		engine.WheelRLMotor.AngularVelocity = -angularVelocity
		engine.WheelRLMotor.MotorMaxTorque = torque
	end
```
So it applies a torque to a CylindricalConstraint which attempts to rotate the attachments with the goal of reaching its AngularVelocity (cylindrical motor actuator type definition) now i can only wonder to rotate to what direction? i tried to change the attacment axis or cframe world rotation but i'm not sure if the rotation by itself is wrong or the rotations needs to be slighlty aligned with wheel<Part> orientation

OtherQuestions:
, this rotattes all along the X axis. Engine.WheelSuffixMotor is a prismatic constraint, what is the prismatic constraint and why is necesary to be this engine class to recreate this car mechanic?