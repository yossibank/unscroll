import SwiftUI

extension OnboardingView {
    var pageTransition: AnyTransition {
        let insertion: Edge = isForward ? .trailing : .leading
        let removal: Edge = isForward ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertion).combined(with: .opacity),
            removal: .move(edge: removal).combined(with: .opacity)
        )
    }

    var swipe: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let width = value.translation.width

                guard abs(width) > abs(value.translation.height) else {
                    return
                }

                if width < -60, model.canSwipeForward {
                    turn(forward: true)
                } else if width > 60, model.canGoBack {
                    turn(forward: false)
                }
            }
    }

    var dotsLabel: String {
        let index = (OnboardingModel.introPages.firstIndex(of: model.page) ?? 0) + 1
        return "説明 \(index) / \(OnboardingModel.introPages.count)"
    }

    var waitingCaption: String {
        guard let companion = model.settings.companion else {
            return "相棒が、出発を待っています"
        }

        return "\(companion.name)が、出発を待っています"
    }

    var primaryTitle: String {
        switch model.page {
        case .usage: "旅の支度をする"
        case .permission: permissionTitle
        case .practice: "練習の旅に出る"
        default: "次へ"
        }
    }

    var permissionTitle: String {
        if model.settings.isRequestingAuthorization {
            return "許可を待っています"
        }

        return model.settings.isAuthorized ? "次へ" : "許可する"
    }

    var laterTitle: String {
        model.page == .practice ? "練習せずにはじめる" : "あとで設定する"
    }

    var canPrimary: Bool {
        switch model.page {
        case .companion: model.companion.draft != nil
        case .apps: model.settings.hasSelection
        default: true
        }
    }

    var showsLater: Bool {
        switch model.page {
        case .permission: !model.settings.isAuthorized
        case .apps: !model.settings.hasSelection
        case .practice: true
        default: false
        }
    }

    func primaryAction() {
        switch model.page {
        case .companion:
            withAnimation(.snappy) {
                isForward = true
                model.saveCompanion()
            }

        case .permission where !model.settings.isAuthorized:
            Task {
                if await model.requestAuthorization() {
                    turn(forward: true)
                }
            }

        case .practice:
            finish(startsPractice: true)

        default:
            turn(forward: true)
        }
    }

    func laterAction() {
        switch model.page {
        case .apps, .practice:
            finish(startsPractice: false)

        default:
            turn(forward: true)
        }
    }

    func finish(startsPractice: Bool) {
        model.complete()
        onFinish(startsPractice)
    }

    func turn(forward: Bool) {
        withAnimation(.snappy) {
            isForward = forward

            if forward {
                model.next()
            } else {
                model.back()
            }
        }
    }

    func skipIntro() {
        withAnimation(.snappy) {
            isForward = true
            model.skipIntro()
        }
    }
}
