local function getDrop(luck)
	local L = math.clamp(luck, 1, 5)

    local u = math.random()

    -- core idea
    local skewed = u ^ (1 / L)

    -- optional stabilization
    local alpha = 0.7
    local result = (1 - alpha) * u + alpha * skewed

    return result * 100
end


print("bias: 0.5 ", getDrop(0.5))
print("bias: 0.5 ", getDrop(0.5))
print("bias: 0.5 ", getDrop(0.5))
print("=======================")
print("bias: 1 ", getDrop(1))
print("bias: 1 ", getDrop(1))
print("bias: 1 ", getDrop(1))
print("=======================")
print("bias: 1.5 ", getDrop(1.5))
print("bias: 1.5 ", getDrop(1.5))
print("bias: 1.5 ", getDrop(1.5))
print("=======================")
print("bias: 2 ", getDrop(2))
print("bias: 2 ", getDrop(2))
print("bias: 2 ", getDrop(2))
print("=======================")
print("bias: 2.5 ", getDrop(2.5))
print("bias: 2.5 ", getDrop(2.5))
print("bias: 2.5 ", getDrop(2.5))
print("=======================")
print("bias: 3 ", getDrop(3))
print("bias: 3 ", getDrop(3))
print("bias: 3 ", getDrop(3))
print("=======================")
print("bias: 3.5 ", getDrop(3.5))
print("bias: 3.5 ", getDrop(3.5))
print("bias: 3.5 ", getDrop(3.5))
print("=======================")
print("bias: 4 ", getDrop(4))
print("bias: 4 ", getDrop(4))
print("bias: 4 ", getDrop(4))
print("=======================")
print("bias: 4.5 ", getDrop(4.5))
print("bias: 4.5 ", getDrop(4.5))
print("bias: 4.5 ", getDrop(4.5))
print("=======================")
print("bias: 5 ", getDrop(5))
print("bias: 5 ", getDrop(5))
print("bias: 5 ", getDrop(5))