import random


MAX_ATTEMPTS = 5


def get_user_guess():
    while True:
        try:
            guess = int(input("Enter your guess (1-100): "))
            if 1 <= guess <= 100:
                return guess
            print("Please enter a number between 1 and 100.")
        except ValueError:
            print("Please enter a valid integer.")


def play_guessing_game():
    secret = random.randint(1, 100)

    for attempt in range(1, MAX_ATTEMPTS + 1):
        print(f"\nAttempt {attempt} of {MAX_ATTEMPTS}")
        guess = get_user_guess()

        if guess == secret:
            print("Congratulations! You guessed the right number.")
            return
        elif guess > secret:
            print("Too high!")
        else:
            print("Too low!")

    print(f"Sorry, you've run out of attempts. The correct number was {secret}.")


if __name__ == "__main__":
    play_guessing_game()
