import Foundation

enum DemoMessages {
    static let message = DemoMessage(
        from: "Ms. Thompson",
        subject: "Behaviour Note",
        body: "Hi, I wanted to let you know that Jake had some trouble staying focused in class today. He was talking during the lesson and had to be redirected several times. I'd love to work together to help him stay on track. Would you be available for a quick chat this week?"
    )

    static let demoReplies: [(tone: ReplyTone, text: String)] = [
        (.grateful, "Thank you for letting me know, Ms. Thompson. We appreciate you taking the time to reach out and we'll talk to Jake about staying focused."),
        (.concerned, "Thanks for flagging this. Has this been happening often? We want to make sure there isn't something else going on."),
        (.diplomatic, "I appreciate you sharing this. Jake is usually quite focused at home — could there be something in the classroom environment contributing?")
    ]
}
