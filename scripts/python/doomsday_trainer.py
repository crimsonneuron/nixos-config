#!/usr/bin/env python3
"""
Doomsday Algorithm Trainer
Practice computing the day of the week for random dates (1583 onward,
i.e. Gregorian calendar only -- no Julian calendar quirks).
"""

import random
import datetime
import time

WEEKDAYS = ["Monday", "Tuesday", "Wednesday", "Thursday",
            "Friday", "Saturday", "Sunday"]

# Accept short forms too: mon, tue, wed, thu, fri, sat, sun
ABBREV = {day[:3].lower(): day for day in WEEKDAYS}


def random_date(start_year=1583, end_year=2399):
    year = random.randint(start_year, end_year)
    month = random.randint(1, 12)
    # figure out valid day range for that month/year
    if month == 12:
        next_month = datetime.date(year + 1, 1, 1)
    else:
        next_month = datetime.date(year, month + 1, 1)
    days_in_month = (next_month - datetime.date(year, month, 1)).days
    day = random.randint(1, days_in_month)
    return datetime.date(year, month, day)


def normalize(answer):
    answer = answer.strip().lower()
    if answer in ABBREV:
        return ABBREV[answer]
    for day in WEEKDAYS:
        if day.lower() == answer:
            return day
    return None


def main():
    print("=" * 50)
    print("Doomsday Algorithm Trainer")
    print("Dates are Gregorian only (year 1583 onward).")
    print("Type full weekday name or 3-letter abbreviation (e.g. 'wed').")
    print("Type 'q' at any time to quit.")
    print("=" * 50)

    score = 0
    total = 0
    times = []

    while True:
        d = random_date()
        prompt = f"\nWhat day of the week was {d.strftime('%B %-d, %Y')}? "
        start = time.time()
        try:
            raw = input(prompt)
        except EOFError:
            break
        elapsed = time.time() - start

        if raw.strip().lower() in ("q", "quit", "exit"):
            break

        guess = normalize(raw)
        actual = WEEKDAYS[d.weekday()]
        total += 1

        if guess == actual:
            score += 1
            times.append(elapsed)
            print(f"Correct! ({elapsed:.1f}s)")
        else:
            shown = guess if guess else f"'{raw}' (not recognized)"
            print(f"Nope -- you said {shown}, actual answer is {actual}.")

        print(f"Score: {score}/{total}")

    if total > 0:
        print("\n" + "=" * 50)
        print(f"Final score: {score}/{total} ({100 * score / total:.0f}%)")
        if times:
            avg = sum(times) / len(times)
            print(f"Average time per correct answer: {avg:.1f}s")
    print("Goodbye!")


if __name__ == "__main__":
    main()
