class Alphabet:
    def __init__(self, lang, letters):
        self.lang = lang
        self.letters = letters

    def print(self):
        print(self.letters)

    def letters_num(self):
        return len(self.letters)


class EngAlphabet(Alphabet):
    _letters_num = 26

    def __init__(self):
        super().__init__("En", "abcdefghijklmnopqrstuvwxyz")

    def letters_num(self):
        return EngAlphabet._letters_num

    def is_en_letter(self, letter):
        return letter.lower() in self.letters

    @staticmethod
    def example():
        return "The quick brown fox jumps over the lazy dog."


if __name__ == "__main__":
    eng = EngAlphabet()

    eng.print()
    print(eng.letters_num())
    print(eng.is_en_letter("F"))
    print(eng.is_en_letter("Щ"))
    print(eng.example())
