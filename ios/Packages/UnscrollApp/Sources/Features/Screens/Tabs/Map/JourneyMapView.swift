import Core
import DesignSystem
import SwiftUI

public struct JourneyMapView: View {
    @State private var model: JourneyMapModel
    @State private var picker: JourneyPickerModel?

    @Environment(\.scenePhase) private var scenePhase

    private let onJourneyChanged: () -> Void

    public init(
        model: JourneyMapModel,
        onJourneyChanged: @escaping () -> Void = {}
    ) {
        _model = State(initialValue: model)
        self.onJourneyChanged = onJourneyChanged
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                JournalTitle("旅の地図", note: "いま歩いている道のり")

                JourneyMapTicket(model: model) {
                    picker = model.makeJourneyPicker()
                }

                JourneyMapPaper(model: model)
                    .padding(.vertical, Spacing.small)

                JourneyMapTag(
                    journey: model.journey,
                    nextLandmark: model.nextLandmark,
                    kilometersToNext: model.kilometersToNext
                )
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
            .padding(.bottom, FloatingTabBarMetrics.clearance)
        }
        .background(PaperBackdrop())
        .onAppear {
            model.refresh()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            model.refresh()
        }
        .sheet(item: $picker) { picker in
            JourneyPickerSheet(model: picker) {
                self.picker = nil
                model.refresh()
                onJourneyChanged()
            }
            .presentationDetents([.fraction(0.65), .large])
        }
    }
}
