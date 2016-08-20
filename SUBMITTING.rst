.. |...| unicode:: U+2026 .. ldots
  :trim:

#. Open ``iphone-client/openSNP Health.xcodeproj`` in Xcode.
#. Click "Xcode" from the top menu (to the right of the ), and select "Preferences"
#. Click "Accounts" then the + icon to add an account. Login with the developer account's Apple ID. Close preferences afterwards.
#. In the top of the window (to the right of the "stop" icon) click the *right* part of the button with "iphone-client >" text to select a device. Select "Generic iOS Device" from the dropdown.
#. Click "Product" from the top (to the far right of ) menu and select "Archive"
#. In the window that just appeared, click "Upload to App Store |...|". (F.Y.I., this window is the "Organizer" and can be opened from "Window" -> "Organizer").
#. Confirm your account is selected from the dropdown, and click "Choose".
#. Click "Upload" after processing is completed.
#. Visit https://itunesconnect.apple.com, and login.
#. Click "My Apps" and the "+" symbol in the top left and "New app".
#. After filling-out the form, click the on the app icon.
#. Click "+ version or platform"
#. You'll need to "select a binary" for the version, which you should see after the upload from Xcode has been processed. This can take a little while (~1hr).
#. The rest is difficult for me to test without actually performing the steps, but it should be relatively straightforward. There should be a button that allows yous to "submit for review", which will send the code to Apple. The review process should be within 9 days, after which the app will appear on the store. Updates are generally faster: perhaps a few days only.
