import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome       = 0
    case carousel      = 1
    case painPoints    = 2
    case solution      = 3
    case demo          = 4
    case valueDelivery = 5
    case paywall       = 6
}
