#We want to do a couple of things
#basic is just sending output to qalc and copying that.
#God this may be difficult
import subprocess

def io():
    p1 = subprocess.Popen(["cat", "/home/crimson/.cache/tofi-calc/history.txt"], stdout=subprocess.PIPE)
    p2 = subprocess.Popen(["tofi", "--prompt-text=Calc: ", "--require-match=false", "--font=/home/crimson/.nix-profile/share/fonts/truetype/NerdFonts/FantasqueSansM/FantasqueSansMNerdFont-Regular.ttf"], stdin=p1.stdout, stdout=subprocess.PIPE)

    p1.stdout.close()
    operation = p2.communicate()[0].decode('utf-8').strip()
    if operation == "":
       return 

    if operation.startswith("approx"):
        operation = operation.replace("approx","")
        p3 = subprocess.run(["qalc","-t","--defaults",operation],capture_output=True)
    else:
        p3 = subprocess.run(["qalc","-t","-s","exact",operation],capture_output=True)
    result = p3.stdout.decode('utf-8').strip()

    subprocess.run(["wl-copy", result])
    subprocess.run(["notify-send", result, "Copied to clipboard"])
    history(operation)

def history(operation):
    path = "/home/crimson/.cache/tofi-calc/history.txt"
    with open(path,'r') as f:
        lines = f.readlines()

        lines.insert(0, operation+"\n")
        trimmed_lines = lines[:5]

        with open(path, "w") as f:
            f.writelines(trimmed_lines)
        

io()
