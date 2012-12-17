This app is a workaround for the issue of hackintoshes not going to sleep to save power or when the battery is dying.

It takes Sleep timer from /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist (so the setup is done nativly via System Preferences) and after idle time passes given value app sleeps the computer, also to prevent sleeping while watching movies it only sleeps when screen Power State is 0 (off)

I made it so it detects wether battery percentage is 10 or below and then, also sleeps OS to prevent full discharge.
Critical Battery Level on which system will automatically sleep can be adjusted in /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist in "Battery Power" dict create a key "Critical Battery Level" with integer value.

Example:
        <key>Critical Battery Level</key>
        <integer>5</integer>
        
Some hackbooks just won't go to sleep when battery is below 10%.

Place it in whatever folder You like and add to login items to have the Power Saver sleep working.

You are free to modify the code or put it in your apps or packages as long as You mention me in credits.