# StayAwake

A menu bar switch for keeping a Mac awake, even with the lid closed.

- **Coffee cup** = on. The Mac doesn't sleep when you close the lid or leave it idle, and the
  screen never dims. Also opens [BetterDisplay](https://github.com/waydabber/BetterDisplay).
- **Moon** = off. Normal sleep comes back (display sleeps after 2 min on battery, 10 min on the
  adapter), and BetterDisplay quits.

`caffeinate` can't do this: it never stops lid-close sleep. StayAwake uses
`pmset disablesleep`, which does.

## Build and install

```sh
./build.sh                 # swiftc + ad-hoc codesign → ./StayAwake.app (Command Line Tools only)
./install-sudoers.sh       # lets the app run its pmset commands without a password
cp -R StayAwake.app /Applications/
cp Resources/com.mwolfe.stayawake.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.mwolfe.stayawake.plist
```

The LaunchAgent starts StayAwake at login and right away.

## Why sudo

`pmset` needs root. `install-sudoers.sh` installs `/etc/sudoers.d/stayawake`, which allows only
the seven `pmset` commands the app runs (rule in `Resources/sudoers-stayawake`, checked with
`visudo`). Without it, the toggle shows "Couldn't change sleep settings".

Check the current state: `pmset -g | grep SleepDisabled`

## Icon missing?

A full menu bar can push new items behind the camera notch. This moves it next to the clock:

```sh
defaults write com.mwolfe.stayawake "NSStatusItem Preferred Position Item-0" -float 230
launchctl kickstart -k gui/$(id -u)/com.mwolfe.stayawake
```
