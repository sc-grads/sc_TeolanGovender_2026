import sys

def welcome_message() -> None:
    print('Welcome to groceries')
    print('Enter: ')
    print('------------------------')
    print('1 - To add an item')
    print('2 - to remove an item')
    print('3 - to list all items')
    print('0 - Exit')
    print('------------------------')

def add_item(item: str, groceries: list[str]) -> None:
    groceries.append(item)
    print(f'{item} added')

def remove_item(item: str, groceries: list[str]) -> None:
    try:
        groceries.remove(item)
        print(f'{item} removed')
    except ValueError:
        print(f'{item} not found')

def display(groceries: list[str]) -> None:
    print('___LIST___')
    for i, item in enumerate(groceries):
        print(f'{i}. {item.capitalize()}')

    print('_' * 10)

def is_an_option(text: str) -> bool:
    return text in ['1', '2', '3', '0']

def main() -> None:
    groceries: list[str] = []

    welcome_message()
    while True:
        user_input: str = input('Choose: ').lower()

        if not is_an_option(user_input):
            print('Invalid option...')
            continue

        if user_input == '1':
            new_item: str = input('Enter new item: ').lower()
            add_item(new_item, groceries)
        elif user_input == '2':
            item_to_remove: str = input('Enter item to remove: ').lower()
            remove_item(item_to_remove, groceries)
        elif user_input == '3':
            display(groceries)
        elif user_input == '0':
            print('Goodbye!')
            sys.exit()

if __name__ == '__main__':
    main()