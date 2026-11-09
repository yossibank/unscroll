import Core
import Features
import Foundation
import Testing

@MainActor
struct LandmarkArrivalViewTests {
    @Test
    func makesBodyBeforeAndAfterDecorating() {
        let landmark = Journey.tokyoToKyoto.landmarks[1]
        let start = Date(timeIntervalSince1970: 1_000_000)
        let trip = Trip(startedAt: start, plannedMinutes: 90)
        let arrival = Arrival(landmark: landmark, tripID: trip.id, arrivedAt: start)
        var decorated = arrival
        decorated.decoratedAt = start

        _ = LandmarkArrivalView(arrival: arrival, onDecorate: { _ in }).body
        _ = LandmarkArrivalView(arrival: decorated, onDecorate: { _ in }).body
    }
}
