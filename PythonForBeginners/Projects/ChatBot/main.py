import sys
from datetime import datetime

def get_response(text: str) -> str:
    lowered: str = text.lower()

    if lowered in ["hello", "yo", "hi", "hey"]:
        return "hey there"
    elif "how are you" in lowered: # in keyword performs membership check - 'how are you' is typed then it will evaluate as true
        return "i am good thanks"
    elif "your name" in lowered:
        return "My name is: Bot :D"
    elif "time" in lowered:
        current_time: datetime = datetime.now()
        return f"the time is {current_time:%H:%M}"
    elif lowered in ["bye", "see you", "goodbye"]:
        return "It was nice talking to you"
    else:
        return f"I don't understand: '{text}'."

name: str = input("Welcome to the bot! What is your name?: ")
print(f"Bot: Hello {name}, it is a pleasure to meet you! Ask me a question")

while True:

    user_input: str = input("You: ")

    if user_input == 'exit' :
        print("Goodbye!")
        sys.exit()

    bot_response: str = get_response(user_input)
    print(f"Bot: {bot_response}")