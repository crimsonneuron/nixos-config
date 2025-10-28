import sys
import tty
import termios

def getch():
    """Get a single character from stdin (Unix/Linux/Mac)"""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch

def format_greek(s):
    output_string = ""
    thisdict = {
      "brand": "Ford",
      "electric": False,
      "year": 1964,
      "colors": ["red", "white", "blue"]
    } 
    lookup_table = {
        "a": "α",
        "b": "β",
        "g": "γ",
        "d": "δ",
        "e": "ε",
        "z": "ζ",
        "h": "η",
        "th": "θ",
        "i": "ι",
        "k": "κ",
        "l": "λ",
        "m": "μ",
        "n": "ν",
        "x": "ξ",
        "o": "ο",
        "p": "π",
        "r": "ρ",
        "s": "σ",
        "t": "τ",
        "u": "υ",
        "ph": "φ",
        "ch": "χ",
        "ps": "ψ",
        "w": "ω",
        "A": "Α",
        "B": "Β",
        "G": "Γ",
        "D": "Δ",
        "E": "Ε",
        "Z": "Ζ",
        "H": "Η",
        "TH": "Θ",
        "I": "Ι",
        "K": "Κ",
        "L": "Λ",
        "M": "Μ",
        "N": "Ν",
        "X": "Ξ",
        "O": "Ο",
        "P": "Π",
        "R": "Ρ",
        "S": "Σ",
        "T": "Τ",
        "U": "Υ",
        "PH": "Φ",
        "CH": "Χ",
        "PS": "Ψ",
        "W": "Ω", 
    }

    combining_dict = {
        "\'" : u'\u0314' ,
        "\"" : u'\u0313',
        "`" : u"\u0301",
        "~" : u"\u0302",
    }

    for index,char in enumerate(s):
        if (char == 'h' or char == 'H"') and s[index-1]+char in lookup_table:
            output_string = output_string[:-1]
            output_string+=lookup_table[s[index-1]+char]
        elif (char == "s" or char == "S") and (index==len(s)-1 or s[index+1]== " "):
            output_string += "ς"
        elif char in lookup_table:
           output_string+=lookup_table[char] 
        elif char in combining_dict:
            output_string+=combining_dict[char]
        else:
            output_string+=char

    return output_string

def main():
    user_input =""
    while(True):
        char= getch()
        user_input+=char
        result = format_greek(user_input)
        if ord(char) == 3:
            print()
            break

        if char == "\x0D":

            print(f"\n{result}")
            break

        if char == "\x7f":
            user_input = user_input[:-2] #because the backspace character is including silently, so -1 doesn't work

        sys.stdout.write('\r')
        sys.stdout.write('\033[J')
        sys.stdout.write(f"{user_input}\n")
        sys.stdout.write(f"{result}")
        sys.stdout.write('\033[1A')  # Up and to beginning
        sys.stdout.write("\r")
        sys.stdout.write(f"{user_input}")        
        sys.stdout.flush()

if __name__ == "__main__":
    main()

