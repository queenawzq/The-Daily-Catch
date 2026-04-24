import Foundation
import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()

    private let dailyReminderId = "daily-catch-reminder"
    private let reengagementId = "daily-catch-reengagement"
    private let reengagementDelayDays = 3
    private let center = UNUserNotificationCenter.current()

    private init() {}

    // Requests auth from the OS. Returns true if granted.
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // Schedules (or reschedules) the daily reminder at hour:minute in the user's local timezone.
    func scheduleDailyReminder(hour: Int, minute: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])

        let content = UNMutableNotificationContent()
        content.title = "Your Daily Catch is ready"
        content.body = "5 minutes to catch up on what matters. Let's go."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderId, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }

    // Schedules a single "we miss you" nudge 3 days from now. Call this every
    // time the user opens the app — rescheduling with the same identifier replaces
    // the pending one, so the notification only fires if they stay away for 3 days.
    func scheduleReengagementReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reengagementId])

        let content = UNMutableNotificationContent()
        content.title = "Missed a few Catches?"
        content.body = "You haven't caught up in a bit. 5 minutes, you're back in the loop."
        content.sound = .default

        let seconds = TimeInterval(reengagementDelayDays * 24 * 60 * 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: reengagementId, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelReengagementReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reengagementId])
    }

    // Reconciles scheduled notifications with current preferences. Call on app launch
    // (and when the user returns to the app) so the re-engagement timer resets and
    // any OS-level permission changes are reflected in our state.
    func syncWithPreferences() async {
        let prefs = UserPreferencesService.shared
        let status = await currentAuthorizationStatus()

        guard status == .authorized else {
            cancelDailyReminder()
            cancelReengagementReminder()
            if prefs.notificationsEnabled {
                // OS permission was revoked externally — reflect that in our state.
                prefs.notificationsEnabled = false
            }
            return
        }

        if prefs.notificationsEnabled {
            scheduleDailyReminder(hour: prefs.notificationHour, minute: prefs.notificationMinute)
        } else {
            cancelDailyReminder()
        }

        if prefs.notificationsEnabled && prefs.reengagementNotificationsEnabled {
            scheduleReengagementReminder()
        } else {
            cancelReengagementReminder()
        }
    }

    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
