const entitlementID = 'full_access';
const appleAPIKey = 'appl_tVYlENODueIwydWcQqNRLMpyKBO';
const footerText = """
Every Purchase is subject to our Terms of Service and Privacy Policy. Every subscription guarantees access to all features and content. Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.
""";

const Duration daysTestPhase = Duration(days: 14);

enum Plan { test, pro }

extension PlanExtension on Plan {
  String get prettyName {
    switch (this) {
      case Plan.test:
        return 'Test';
      case Plan.pro:
        return 'Pro';
    }
  }
}
