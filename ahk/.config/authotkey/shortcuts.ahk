; #############################################
; Email Shortcuts
; #############################################

; Email shortcut with Ctrl+@
^@::
Send, owen.pinguenet@protonmail.com
return

; Uni Email shortcut with Ctrl+Shift+@
^!@::
Send, s4406770@glos.ac.uk

; #############################################
; Obsidian shortcuts
; #############################################

; Obsidian shortcut with Ctrl+~
^~::
Send, ^p
Send, insert template
Send, {Enter}
Send, date created
Send, {Enter}
return

; ##############################################
; Volume Control Shortcuts
; #############################################

Alt & WheelUp::Volume_Up
Alt & WheelDown::Volume_Down
Alt & MButton::Volume_Mute

; #############################################
; Application Shortcuts
; #############################################

; Windows Terminal shortcut with Ctrl+Alt+T
^!t::
if (FileExist("C:\Program Files\Alacritty\alacritty.exe"))
    Run, alacritty.exe
else
    Run, wt.exe
return

; Open web browser with Ctrl+Alt+B
^!b::
Run, zen.exe

; Open Obsidian with Ctrl+Alt+O
^!o::
Run, obsidian://open?vault=General