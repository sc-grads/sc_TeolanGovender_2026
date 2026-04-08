from dataclasses import dataclass, field
from uuid import uuid4, UUID

@dataclass
class Note:
    id: UUID = field(init=False)
    title: str
    body: str

    def __post_init__(self) -> None:
        self.id = uuid4()

class NoteApp:
    def __init__(self, author: str, notes: list[Note] | None = None) -> None:
        self.notes = notes

        if notes is None:
            self.notes = []
        else:
            self.notes = notes

        self.displayInstructions()

    @staticmethod
    def displayInstructions() -> None:
        print('Welcome to Notes!')
        print('Here are the commands')
        print('1 - Add new note')
        print('2 - Edit note')
        print('3 - Delete note')
        print('4 - Display all notes')

    def addNote(self) -> None:
        title = input('Title: ')
        body = input('Body: ')

        note: Note = Note(title, body)
        self.notes.append(note)
        print('Note added!')

    def editNote(self) -> None:
        print('Which note would you like to edit?')
        self.showNotes()

        try:
            noteIndex: int = int(input('Index: ')) - 1
            current: Note = self.notes[noteIndex]

            newTitle: str = input('New title: ')
            newBody: str = input('New body: ')
            print('Note edited!')

            current.title = newTitle
            current.body = newBody
        except IndexError:
            print('Invalid index!')
            self.editNote()
        except ValueError:
            print('Index cannot be empty')
            print('Aborting operation')

    def deleteNote(self) -> None:
        print('Which note would you like to delete?')
        self.showNotes()

        try:
            noteIndex: int = int(input('Index: ')) - 1
            del self.notes[noteIndex]
            print('Note deleted!')
        except IndexError:
            print('Invalid index!')
            self.deleteNote()
        except ValueError:
            print('Index cannot be empty')
            print('Aborting operation')


    def showNotes(self) -> None:
        if not self.notes:
            print('No notes added!')
            return

        for i, note in enumerate(self.notes, start=1):
            print(f'{i}. {note.title} - {note.body}')

    def selectOption(self, userInput: str) -> None:
        if userInput not in ['1', '2', '3', '4']:
            print('Invalid option?')
            return

        if userInput == '1':
            self.addNote()
        elif userInput == '2':
            self.editNote()
        elif userInput == '3':
            self.deleteNote()
        elif userInput == '4':
            self.showNotes()

    def runApp(self) -> None:
        while True:
            user = input('You: ')
            self.selectOption(user)

def main() -> None:
    sampleNotes: list[Note] = [Note(title='Title 1', body='Clean the pool'),
                               Note(title='Title 2', body='Clean the table')]

    noteApp: NoteApp = NoteApp(author='Bob', notes=sampleNotes)
    noteApp.runApp()

if __name__ == '__main__':
    main()