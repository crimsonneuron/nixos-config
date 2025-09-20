import subprocess as sp

class output_type:
    def __init__(self, common_name, wpctl_name, sink):
        self.common_name =common_name
        self.wpctl_name=wpctl_name
        self.sink=sink
    def __repr__(self):
       return self.common_name+" "+self.wpctl_name+" "+format(self.sink)
#"common_name": "wpctl_name", "sink" (initialized to zero, changed later)
choices = [output_type("Headphones","Crusher Evo", 0), output_type("Monitor 2", "Navi 31 HDMI/DP Audio Digital Stereo (HDMI 2)",0)]
def get_choice():
    choice_string = ""
    for choice in choices:
        choice_string+=choice.common_name
        choice_string+="\n"
    echo = sp.Popen(["echo", choice_string],stdout=sp.PIPE)
    p1 = sp.Popen(["fuzzel", "--dmenu", "--prompt \"Output\""], stdin=echo.stdout, stdout=sp.PIPE)
    return p1.communicate()[0].decode('utf-8').strip()

def get_sinks():
    p1 = sp.Popen(["wpctl", "status"],stdout=sp.PIPE)
    output = p1.communicate()[0].decode('utf-8').strip().splitlines()
    output = output[output.index(" ├─ Sinks:")+1:output.index(" ├─ Sources:")]
    for source in choices:
        for line in output:
            if source.wpctl_name in line:
                line_chars = list(line)
                number= ""
                for char in line_chars:
                    if char.isnumeric():
                        number+=char
                    if char == '.':
                        break
                source.sink = int(number)

if __name__ == "__main__":
    choice = get_choice()
    if choice != "":
        index = 0
        for i in range(0,len(choices)):
            if choices[i].common_name == choice:
                index =i
                break
        get_sinks()
        sp.Popen(["wpctl","set-default", format(choices[index].sink)])

