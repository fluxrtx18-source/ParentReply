import Testing
@testable import ParentReply

@Suite("OnboardingData")
struct OnboardingDataTests {

    @Test("All onboarding steps are sequential")
    func stepsAreSequential() {
        let steps = OnboardingStep.allCases
        for (i, step) in steps.enumerated() {
            #expect(step.rawValue == i, "Step \(step) should have rawValue \(i)")
        }
    }

    @Test("Feature cards have valid content")
    func featureCardsValid() {
        let cards = FeatureCard.all
        #expect(cards.count == 3)
        for card in cards {
            #expect(!card.headline.isEmpty)
            #expect(!card.body.isEmpty)
            #expect(!card.accentHex.isEmpty)
        }
    }

    @Test("Pain points are non-empty")
    func painPointsNonEmpty() {
        #expect(!OnboardingPainPoints.options.isEmpty)
        #expect(!OnboardingPainPoints.headline.isEmpty)
    }

    @Test("Solution items are non-empty")
    func solutionItemsNonEmpty() {
        #expect(!PersonalisedSolutionData.items.isEmpty)
    }

    @Test("Demo message has valid content")
    func demoMessageValid() {
        let demo = DemoMessages.message
        #expect(!demo.from.isEmpty)
        #expect(!demo.subject.isEmpty)
        #expect(!demo.body.isEmpty)
    }

    @Test("Demo replies cover expected tones")
    func demoRepliesCoverTones() {
        let tones = DemoMessages.demoReplies.map(\.tone)
        #expect(tones.contains(.grateful))
        #expect(tones.contains(.concerned))
    }
}
