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

print("--------------------------------------------------")

#Intersection
art = {"Bob", "Jen", "Rolf", "Charlie"}
science = {"Bob", "Jen", "Adam", "Anne"}

both = art.intersection(science)
print(both)