# Prayer Notification Feature

## Overview
The prayer notification feature automatically sends notifications to users when it's time for each of the five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha).

## Implementation Details

### Files Added/Modified

1. **PrayerNotificationManager.swift** (NEW)
   - Location: `/Deen Buddy Advanced/Services/PrayerNotificationManager.swift`
   - Manages all notification-related functionality
   - Handles permission requests
   - Schedules notifications for all 5 prayers
   - Supports canceling notifications
   - Implements UNUserNotificationCenterDelegate for foreground presentation

2. **PrayersViewModel.swift** (MODIFIED)
   - Added notification manager integration
   - Automatically schedules notifications when prayer times are loaded
   - Requests notification permission on first launch
   - Methods:
     - `requestNotificationPermission()` - Manually request permission
     - `cancelAllNotifications()` - Cancel all prayer notifications

3. **Deen_Buddy_AdvancedApp.swift** (MODIFIED)
   - Initializes notification manager on app launch
   - Sets up the notification delegate

4. **project.pbxproj** (MODIFIED)
   - Added notification usage description:
     - `INFOPLIST_KEY_NSUserNotificationsUsageDescription = "We send you reminders when it's time for each prayer."`

## How It Works

### Automatic Flow
1. App launches → `PrayerNotificationManager` is initialized
2. User's location is determined → Prayer times are calculated
3. If notification permission not yet requested:
   - System prompt appears asking for notification permission
4. If permission granted:
   - Notifications are scheduled for all 5 prayer times
5. When a prayer time arrives:
   - Local notification is sent with title and body
   - Example: "🕌 Time for Fajr Prayer - It's time to pray Fajr in New York, US"

### Notification Scheduling
- Notifications are scheduled using `UNCalendarNotificationTrigger`
- Only future prayer times are scheduled (past times are skipped)
- Notifications are rescheduled daily when location/prayer times update
- Each notification has a unique identifier: `prayer_{name}_{YYYYMMDD}`

### Permission States
- **Not Determined**: System prompt will appear on first prayer time calculation
- **Authorized**: Notifications are scheduled automatically
- **Denied**: No notifications are scheduled (user can enable in iOS Settings)

## User Experience

### First Launch
1. User opens the app
2. Location permission is requested (existing feature)
3. Prayer times are calculated based on location
4. Notification permission dialog appears automatically
5. If user grants permission, notifications are scheduled

### Daily Usage
- Notifications arrive at exact prayer times
- Notification shows prayer name and location
- Tapping notification opens the app
- Notifications appear even when app is in foreground

### Notification Content
```
Title: 🕌 Time for [Prayer Name] Prayer
Body: It's time to pray [Prayer Name] in [City, Country]
Sound: Default notification sound
```

## Testing

### Manual Testing Steps
1. Build and run the app on simulator/device
2. Grant location permission when prompted
3. Wait for prayer times to load
4. Grant notification permission when prompted
5. Check that notifications are scheduled:
   ```swift
   // In PrayerNotificationManager, call:
   listPendingNotifications { requests in
       print("Pending notifications: \(requests.count)")
   }
   ```
6. To test immediately, temporarily modify notification time in code
7. Verify notification appears at scheduled time

### Simulator Testing
```bash
# To trigger a test notification immediately:
# 1. Set a notification 1 minute in the future
# 2. Or use xcrun simctl to push a notification

xcrun simctl push booted VibalyzeOU.Deen-Buddy-Advanced payload.json
```

### Debug Logs
The implementation includes extensive logging:
- ✅ Success messages (green checkmark)
- ❌ Error messages (red X)
- ⏭️ Skipped actions (skip emoji)
- 🗑️ Cancellation messages (trash emoji)
- 📱 User interactions (phone emoji)

## Code Examples

### Manually Request Notification Permission
```swift
// From any view with access to PrayersViewModel
prayersVM.requestNotificationPermission()
```

### Cancel All Notifications
```swift
// From any view with access to PrayersViewModel
prayersVM.cancelAllNotifications()
```

### Check Permission Status
```swift
PrayerNotificationManager.shared.checkPermissionStatus { status in
    switch status {
    case .authorized:
        print("Notifications enabled")
    case .denied:
        print("Notifications denied - user must enable in Settings")
    case .notDetermined:
        print("Permission not yet requested")
    default:
        break
    }
}
```

### List Pending Notifications (Debug)
```swift
PrayerNotificationManager.shared.listPendingNotifications { requests in
    for request in requests {
        print("Scheduled: \(request.identifier)")
        if let trigger = request.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = trigger.nextTriggerDate() {
            print("  Will fire at: \(nextTriggerDate)")
        }
    }
}
```

## Architecture

### Notification Manager Pattern
- Singleton pattern (`PrayerNotificationManager.shared`)
- Thread-safe with DispatchQueue.main callbacks
- Implements delegate pattern for notification handling
- Separates concerns: scheduling vs. permission management

### Integration with Existing Code
- Minimal changes to existing codebase
- Uses existing `DayTimes` model
- Integrates with `PrayersViewModel` reload flow
- Respects existing location/prayer time caching

### Error Handling
- Gracefully handles permission denial
- Skips past prayer times
- Validates all date components before scheduling
- Logs all errors for debugging

## Future Enhancements

### Potential Improvements
1. **User Preferences**
   - Allow users to enable/disable notifications per prayer
   - Custom notification sounds for each prayer
   - Advance notification option (5/10/15 minutes before)
   - Reminder notification if prayer not marked complete

2. **Rich Notifications**
   - Add quick actions (Mark as Prayed, Snooze)
   - Include countdown timer in notification
   - Show Qibla direction in notification

3. **Smart Notifications**
   - Adjust based on user's prayer completion history
   - Send follow-up reminder if prayer not completed
   - Suggest best time based on user patterns

4. **Customization**
   - Multiple notification styles
   - Custom messages/duas in notifications
   - Integration with Do Not Disturb schedules

5. **Analytics**
   - Track notification delivery success
   - Monitor user engagement with notifications
   - Optimize notification timing based on data

## Troubleshooting

### Notifications Not Appearing
1. Check notification permission in iOS Settings
2. Verify prayer times are being calculated correctly
3. Check device is not in Do Not Disturb mode
4. Use debug logging to verify notifications are scheduled
5. Ensure device time zone matches location

### Permission Issues
- If permission denied, direct user to iOS Settings:
  - Settings → [App Name] → Notifications
- Cannot re-prompt if denied (iOS limitation)
- Consider showing in-app message explaining how to enable

### Testing Issues
- Simulator may have delays with notifications
- Use physical device for accurate testing
- Check Xcode console for debug logs
- Verify app is not force-quit (affects background notifications)

## Technical Notes

### iOS Notification Limits
- iOS has no hard limit on scheduled local notifications
- Best practice: Keep under 64 pending notifications
- Current implementation: Maximum 5 per day (one per prayer)
- Automatically cancels old notifications before scheduling new ones

### Background Behavior
- Local notifications work even when app is closed
- Notifications are persistent (stored by iOS)
- Survive app restarts and device reboots
- Must be rescheduled after iOS updates (handled automatically on app launch)

### Privacy Considerations
- Notification content only shows prayer name and city
- No personal data in notifications
- Location data not included in notification payload
- User can disable in system settings at any time
