import Control.Monad (liftM, sequence)
import Data.List
import Text.Read
import XMonad
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows
import XMonad.Actions.GroupNavigation
import XMonad.Actions.SpawnOn
import XMonad.Actions.Submap
import XMonad.Actions.TagWindows
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowBringer
import XMonad.Actions.WindowGo
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName -- for jetbrains stuff to work
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.WorkspaceDir
import XMonad.Operations
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows (getName, unName)
import XMonad.Util.Run
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Layout.IndependentScreens
import XMonad.Layout.ThreeColumns

main = do
  d <- spawnPipe myDzenArgs
  xmonad $ withUrgencyHook NoUrgencyHook $ desktopConfig
    { manageHook  = myManageHook
    , modMask     = myModMask
    , layoutHook  = myLayoutHook
    , terminal    = myTerminal
    , logHook     = myLogHook d
    , borderWidth = myBorderWidth
    , startupHook = myStartupHook
    } `additionalKeysP` myKeys

myStartupHook :: X ()
-- ^ actions to run at the start of the X session
myStartupHook = do
  spawnHere "~/.xmonad/autostart.sh"
  setWMName "LG3D" -- spoof window manager name in order to make jetbrains stuff work

myLayoutHook =
  id
  $ avoidStruts
  $ smartBorders
  $ layoutHook desktopConfig

myModMask = mod4Mask -- use window key as modifier

myManageHook = composeAll
  [ manageDocks
  , manageHook def
  , namedScratchpadManageHook myScratchPads
  , manageSpawn
  ]

myLogHook h  = do
    historyHook                     -- for window history navigation
    updatePointer (0.5, 0.5) (0, 0) -- center pointer when focusing new window
    dynamicLogWithPP $ def
    -- dzen2 settings
        { ppCurrent         = dzenColor "black" "light gray" . pad           -- current ws color
        , ppHidden          = dzenColor "light gray" "" . pad . noScratchPad -- nonempty ws color
        , ppHiddenNoWindows = dzenColor "dim gray" "" . pad . noScratchPad   -- empty ws color
        , ppLayout          = dzenColor "dim gray" "" . pad                  -- layout indicator color
        , ppUrgent          = dzenColor "black" "red" . pad . dzenStrip      -- urgent ws color
        , ppTitle           = shorten 100                                     -- shorten window titles
        , ppWsSep           = ""                                             -- workspace separator
        , ppSep             = "  "                                           -- object separator
        , ppOutput          = hPutStrLn h                                    -- output to argument
        , ppExtras          = [myLogTitles (dzenColor "#ee3366" "")]
        , ppOrder           = \(ws:l:t:e) -> [ws, l] ++ e
        }
        where
          noScratchPad ws = if ws =="NSP" then "" else ws

myKeys :: [(String, X ())]
-- ^ list of keymaps
myKeys =
  [
  --------------------------
  -- workspace navigation --
  --------------------------
    ("M-n"   , moveTo Next emptyWS) -- focus next empty workspace
  , ("M-S-l" , nextWS)              -- focus next workspace
  , ("M-S-h" , prevWS)              -- focus prev workspace

  -------------------------
  -- window manipulation --
  -------------------------
  , ("M-d"   , kill)                                 -- delete window
  , ("M-y"   , windowYank)                           -- yank window
  , ("M-p"   , windowPut)                            -- put all tagged windows
  , ("M-u"   , nextMatch History (return True))      -- go to prev win
  , ("M-/"   , gotoMenuConfig myWindowBringerConfig) -- go to win by title
  , ("M-S-n" , shiftTo Next emptyWS)                 -- send window to next nonempty ws

  -- the block below implements window tagging in the style of vim marks
  -- currently the only characters that can be used as marks are a, b, m, and n
  -- TODO abstract this pattern so you can use any alphabetic character
  , ("M-m", submap . M.fromList $
      [ ((0, xK_m),     windowMark "m")
      , ((0, xK_n),     windowMark "n")
      , ((0, xK_a),     windowMark "a")
      , ((0, xK_b),     windowMark "b")
      , ((0, xK_w),     windowMark "w")
      ])
  , ("M-'", submap . M.fromList $
      [ ((0, xK_m),     windowJump "m")
      , ((0, xK_n),     windowJump "n")
      , ((0, xK_a),     windowJump "a")
      , ((0, xK_b),     windowJump "b")
      ])
  , ("M-w" , windowJump "w")                 -- jump to window marked with 'w'

  --------------------
  -- screen control --
  --------------------
  -- NOTE if `light` fails for permission reasons, see note at the end of this file
  , ("<XF86MonBrightnessUp>"     , spawnHere "light -A 10")                      -- brighten
  , ("<XF86MonBrightnessDown>"   , spawnHere "light -U 10")                      -- dim
  , ("M-<F1>"                    , liftH $ screenTempModify (const 3000))        -- set screen temperature to red
  , ("M-<F2>"                    , liftH $ screenTempModify (const 5000))        -- set screen temperature to orange
  , ("M-<F3>"                    , liftH $ screenTempModify (const 6400))        -- set screen temperature to default
  , ("M-<XF86MonBrightnessUp>"   , liftH $ screenTempModify (+500))              -- make screen more red
  , ("M-<XF86MonBrightnessDown>" , liftH $ screenTempModify (flip (-) 500))      -- make screen more blue

  ---------------------
  -- color switching --
  ---------------------
  , ("M-<F7>" , spawnHere "xcalib -invert -alter" ) -- invert screen color

  --------------------
  -- audio settings --
  --------------------
  , ("<XF86AudioLowerVolume>" , spawn "amixer -D pulse sset Master 10%+")      -- volume down
  , ("<XF86AudioRaiseVolume>" , spawn "amixer -D pulse sset Master 10%-")      -- volume down
  -- , ("<XF86AudioRaiseVolume>" , liftH $ audioLevelModify (+10))              -- volume up
  , ("<XF86AudioMute>"        , spawn "amixer sset Master 1+ toggle")        -- toggle mute

  --------------------
  -- misc utilities --
  --------------------
  , ("M-S-;"       , spawnHere "sleep 0.5; scrot -s -e 'mv $f ~/images/screenshots/'")         -- screenshot region of screen
  , ("M-;  "       , spawnHere "sleep 0.5; scrot -e 'mv $f ~/images/screenshots/'")            -- capture entire screen
  , ("M-<F9>     " , spawnHere "setxkbmap us -variant colemak")                                -- set keyboard layout to colemak
  , ("M-<F10>    " , spawnHere "setxkbmap us")                                                 -- set keyboard layoyut to qwerty
  , ("M-i"         , spawnHere myLauncher)                                                     -- run app by name via rofi
  , ("M-s"         , scratchTerm)                                                              -- toggle scratchpad
  , ("M-q"         , spawn "xmonad --recompile; kill -9 $(pgrep dzen); xmonad --restart")      -- restart xmonad
  , ("<Print>"     , spawnHere "sleep 0.4; maim -s -u | xclip -selection clipboard -t image/png -i")      -- screenshot region to clipboard
  , ("M-S-i"       , spawnHere "fd -i -d 4 | rofi -multi-select -dmenu | xargs -n 1 xdg-open")                       -- file picker

  ----------------------
  -- temporary things --
  ----------------------
  , ("M-x" , showState) -- for testing purposes
  -- , ("M-f", withFocused $ windows . W.sink) -- toggle float -- NOTE needs testing to determine exact behavior
  ]
  ++ myAppKeys
  where
    windowPut       = sequence_ [withTaggedGlobalP "yanked" shiftHere, withTaggedGlobal "yanked" (delTag "yanked")]
    windowYank      = withFocused (addTag "yanked")
    windowMark mark = sequence_ [withTaggedGlobal mark (delTag mark), withFocused (addTag mark)]
    windowJump mark = focusUpTaggedGlobal mark
    scratchTerm     = namedScratchpadAction myScratchPads "terminal"

myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm]
  where
    spawnTerm  = myTerminal ++ " --class scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 2/6
        w = 2/6
        t = 3/6
        l = (1-w)/2

myTerminal = "kitty"

myWindowBringerConfig :: WindowBringerConfig
myWindowBringerConfig = def
  { menuCommand = "rofi"
  , menuArgs = ["-dmenu", "-i"]
  }

myLauncher              = ("rofi -show run " ++ myLauncherArgs )
myLauncherArgs = "" -- rofi config delegated to home.nix

myDzenArgs = "dzen2 -dock -p -xs 1 -ta l -e 'onstart=lower' -fn terminus:bold:pixelsize=12"

myBorderWidth = 3 --pixels

-- myLogTitles is used to show window titles in dzen2
myLogTitles :: (String -> String) -> Logger
myLogTitles ppFocus =
        let
            windowTitles windowset = sequence (map (fmap showName . getName) (W.index windowset))
                where
                    fw = W.peek windowset
                    showName nw =
                        let
                            window = unName nw
                            name = shorten 50 (show nw)
                        in
                            if maybe False (== window) fw
                                then
                                    ppFocus name
                                else
                                    name
        in
            withWindowSet $ liftM (Just . (intercalate "  |  ")) . windowTitles


----------------------------------
-- Application launch and focus --
----------------------------------

-- The `App` type wraps the data needed to control an application
data App = App
     { keyApp :: String      -- a hotkey used to run or raise the app
     , findApp :: Query Bool -- how to raise the app
     , runApp :: X ()        -- how to run the app
     }

-- The `makeKeys` function turns an `App` value into a concrete xmonad keymap
makeKeys :: App -> [(String, X ())]
makeKeys (App k f r) =
  [ ("M-" ++ k, nextMatchOrDo Backward f r)
  , ("M-S-" ++ k, r)
  ]

-- The list `myApps` contains applications which can be ran or raised
myApps :: [App]
myApps =
  -- appname    -- hotkey
  [ firefox     -- f
  , zathura     -- a
  , kitty       -- t
  , ranger      -- r
  , qutebrowser -- o
  , emacs       -- e
  , chromium    -- c
  , vmware      -- v
  ]

-- `myAppKeys` is a list of concrete keymaps constructed from `myApps`
myAppKeys = concat $ map makeKeys myApps

-- -- The block below defines applications of interest
-- lf = App
--   { keyApp  =             "l"
--   , findApp = className ~=?   "lf"
--   , runApp  = spawnHere   "mpv" -- NOTE would be nice to have a prompt allowing selection of video (sorted by recent, with thumbnails!)
--   }

mpv = App
  { keyApp  =             "v"
  , findApp = className ~=?   "mpv"
  , runApp  = spawnHere   "mpv" -- NOTE would be nice to have a prompt allowing selection of video (sorted by recent, with thumbnails!)
  }

firefox = App
  { keyApp =               "f"
  , findApp = className =? "Firefox"
  -- , runApp =  spawnHere    "firefox"
  , runApp =  spawnHere    "firefox -private-window"
  }

zathura = App
  { keyApp  =              "a"
  , findApp = className =? "Zathura"
  , runApp  = spawnHere    "zathura"
  }

vscode      = App
  { keyApp  =              "v"
  , findApp = className =? "Code"
  , runApp  = spawnHere    "code"
  }

emacs       = App
  { keyApp  =              "e"
  , findApp = className =? "Emacs"
  , runApp  = spawnHere    "emacsclient -c"
  }

urxvt       = App
  { keyApp  =              "t"
  , findApp = className =? "URxvt"
  , runApp  = spawnHere   "urxvt"
  }

alacritty   = App
  { keyApp  =              "t"
  , findApp = className =? "Alacritty"
  , runApp  = spawnHere    "alacritty"
  }

kitty   = App
  { keyApp  =              "t"
  , findApp = className =? "kitty"
  , runApp  = spawnHere    "kitty"
  }

ranger      = App
  { keyApp  =              "r"
  , findApp =  title ~=? "ranger:"
  , runApp  =  runInTerm   "--class ranger" "ranger"
  }

(~=?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~=? x = fmap (isPrefixOf x) q

qutebrowser = App
  { keyApp  =              "o"
  , findApp = className =? "qutebrowser"
  , runApp  =  spawnHere   "qutebrowser"
  }

chromium    = App
  { keyApp  =              "c"
  , findApp = className =? "Chromium"
  , runApp  = spawnHere    "chromium --incognito"
  }

gimp        = App
  { keyApp  =              "g"
  , findApp = className =? "Gimp"
  , runApp  =  spawnHere   "gimp"
  }

vmware        = App
  { keyApp  =              "v"
  , findApp = className =? "Vmware"
  , runApp  =  spawnHere   "vmware"
  }


-----------
-- State --
-----------
-- make functions which update a HState value
-- such as screenBrightnessShift, screenTempShift, volumeShift, keyboardLightToggle
-- these should all have type HState -> HState
-- then lift those to the type X () by using modify and actualize

data HState = HState        -- Hardware state
  { screenTemp :: Int
  -- , keyboardLight :: Bool
  -- , audioLevel :: Int       -- sound volume
  }
  deriving (Typeable, Show)

instance ExtensionClass HState where
  initialValue = HState
    { screenTemp = 6400
    -- , keyboardLight = False
    -- , audioLevel = 0
    }


screenTempModify :: (Int -> Int) -> (HState -> HState)
screenTempModify f state = state {screenTemp = newScreenTemp}
  where
    newScreenTemp = min (max (f $ (screenTemp state)) 1000) 24000


-- keyboardLightToggle :: HState -> HState
-- keyboardLightToggle state = state {keyboardLight = newKeyboardLight}
--   where
--     newKeyboardLight = not $ keyboardLight state


-- audioLevelModify :: (Int -> Int) -> (HState -> HState)
-- audioLevelModify f state = state {audioLevel = newAudioLevel}
--   where
--     newAudioLevel = min (max (f $ (audioLevel state)) 0) 100


liftH :: (HState -> HState) -> X ()
liftH f = XS.modify f >> actualizeHState


check :: Bool -> String
check False = "0"
check True  = "100"


actualizeHState :: X ()
actualizeHState = do
  currentState <- XS.get :: X HState
  spawn $ "redshift -P -O " ++ (show $ screenTemp currentState)
  -- spawn $ "light -S " ++ (show $ check $ keyboardLight currentState) ++ " -s sysfs/leds/tpacpi::kbd_backlight;" -- get this by running `light -L`
  -- spawn $ "amixer sset Master " ++ (show $ audioLevel currentState) ++ "%"


showState :: X () -- used for debugging
showState = do
  currentState <- XS.get :: X HState
  -- spawn $ "xmessage " ++ (show (screenTemp state))
  spawn $ "xmessage " ++ (show currentState)



-----------
-- Notes --
-----------

-- NOTE from documentation at https://wiki.haskell.org/Xmonad/Frequently_asked_questions#I_need_to_find_the_class_title_or_some_other_X_property_of_my_program section 3.16
-- resource (also known as appName) is the first element in WM_CLASS(STRING)
-- className is the second element in WM_CLASS(STRING), find it by running  `xprop WM_CLASS | sed 's/.*"\(.*\)"/\1/'`
-- title is WM_NAME(STRING)

-- NOTE if `light` fails for permission reasons, run `chgrp video /sys/class/backlight/.../brightness; chmod g+w ...`
-- do `cat .nix-profile/lib/udev/rules.d/90-backlight.rules` first
-- and make sure user is part of "video" group
