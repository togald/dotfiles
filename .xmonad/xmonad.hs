-- Imports.
import XMonad
import Data.Monoid
import Data.List                   -- Required for class matching to work correctly
import System.IO
import System.Exit
import XMonad.Actions.CycleWS      -- Additional workspace cycling binds

import XMonad.Hooks.DynamicLog     -- statusbar
import XMonad.Hooks.EwmhDesktops   -- fullscreenEventHook fixes chrome fullscreen
import XMonad.Hooks.FadeInactive   -- Fade inactive windows
import XMonad.Hooks.ManageDocks    -- dock/tray mgmt
import XMonad.Hooks.ManageHelpers  -- To get fullscreen working
import XMonad.Hooks.UrgencyHook    -- window alert bells

import XMonad.Layout.Named         -- custom layout names
import XMonad.Layout.NoBorders     -- smart borders on solo clients
import XMonad.Layout.PerWorkspace  -- per-workspace settings

import XMonad.Util.EZConfig        -- append key/mouse bindings
import XMonad.Util.Run             -- spawnPipe and hPutStrLn

import XMonad.Util.Paste           -- Paste stuff, required for pasteSelection

import qualified XMonad.StackSet as W -- manageHook rules
import qualified Data.Map        as M

-- The main function.
main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

-- Command to launch the bar.
myBar = "xmobar --alpha=150 ~/.xmobarrc.hs"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppTitle = xmobarColor "#00b0ff" "" . shorten 100
                , ppCurrent = xmobarColor "green" ""
                , ppUrgent = xmobarColor "red" ""
                , ppSep = " | " }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- Main configuration, override the defaults to your liking.
myConfig = ewmh defaultConfig { modMask            = mod1Mask                    -- mod1Mask=left alt, mod3Mask=right alt, mod4Mask=Win key
                              , terminal           = "xterm -fg white -bg black" -- default terminal emulator
                              , borderWidth        = 1                           -- width of the borders around windows
                              , normalBorderColor  = "#000000"                   -- default border color
                              , focusedBorderColor = "#0000d0"                   -- focused window border color
                              , focusFollowsMouse  = True
                              , workspaces         = ["Music","Web","Img","Remote","Term","IM","Dev","Files","Game","Misc","Work","Clear","Virt"]
                              , mouseBindings      = myMouseBindings
                              , layoutHook         = myLayoutHook
                              , manageHook         = myManageHook
                              , handleEventHook    = myEventHook
                              , startupHook        = myStartupHook
                              } `additionalKeys` myKeys
-- end

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
-- end

myLayoutHook = avoidStruts $ smartBorders 
    $ onWorkspace "Web"    (Tall 1 (3/100) (35/52)) 
    $ onWorkspace "IM"  (Tall 1 (3/100) (3/4))
    $ onWorkspace "Dev"    (Tall 1 (3/100) (33/52))
    $ onWorkspace "Files"  (Tall 1 (3/100) (1/2))
    $ onWorkspace "School" (Tall 1 (3/100) (29/44))
    $ ( tiled ||| Mirror tiled )
    where tiled = Tall 1 (3 / 100) (5/9)
-- end

myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [ [ resource  =? r --> doIgnore    | r <- ["desktop_window", "kdesktop"] ]
    , [ className =? c --> doFloat     | c <- ["Nitrogen", "Galculator", "Cowbell", "Pavucontrol", "KODI", "Opennx", "NXAgent", "onboard", "Onboard"] ]
    , [ className =? c <&&> fmap not isDialog --> doFullFloat | c <- ["Gpicview"] ]
    , [ fmap ("VLC" `isInfixOf`) title      --> doFloat ]
    , [ fmap ("Copying" `isInfixOf`) title  --> doFloat ]
    , [ fmap ("Moving" `isInfixOf`) title   --> doFloat ]
    , [ fmap ("Deleting" `isInfixOf`) title --> doFloat ]
    , [ fmap ("GtkFileChooserDialog" `isInfixOf`) role --> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7) ]
    , [ className =? "Gimp"    --> doShift "Img" ] -- Shift GIMP to the Img desktop
    , [ fmap ("Digikam" `isInfixOf`) title --> doShift "Game" ] -- Shift Digikam to the Game desktop
    -- , [ fmap ("Steam" `isInfixOf`) title --> doShift "Game" ] -- Shift Steam to the Game desktop
    , [ fmap ("Lutris" `isInfixOf`) title --> doShift "Game" ] -- Shift Lutris to the Game desktop
    , [ fmap ("Age of Empires II:" `isInfixOf`) title --> doShift "Clear" ] -- Shift AoE2 to the clear desktop to get it to behave
    , [ fmap ("Discord" `isInfixOf`) title --> doShift "IM" ] -- Shift Discord to the IM desktop
    , [ (className =? "Chromium" <&&> fmap ("pop-up" `isSuffixOf`) role) --> doCenterFloat ]
    , [ manageDocks ]
    , [ isDialog --> doCenterFloat ]
    , [ isFullscreen --> doFullFloat ] ]
    where role = stringProperty "WM_WINDOW_ROLE"
          icon = stringProperty "WM_ICON_NAME"
-- end

myKeys = [ ((mod1Mask, xK_Left)  , sendMessage Shrink)
         , ((mod1Mask, xK_Right) , sendMessage Expand)
         , ((mod1Mask, xK_Up)    , sendMessage (IncMasterN 1))
         , ((mod1Mask, xK_Down)  , sendMessage (IncMasterN (-1))) 
         -- Above: controlling tiling with the arrow keys
         -- Below: Quick access to applications
         , ((mod1Mask, xK_e)              , spawn "kate .xmonad/xmonad.hs .xmobarrc.hs .xprofile") 
         , ((mod1Mask .|. shiftMask, xK_f), spawn "dolphin") 
         , ((mod1Mask .|. shiftMask, xK_w), spawn "chromium")
         , ((mod1Mask .|. shiftMask, xK_t), spawn "xterm -fg white -bg black")
         -- Volume controls and stuff
         , ((0, 0x1008ff12), spawn "pamixer -t") -- Mute button
         , ((0, 0x1008ff13), spawn "pamixer -i 5") -- Volume up
         , ((0, 0x1008ff11), spawn "pamixer -d 5") -- Volume down
         , ((0, 0x1008ffb2), spawn "pamixer -t --source 1") -- mute mic
         , ((0, 0x1008ff41), spawn "pavucontrol") -- open mixer
         , ((0, 0x1008ff03), spawn "xbacklight -20")
         , ((0, 0x1008ff02), spawn "xbacklight +20")
         -- Workspace-shifting: the name-list
         , ((mod4Mask, xK_q)              , toggleOrView "Music")
         , ((mod4Mask .|. shiftMask, xK_q), windows $ W.shift "Music")
         , ((mod4Mask, xK_w)              , toggleOrView "Web")
         , ((mod4Mask .|. shiftMask, xK_w), windows $ W.shift "Web")
         , ((mod4Mask, xK_e)              , toggleOrView "Img")
         , ((mod4Mask .|. shiftMask, xK_e), windows $ W.shift "Img")
         , ((mod4Mask, xK_r)              , toggleOrView "Remote")
         , ((mod4Mask .|. shiftMask, xK_r), windows $ W.shift "Remote")
         , ((mod4Mask, xK_t)              , toggleOrView "Term")
         , ((mod4Mask .|. shiftMask, xK_t), windows $ W.shift "Term")
         , ((mod4Mask, xK_s)              , toggleOrView "IM")
         , ((mod4Mask .|. shiftMask, xK_s), windows $ W.shift "IM")
         , ((mod4Mask, xK_d)              , toggleOrView "Dev")
         , ((mod4Mask .|. shiftMask, xK_d), windows $ W.shift "Dev")
         , ((mod4Mask, xK_f)              , toggleOrView "Files")
         , ((mod4Mask .|. shiftMask, xK_f), windows $ W.shift "Files")
         , ((mod4Mask, xK_g)              , toggleOrView "Game")
         , ((mod4Mask .|. shiftMask, xK_g), windows $ W.shift "Game")
         , ((mod4Mask, xK_z)              , toggleOrView "Misc")
         , ((mod4Mask .|. shiftMask, xK_z), windows $ W.shift "Misc")
         , ((mod4Mask, xK_x)              , toggleOrView "Work")
         , ((mod4Mask .|. shiftMask, xK_x), windows $ W.shift "Work")
         , ((mod4Mask, xK_c)              , toggleOrView "Clear")
         , ((mod4Mask .|. shiftMask, xK_c), windows $ W.shift "Clear")
         , ((mod4Mask, xK_v)              , toggleOrView "Virt")
         , ((mod4Mask .|. shiftMask, xK_v), windows $ W.shift "Virt")
         -- Other workspace-shifting: moving around without knowing where you're going
         , ((mod4Mask, xK_Left),                prevWS)
         , ((mod4Mask, xK_Right),               nextWS)
         , ((mod4Mask .|. shiftMask, xK_Left),  shiftToPrev)
         , ((mod4Mask .|. shiftMask, xK_Right), shiftToNext)
         , ((mod4Mask, xK_space)              , moveTo Next EmptyWS)
         , ((mod4Mask .|. shiftMask, xK_space), moveTo Next NonEmptyWS)
         -- X-selection-paste buffer, paste selection buffer when Insert is pressed
         , ((0, xK_Insert), pasteSelection)
         -- Screenshot. Pretty important. 
         , ((0, xK_Print)              , spawn "cd ~/ramdisk; scrot")
         , ((mod1Mask, xK_Print)       , spawn "cd ~/ramdisk; scrot -s -b")]

myEventHook = handleEventHook defaultConfig <+> fullscreenEventHook
myStartupHook = mempty


