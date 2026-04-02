name: str = input("Enter a name: ")
nounA: str = input("Enter a noun: ")
verbA: str = input("Enter a verb: ")
nounB: str = input("Enter a noun: ")
verbB: str = input("Enter a verb (past tense): ")
numberA: str = input("Enter current year: ")
numberB: str = input("Enter year born: ")

# the f converts the string into a formatted string which means you can insert pyton code with {}
story: str = f"""
--------------------------------------------------------------------------------------------------------------
This is a story about {name}, a strong (and beautiful) {nounA} who loved to {verbA}.
{name} once {verbB} and won a {nounB} as a prize.
Today name is {name} is {int(numberA) - int(numberB)}  years old and has retired from all adventures.

the end
--------------------------------------------------------------------------------------------------------------
"""

print(story)