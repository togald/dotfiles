Config { font = "xft:droid sans:size=8"
       , bgColor = "black"
       , fgColor = "white"
       , position = TopSize C 180 16
       , lowerOnStart = True
       , commands = [ Run BatteryP ["BAT0","BAT1"] ["-t","<acstatus> <left>% (<timeleft>)","-L","20","-H","80","--","-O", "<fc=green>AC</fc>", "-o", "<fc=yellow>BATT</fc>","-l","red","-m","yellow","-h","green"] 50
                    , Run Cpu ["-L","20","-H","70","-l","green","-n","yellow","-h","red"] 10
                    , Run Memory ["-t","Mem: <usedratio>%","-L","20","-H","70","-l","green","-n","yellow","-h","red"] 10
                    , Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
                    , Run StdinReader
                    , Run ThermalZone 1 ["-t","Temp: <temp>̣C","-L","60","-H","80","-l","green","-n","yellow","-h","red"] 30
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "                        %StdinReader% }{ %cpu% %thermal1% | %memory% | %battery% | <fc=#1793d1>%date%</fc> "
       }
