name = "Bob"
print(f"Hello, {name}")
name = "Rolf"
print(f"Hello, {name}")

name2 = "Bob"
greeting = "Hello, {}"
with_name = greeting.format(name2)
with_name_two = greeting.format("Rolf")

print(with_name)
print(with_name_two)