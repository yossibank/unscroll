#if os(iOS)
import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

public enum FocusShield {
    public enum Reshield: Sendable {
        case done
        case stillOpen
        case tripEnded
    }

    public enum Target {
        case application(ApplicationToken)
        case category(ActivityCategoryToken)
        case webDomain(WebDomainToken)
    }

    public static let shortestScheduleSeconds: TimeInterval = 15 * 60

    private static let reshieldToleranceSeconds: TimeInterval = 5

    public static var pressedAt: Date? {
        defaults?.object(forKey: ShieldUnlock.pressedAtKey) as? Date
    }

    private static var unlockName: DeviceActivityName {
        DeviceActivityName(ScreenTimeShared.unlockActivityName)
    }

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: ScreenTimeShared.appGroup)
    }

    private static var store: ManagedSettingsStore {
        ManagedSettingsStore(named: ManagedSettingsStore.Name(ScreenTimeShared.focusStoreName))
    }

    public static func savedSelection() -> FamilyActivitySelection {
        guard
            let data = defaults?.data(forKey: ScreenTimeShared.selectionKey),
            let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return FamilyActivitySelection()
        }

        return saved
    }

    public static func startTrip(endsAt end: Date) {
        defaults?.set(end, forKey: ScreenTimeShared.focusEndsAtKey)
        defaults?.removeObject(forKey: ShieldUnlock.pressedAtKey)

        shield(savedSelection())
    }

    public static func endTrip() {
        defaults?.removeObject(forKey: ScreenTimeShared.focusEndsAtKey)
        defaults?.removeObject(forKey: ShieldUnlock.openUntilKey)
        defaults?.removeObject(forKey: ShieldUnlock.pressedAtKey)

        store.clearAllSettings()

        DeviceActivityCenter().stopMonitoring([unlockName])
    }

    public static func press(
        _ target: Target,
        at now: Date
    ) -> ShieldUnlock {
        let unlock = ShieldUnlock(pressedAt: pressedAt, now: now)

        switch unlock {
        case .startWaiting:
            defaults?.set(now, forKey: ShieldUnlock.pressedAtKey)

        case .keepWaiting:
            break

        case .open:
            open(target, at: now)
        }

        return unlock
    }

    public static func reshieldIfTripContinues(at now: Date) -> Reshield {
        let openUntil = defaults?.object(forKey: ShieldUnlock.openUntilKey) as? Date ?? now

        guard
            let end = defaults?.object(forKey: ScreenTimeShared.focusEndsAtKey) as? Date,
            now < end
        else {
            return .tripEnded
        }

        guard now >= openUntil.addingTimeInterval(-reshieldToleranceSeconds) else {
            return .stillOpen
        }

        defaults?.removeObject(forKey: ShieldUnlock.openUntilKey)

        shield(savedSelection())
        return .done
    }

    public static func schedule(
        from start: Date,
        to end: Date
    ) -> DeviceActivitySchedule {
        let components: Set<Calendar.Component> = [.hour, .minute, .second]
        let calendar = Calendar.current
        let minimum = start.addingTimeInterval(shortestScheduleSeconds)
        let intervalEnd = max(end, minimum)
        let early = Int(intervalEnd.timeIntervalSince(end))

        return DeviceActivitySchedule(
            intervalStart: calendar.dateComponents(components, from: start),
            intervalEnd: calendar.dateComponents(components, from: intervalEnd),
            repeats: false,
            warningTime: early > 0 ? DateComponents(second: early) : nil
        )
    }

    private static func shield(
        _ selection: FamilyActivitySelection,
        except target: Target? = nil
    ) {
        let store = store
        var apps = selection.applicationTokens
        var categories = selection.categoryTokens
        var domains = selection.webDomainTokens
        var exceptApps = Set<ApplicationToken>()

        switch target {
        case let .application(token):
            apps.remove(token)
            exceptApps.insert(token)

        case let .category(token):
            categories.remove(token)

        case let .webDomain(token):
            domains.remove(token)

        case nil:
            break
        }

        let categoryPolicy: ShieldSettings.ActivityCategoryPolicy<Application>? = categories.isEmpty
            ? nil
            : .specific(categories, except: exceptApps)

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categoryPolicy
        store.shield.webDomains = domains.isEmpty ? nil : domains
    }

    private static func open(
        _ target: Target,
        at now: Date
    ) {
        let end = now.addingTimeInterval(ShieldUnlock.openSeconds)
        let center = DeviceActivityCenter()

        defaults?.removeObject(forKey: ShieldUnlock.pressedAtKey)
        defaults?.set(end, forKey: ShieldUnlock.openUntilKey)

        shield(savedSelection(), except: target)

        center.stopMonitoring([unlockName])

        do {
            try center.startMonitoring(unlockName, during: schedule(from: now, to: end))
        } catch {
            EventLog.append("止めた画面：止め直しを見張れない（\(error.localizedDescription)）")
            shield(savedSelection())
        }
    }
}
#endif
