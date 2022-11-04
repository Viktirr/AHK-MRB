# AHK-MRB
AutoHotkey - Multiple Replay Buffers for OBS  
This script is meant to save you some time during editing by saving only the amount of video you think is necessary on the fly, or to upload the clips directly to YouTube or any other platform.  

## Usage  
Saving videos is simple, the default controls include:
- Alt + F2 - Saving the last 8 seconds
- Alt + F3 - Saving the last 20 seconds
- Alt + F5 - Saving the last 30 seconds
- Alt + F6 - Saving the last 45 seconds
- Alt + F7 - Saving the last 60 seconds (1 minute)
- Alt + F8 - Saving the last 120 seconds (2 minutes)
- Alt + F9 - Saving the last 180 seconds (3 minutes)
- Alt + F10 - Saving the last 300 seconds (5 minutes)
- Alt + F11 - Start/Stop Recording
- Alt + S - Force Save (Closing OBS also works)  
  
Upon exiting OBS, or force saving, your clips will be trimmed to the last amount of seconds you've chosen per clip.

## Installation
### Prerequisites
- Windows 10/11
- AutoHotkey  
Download: https://www.autohotkey.com/
- FFmpeg Binaries (essential or full)  
Download: https://www.gyan.dev/ffmpeg/builds/
- The Script Itself  
Download: https://github.com/Viktirr/AHK-MRB/releases  

### Installation process
#### The script
It doesn't matter where the script or any of its dependencies are (for now).  
If you'd like the script to start up while booting into Windows, then head over to...  
```
%AppData%\Microsoft\Windows\Start Menu\Programs\
```  
and paste the script (AHK-MRB.ahk) there.
#### FFmpeg
There is also no restriction for FFmpeg's file location, just as long as it doesn't require administrator rights to run, any place should be fine.  
My recommendation is to create a folder named ffmpeg inside Documents and paste ffmpeg.exe there  
1. Open the downloaded .7z file that contains FFmpeg
2. Head over to the bin folder inside the .7z file
3. Drag and drop ffmpeg.exe to the folder you created (or create the folder now)
4. Delete the .7z file  
#### Setting up the script  
- Create 2 new folders, one where the video will be temporarily stored, and the other where the final videos will be stored (the temporary folder can be nested inside the final one)
- Open the script with a text editor (Notepad, Notepad++, VS Code...)  
- Set SetWorkingDir to the folder you created with ffmpeg on (if you can't find this variable, use Ctrl + F)
- Set TemporaryDirectory to the temporary folder you just created
- Set FinalDirectory to the final folder you just created
- Save the script and exit
#### Setting up OBS
- Open OBS
- Open Settings
- Head over to Output and then Recording
- On Recording Format select .mkv
- On Recording Path click Browse
- Select the temporary folder for saving your replays (mandatory)
- Apply changes
- Head over to Replay Buffer under Output as well
- Enable the Replay Buffer
- Set the Replay Buffer to 300 seconds. (mandatory)
- Head over to Hotkeys
- Replace Save Replay with Alt + F10 (mandatory)
- Replace Start/Stop Recording with Alt + F11 (mandatory)
- Apply changes
  
If you've done everything right, you should be good to go!

## Additional configuration  
If you want to customise your script even further, click on this [YouTube Video](https://www.youtube.com/watch?v=QQHP5CUg7WM) explaining how to change the amount of replay buffers, changing hotkeys, compressing videos further with x264 or x265, and some additional options you may also change.
