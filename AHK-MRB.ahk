; Make a new .ahk file, paste the following and save


; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

; You will have to change your keybinds/settings in OBS to:
; Save Replay - Alt + F10
; Start/Stop Recording - Alt + F11
; Change your Replay Buffer to 300 seconds.
;
; Alternatively you may want to change the keybinds in this script to your liking. Most of the hotkeys are at the bottom.
; For optimal experience, enable this script and open OBS with replay buffer on at system startup.


; How does it work?
;
; Whenever you press Alt + F3, F5, F6 and onwards your replays will be put in a temporary folder with a text file that saves the number of seconds associated with your video clip.
; After you close OBS (or press Alt + S), ffmpeg will start running through those videos, check how many seconds did you save the video for, see if you want it compressed and then it's going to save them on your FinalDirectory.
; This also means that you're committing yourself to using hotkeys instead of buttons on OBS. This is because this script can't detect whenever a new file is added automatically, and you wouldn't be able to save your replay with a custom length either way.

; How to use
;
; Default controls include:
; 	Saving
; Alt + F2, F3, F5, F6, F7, F8, F9 and F10 (save last 8, 20, 30, 45, 60, 120, 180 or 300 seconds respectively)
; Alt + F11 (Start/Stop Recording)
; Alt + F12 (Custom replay seconds)
; Alt + S (Force Video Processing)
;
;	Script management
; Ctrl + Esc (Restart Script)
; Ctrl + L (Stop Script)

; Prerequisites: ffmpeg, download it here: https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z
; Place it inside SetWorkingDir and you'll be good to go!

; Features:
; Get notified if your replay has been saved!
; More replay buffers! Save anywhere between 5 seconds or 20 minutes (or more) of your last gameplay! It's up to you!
; Compress your videos even further with x265!
; Save in different folders depending what app/game are you using/playing!

; Customisable options:
; Files
SetWorkingDir C:\Users\%A_UserName%\Documents        ; Change this to the directory where you have ffmpeg located. (untested yet, if you're having issues set ffmpeg as environment variable)
TemporaryDirectory = D:\Videos\Temporary            	     ; Change this to your temporary videos folder, you want to put the same folder as what's set up on OBS. BE CAREFUL: Selecting a folder with files in it WILL DELETE ALL OF THEM! I'm not responsible for this!
FinalDirectory = D:\Videos                             ; Your Videos folder that you wish to save the videos to.

; Video
; If you're using DaVinci Resolve you may want to use x264 instead of x265 (x265 doesn't work in Resolve without Studio version), enable usex264VerySlow instead.
global recordingFormat := .mkv      ; The file extension of your videos in OBS. Default: .mkv

global x265SecondsThreshold := 0   	; If your replay is shorter than the amount you select here, it will heavily compress your videos (with almost no reduction in quality), in order to see them, you may have to download VLC media player. This process may take up to 10x the length of the video, even more so if your resolution is high. To disable this, change the threshold to 0. Default: 20
global x265Quality := 26            ; Video CRF while converting to x265, the lower the better the quality, however, you should leave as it is as it looks better than the 1440p option on YouTube. Default: 26

global usex264VerySlow := true      ; Alternative to x265, works with DaVinci Resolve, it doesn't use veryslow, but rather medium.
global x264SecondsThreshold := 0    ; Same as x265SecondsThreshold but for x264
global x264Quality := 21            ; Set this to your OBS CRF setting. Default: 21

; Audio
; If you're using DaVinci Resolve you may want to use the libopus audio codec and change the bitrate to 64k or 96k, it should reduce the file size by a bit.
; More information here: https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio
global audioCodec = "libopus"       ; Which audio codec to use? (Recommended values are: libopus, libvorbis, aac and copy (copy just copies the audio codec used in the video without processing it again) Default: "aac"
global audioBitrate = "96k"         ; Select audio bitrate. (Recommended values are: 64k for libopus, 160k for aac) Default: "160k"

; UX (User Experience)
; The default options are recommended with disabled notification banners for AutoHotkey on system settings. You should also add AutoHotkey to priority on Focus Assist so you can hear the notifications while gaming. If you want to keep noise to a minimum, disable enableNotifications.
global showDirWhenDone := false     ; When your videos are done processing, would you want to show FinalDirectory on the notification?                              Default: false
global enableNotifications := true  ; Should your notifications be enabled just to be sure that something saved?                                                    Default: true
global errorNotifications := true   ; Notifications are shown only if there are any issues. This won't have any effect if enableNotifications is true.              Default: true
global errorSoundNotif := true 		; When there's an error make an additional sound.																				Default: true
global soundNotifications := false  ; Should notifications have sound in them? Useful if you can't see the notifications, annoying on recordings/streams though.   	Default: false
global noExplorerInGame := false	; Closes explorer.exe while in-game. If you get stuck and only have the game window open, open task manager via Shift+Ctrl+Escape, it should open explorer this way.    Default: false

; Accessibility
global checkDelay = 3300			; If your videos aren't being shown as being saved even though they are saved, try increasing this delay. (Measured in milliseconds)	Default: 2500
global autoOrganise := true         ; Check if you have a game running, and if so, save the replay to a folder with the name of the game. Apps can work too, but you have to add them yourself at the bottom of the script.     Default: true
global retryCount = 3               ; How many times should it try to detect a new video
global optimiseForDavinci := false  ; Do NOT use this, just click Generate optimized media within DaVinci Resolve. This will generate files 10-25 times larger than x264.     Default: false

; Performance
global scriptTick = 3000			; If your CPU usage is high while this script is running, increase this value.	Default: 2250

; Note that sometimes notifications may not be accurate, they may have wrong or incomplete information. Especially while recording. This happens mostly when the script is restarted.

; DO NOT CHANGE ANY OF THIS OR YOUR SCRIPT WILL NOT WORK OR CAUSE DATA LOSS!
; DO NOT CHANGE ANY OF THIS OR YOUR SCRIPT WILL NOT WORK OR CAUSE DATA LOSS!
; DO NOT CHANGE ANY OF THIS OR YOUR SCRIPT WILL NOT WORK OR CAUSE DATA LOSS!
#SingleInstance, Force
ffmpegrunning := false
obsrunning := false
hasobsran := false
forceSave := false
recordingstarted := false
recordingdelay := false
replaysaving := false
sseofstr := "-sseof -"
isexplorerrunning := true
retryNumber = 0

while true {
    Sleep %scriptTick%

; This part of the script checks if OBS is running and has OBS ever ran. When OBS is closed, open FFmpeg to reduce filesize at below normal priority and save your replay on the amount of seconds you've chosen.
    if ProcessExist("obs64.exe") {
        obsrunning := true
        hasobsran := true
    }
    if !ProcessExist("obs64.exe") {
        obsrunning := false
    }
    if (noExplorerInGame = true)
    {
        currentApp := checkProcessDB()
    }
    if (currentApp = "" and isexplorerrunning = false and noExplorerInGame = true) {
        isexplorerrunning := true
        Run, explorer.exe
    }
    else if (isexplorerrunning = true and not currentApp = "" and noExplorerInGame = true) {
        isexplorerrunning := false
        Run, %comspec% /c "taskkill /f /im explorer.exe",, hide
    }
    if (obsrunning = false and hasobsran = true or forceSave = true) {
        if (ffmpegrunning = false) {
            ffmpegrunning := true
            vidAmount = 0
            if (soundNotifications = true)
            {
                SoundPlay *64
            }
            if (enableNotifications = true)
            {
                TrayTip, Conversion started, Your videos have started converting`, this process may take a while...
            }
            Loop Files, %TemporaryDirectory%\*%recordingFormat%
            {
                SplitPath, A_LoopFileLongPath, , , ,FileName, ; Remove file type extension from string
                Loop, Read, %TemporaryDirectory%\videodictionary.txt
                {
                    Line = %A_LoopReadLine%
                    if (nextLineProcess = true)
                    {
                        folderName = %A_LoopReadLine%
                        if (folderName = "" or folderName = "Video database" or folderName = "nothing") {
                            folderPath = %FinalDirectory%
                        }
                        else {
                            folderPath = %FinalDirectory%\%folderName%
                        }
                        nextLineProcess = false
                    }

                    if (nextLineSeconds = true)
                    {
                        replaySeconds = %A_LoopReadLine%
                        nextLineSeconds = false
                        if (autoOrganise = true) {
                            nextLineProcess := true
                        }
                    }

                    if InStr(Line, FileName)
                    {
                        nextLineSeconds := true
                    }
                }
                sseofstr := "-sseof -"replaySeconds
                if (autoOrganise = true) {
                    LastDirectory = %folderPath%
                    if (!FileExist(LastDirectory)) {
                        FileCreateDir, %LastDirectory%
                    }
                }
                else {
                    LastDirectory = %FinalDirectory%
                }
		        if (replaySeconds <= x265SecondsThreshold and optimiseForDavinci = false)
		        {
                    if (usex264VerySlow = false)
                    {
                        RunWait %comspec% /c "start /belownormal /wait /b ffmpeg -nostdin %sseofstr% -i "%A_LoopFileFullPath%" -map 0:0 -map 0:1? -map 0:2? -map 0:3? -map 0:4? -c:v libx265 -movflags +faststart -crf %x265Quality% -preset medium -ac 0 -c:a %audioCodec% -b:a:0 %audioBitrate% -b:a:1 %audioBitrate% -b:a:2 %audioBitrate% -b:a:3 %audioBitrate% "%LastDirectory%\%FileName%.mp4"",, hide
                    }
		        }
                else if (replaySeconds <= x264SecondsThreshold and optimiseForDavinci = false) {
                    if (usex264VerySlow = true)
                    {
                        RunWait %comspec% /c "start /belownormal /wait /b ffmpeg -nostdin %sseofstr% -i "%A_LoopFileFullPath%" -map 0:0 -map 0:1? -map 0:2? -map 0:3? -map 0:4? -c:v libx264 -movflags +faststart -crf %x264Quality% -preset medium -x264opts opencl -ac 0 -c:a %audioCodec% -b:a:0 %audioBitrate% -b:a:1 %audioBitrate% -b:a:2 %audioBitrate% -b:a:3 %audioBitrate% "%LastDirectory%\%FileName%.mp4"",, hide
                    }
                }
                else if (optimiseForDavinci = true)
                {
                    RunWait %comspec% /c "start /belownormal /wait /b ffmpeg -nostdin %sseofstr% -i "%A_LoopFileFullPath%" -map 0:0 -map 0:1? -map 0:2? -map 0:3? -map 0:4? -c:v mjpeg -q:v 5 -ac 0 -c:a pcm_s16be -q:a:0 0 -q:a:1 0 -q:a:2 0 -q:a:3 0 "%LastDirectory%\%FileName%.mov"",, hide
                }
		        else {
		            RunWait %comspec% /c "start /belownormal /wait /b ffmpeg -nostdin %sseofstr% -i "%A_LoopFileFullPath%" -map 0:0 -map 0:1? -map 0:2? -map 0:3? -map 0:4? -c:v copy -ac 0 -c:a %audioCodec% -b:a:0 %audioBitrate% -b:a:1 %audioBitrate% -b:a:2 %audioBitrate% -b:a:3 %audioBitrate% "%LastDirectory%\%FileName%.mp4"",, hide
		        }
                vidAmount := vidAmount + 1
                IfExist, %LastDirectory%\%FileName%.mp4
                {
		        FileDelete, %A_LoopFileFullPath%
                }
            }
            ffmpegrunning := false
            obsrunning := false
            hasobsran := false
            forceSave := false
            nextLineSeconds := false
            HideTrayTip()
            if (soundNotifications = true)
            {
                SoundPlay *64
            }
            if (enableNotifications = true)
            {
                if (showDirWhenDone = true)
                {
                    TrayTip, Converting done, Your %vidAmount% clips/videos are done processing!`nThey are saved in %FinalDirectory%!
                }
                else
                {
                    TrayTip, Converting done, Your %vidAmount% clips/videos are done processing!
                }
            }
            FileDelete, %TemporaryDirectory%\videodictionary.txt
        }
    }
}

folderChanged(numberOfSeconds:=999999)
{
    global TemporaryDirectory
    global recordingFormat
	global checkDelay
    global autoOrganise
    global retryCount
    global retryNumber

    if (autoOrganise = true) {
        currentProcess := checkProcessDB()
    }
    foundReplay := false
    replaysaving := true
    Sleep %checkDelay%

    if !FileExist(TemporaryDirectory . "\videodictionary.txt")
    {
        FileAppend,Video database, %TemporaryDirectory%\videodictionary.txt
    }

    Loop Files, %TemporaryDirectory%\*%recordingFormat%
    {
        SplitPath, A_LoopFileLongPath, , , ,videoTitle,
        FileRead, videodictionaryStr, %TemporaryDirectory%\videodictionary.txt
        videoDictionaryStrr = videodictionaryStr
        videoTitlee = videoTitle
        if !InStr(%videoDictionaryStrr%, %videoTitlee%)
        {
            if (autoOrganise = true) {
                FileAppend, `n%videoTitle%`n%numberOfSeconds%`n%currentProcess%, %TemporaryDirectory%\videodictionary.txt
            }
            else {
                FileAppend, `n%videoTitle%`n%numberOfSeconds%, %TemporaryDirectory%\videodictionary.txt
            }
            foundReplay := true
            retryNumber = 0
            if (numberOfSeconds < 999999)
            {
                if (soundNotifications = true)
                {
                    SoundPlay *64
                }
                if (enableNotifications = true)
                {
                    TrayTip, Replay saved, Saved %videoTitle%`nfor %numberOfSeconds% seconds.
                }
            }
            else {
                if (soundNotifications = true)
                {
                    SoundPlay *64
                }
                if (enableNotifications = true)
                {
                    TrayTip, Recording detected, Started recording as `n%videoTitle%.
                }
            }
        }
    }
    if (foundReplay = false and retryNumber => retryCount)
    {
		retryNumber = 0
        if (soundNotifications = true or errorSoundNotif = true)
        {
            SoundPlay *16
			Sleep 300
        }
        if (enableNotifications = true or errorNotifications = true)
        {
            TrayTip, Replay has not been saved, No new clip/video has been saved.`nCheck if OBS is running or if Replay Buffer is turned off.
        }
    }
    else if (foundReplay = false and retryNumber < retryCount)
    {
		retryNumber = retryNumber + 1
        folderChanged(%numberOfSeconds%)
    }
    replaysaving := false
}

ProcessExist(Name) {
	Process,Exist,%Name%
	return Errorlevel
}

ReplayNotSavedPrompt() {
    if (soundNotifications = true)
    {
        SoundPlay *16
		Sleep 300
    }
    if (enableNotifications = true or errorNotifications = true)
    {
        TrayTip, Replay has not been saved, Replay has not been saved!`n`nDon't save a replay immediately after starting a recording!
    }
}

HideTrayTip(timeForSleep := 300) {
    Sleep %timeForSleep%
    TrayTip
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 220
        Menu Tray, Icon
    }
}

; Customizable Hotkeys
; Alt and F10 in this situation is my hotkey in OBS for saving a replay, if you want a different one change it to the keys you want. 

saveReplay()
{
    Sleep 33
    Send {Alt down}{F10 Down}
    Sleep 1000
    Send {Alt up}{F10 up}
}

; folderChanged(20) saves a replay that's going to last 20 seconds. So if you want it to save for 15 seconds you would change it to: folderChanged(15)
;
; If any of the hotkeys overlap with OBS you may want to use ~$ this prefix in front of the hotkey and remove saveReplay(). Check example for ~$!F10::

!F2:: ; Save replay for 8 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(8)
return

!F3:: ; Save replay for 20 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(20)
return

!F5:: ; Save replay for 30 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(30)
return

!F6:: ; Save replay for 45 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(45)
return

!F7:: ; Save replay for 60 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(60)
return

!F8:: ; Save replay for 120 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(120)
return

!F9:: ; Save replay for 180 seconds.
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
folderChanged(180)
return

~$!F10:: ; Save replay for 300 seconds. Note that this does not include saveReplay() and has ~$ prefix because it overlaps with my OBS hotkey.
folderChanged(300)
return

~$!F11:: ; Recording
if (recordingstarted = true)
{
    recordingstarted := false
    if (soundNotifications = true)
    {
        SoundPlay *64
        Sleep 250
    }
    if (enableNotifications = true)
    {
        TrayTip, Recording Saved, Your recording has been saved.
    }
}
else if (obsrunning = true)
{
    recordingstarted := true
    recordingdelay := true
    Sleep 7000
    folderChanged()
    recordingdelay := false
}
return

!F12:: ; Save replay for custom amount of seconds
if (recordingdelay = true or replaysaving = true)
{
    ReplayNotSavedPrompt()
    return
}
saveReplay()
InputBox, seconds, seconds
folderChanged(seconds)
return

!s::
forceSave := true
return

checkProcessDB()
{
	; To add your own app/game to the list of folders, copy the following example
	;	case "program.exe"
	;		return "Program"
	; Change "program.exe" to the app/game's .exe
	; Change "Program" to a folder name you want
	; Then paste it in switch currentWindow

	WinGet, currentWindow, ProcessName, A
	switch currentWindow
	{
		case "gta5.exe":
			return "Grand Theft Auto V"
		case "NFS13.exe":
			return "Need For Speed Most Wanted 2012"
		case "FortniteClient-Win64-Shipping.exe":
			return "Fortnite"
		case "ShooterGame.exe":
			return "Ark Survival Evolved"
		case "javaw.exe":
			return "Minecraft"
		case "csgo.exe":
			return "Counter Strike Global Offensive"
		case "ForzaHorizon5.exe":
			return "Forza Horizon 5"
		case "Terraria.exe":
			return "Terraria"
		case "VALORANT-Win64-Shipping.exe":
			return "VALORANT"
		default:
			return "nothing"
	}
    return
}

^Esc::reload
^l::ExitApp
