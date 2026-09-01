#difference
friends = {"Bob", "Rolf", "Anne"}
abroad = {"Bob", "Rolf"}

localFriends = friends.difference(abroad)
print(localFriends)

print("--------------------------------------------------")

#Union
local = {"Anne"}
abroad = {"Bob", "Rolf"}

Friends = local.union(abroad)
print(Friends)