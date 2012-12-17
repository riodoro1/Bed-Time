This app is a workaround for the issue of hackintoshes not going to sleep to save power or when the battery is dying.

It takes Sleep timer from /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist (so the setup is done nativly via System Preferences) and after idle time passes given value sleeps the computer, also to prevent sleeping while watching movies it only sleeps when screen Power State is 0 (off)
I made it so it detects wether battery percentage is 10 (below this level some hackbooks just won't sleep) or below and then, also sleeps OS to prevent full discharge.

Place it in whatever folder You like and add to login items to have the Power Saver sleep working.

You are free to modify the code or put it in your apps or packages as long as You mention me in credits.