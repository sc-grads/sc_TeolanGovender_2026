import string

def is_letters_only(text: str) -> None:
    alphabet: str = string.ascii_letters + " " # prints all the letters

    for char in text:
        if char not in alphabet:
            raise ValueError('Text can only contain letters from the Alphabet')

    print(f"'{text}' is letters only - nice")

def main() -> None:
    while True:
        try:
            user_input: str = input("Check text: ")
            is_letters_only(user_input)
        except ValueError:
            print("Please enter only letters only")
        except Exception as e:
            print(f'Encountered exception: {type(e)}{e}')

main()