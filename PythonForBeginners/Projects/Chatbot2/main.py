from random import choice
from datetime import datetime
from urllib import response


class ChatBot:
    def __init__(self, name: str, age: int) -> None:
        self.name = name
        self.age = age

    def get_description(self) -> str:
        return f'{self.name} is a bot who is {self.age} years old'

    def get_response(self, text: str) -> str:
        lowered: str = text.lower()

        if 'hello' in lowered:
            return f'{self.name}: Hello!'
        elif 'bye' in lowered:
            return f'{self.name}: Bye!'
        elif 'how old are you' in lowered:
            return f'{self.name}: i am {self.age} years old'
        elif 'what time is it' in lowered:
            now: datetime = datetime.now()
            return f'{self.name}: It is {now:"%H:%M:%S"}'
        elif 'how are you' in lowered:
            return f'{self.name}: I am great thanks'
        else:
            random_response: list[str] = ['I do not understand',
                                          'Would you mind rephrasing that',
                                          'What?',
                                          'Ah, What?']
            return f'{self.name}: {choice(random_response)}'

    def run(self) -> None:
        while True:
            user_input: str = input('you: ')
            if user_input == 'exit':
                print(f'thank you for chatting with {self.name}!')
                break

            response: str = self.get_response(user_input)
            print(response)

def main() -> None:
    mario: ChatBot = ChatBot('Mario', age=20)
    print(mario.get_description())
    mario.run()

if __name__ == '__main__':
    main()