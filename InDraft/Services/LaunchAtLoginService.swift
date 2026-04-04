import ServiceManagement

// MARK: - Protocol

protocol LaunchAtLoginServiceProtocol {
    /// Whether the app is currently registered as a login item.
    var isEnabled: Bool { get }
    /// Enable or disable launch at login. Throws on failure.
    func setEnabled(_ enabled: Bool) throws
}

// MARK: - Errors

enum LaunchAtLoginError: Error, Equatable {
    case registrationFailed(String)
    case unregistrationFailed(String)
}

// MARK: - Live Implementation

final class LiveLaunchAtLoginService: LaunchAtLoginServiceProtocol {
    private let service = SMAppService.mainApp

    var isEnabled: Bool {
        service.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }
}

// MARK: - Mock Implementation

final class MockLaunchAtLoginService: LaunchAtLoginServiceProtocol {
    var isEnabled: Bool = false
    var shouldThrowOnEnable = false
    var shouldThrowOnDisable = false
    var setEnabledCallCount = 0
    var lastSetEnabledValue: Bool?

    func setEnabled(_ enabled: Bool) throws {
        setEnabledCallCount += 1
        lastSetEnabledValue = enabled
        if enabled && shouldThrowOnEnable {
            throw LaunchAtLoginError.registrationFailed("Mock registration failed")
        }
        if !enabled && shouldThrowOnDisable {
            throw LaunchAtLoginError.unregistrationFailed("Mock unregistration failed")
        }
        isEnabled = enabled
    }
}
