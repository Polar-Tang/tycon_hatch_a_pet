All the attachments should inherit the wheel rotation. To make things easy set pivot orientation as 0,0,0 and CFrame orientation as 0,0,0.
![[Pasted image 20260305162859.png]]
The green square is the pvinstance attachments parents
Now set Attachments orientation

Great detective work. Let me break down exactly what's happening.

---

## The Rotation Axis of a CylindricalConstraint

The CylindricalConstraint rotates **Attachment1 around the Axis of Attachment0**. Not the X axis directly — the **Axis property**, which in Roblox attachments corresponds to the **Y axis** of the attachment CFrame (the green arrow).

```
Attachment0.Axis = (0, 1, 0)  ←  this is the rotation axis
```

So the wheel spins around the world **Y direction** of Attachment0... but wait, that's straight up. That would spin the wheel like a top, not like a car wheel.

---

## Why It Actually Works — The Orientation Trick

Look at Attachment0:

```
Axis          = (0,  1,  0)   ← green arrow, points UP in local space
SecondaryAxis = (-1, 0,  0)   ← 
Orientation   = (0,  0, 90)   ← rotated 90 degrees on Z
```

The `Orientation = (0, 0, 90)` rotates the entire attachment 90 degrees, which means what was pointing **up (Y)** is now pointing **sideways through the axle (X world direction)**. So after the rotation is applied, `Axis` ends up pointing **through the wheel hub left-to-right** in world space.

```
Before rotation:  Axis points UP        (0, 1, 0)
After Z+90 rot:   Axis points SIDEWAYS  (1, 0, 0) or (-1, 0, 0)
```

That is your actual spin axis — through the axle, exactly right.

---

## What Attachment1 Does

```
Axis          = (-1, 0, 0)
SecondaryAxis = ( 0, 1, 0)
Orientation   = (0, -180, 0)
```

`CurrentAngle` measures the angle between **Attachment0's secondary axis** and **Attachment1's secondary axis**, around the rotation axis. Attachment1 is essentially the **reference point** that the constraint measures rotation from and applies torque to. When `AngularVelocity` is set, the engine drives Attachment1 to rotate around Attachment0's axis at that speed — which rotates the wheel part with it since the attachment is parented to the wheel.

---

## The Perpendicular Axes — Why It's Intentional

```
Attachment0 Axis = (0,  1, 0)  after orientation → points through axle
Attachment1 Axis = (-1, 0, 0)  points through axle opposite direction
```

They are anti-parallel (opposite directions of the same axis), not truly perpendicular. This is why FL uses `-angularVelocity` and FR uses `+angularVelocity` — the axis direction is flipped left-to-right, so you invert the sign to get both wheels rolling forward.

---

## Your Rear Wheel Problem

Your rear `Mount.MotorAttachment` almost certainly has a different orientation than the Knuckle one. The fix is to make sure it matches exactly:

```
Mount.MotorAttachment:
    Orientation = (0, 0, 90)   ← must match Knuckle.MotorAttachment
    Axis        = (0, 1, 0)
    SecondaryAxis = (-1, 0, 0)
```

Check the rear `Mount.MotorAttachment` orientation in Studio right now — if its `Orientation` is `(0, 0, 0)` instead of `(0, 0, 90)`, that single missing 90 degree rotation is your entire problem. The axis would be pointing up instead of through the axle, spinning the rear wheels like tops instead of rolling them forward.