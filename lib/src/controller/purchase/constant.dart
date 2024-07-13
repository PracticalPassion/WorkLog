const entitlementID = 'full_access';
const appleAPIKey = 'appl_tVYlENODueIwydWcQqNRLMpyKBO';
const footerText =
    """A [purchase amount and period] purchase will be applied to your iTunes account [at the end of the trial or intro] on confirmation]. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription. For more information, see our [link to ToS] and [link to Privacy Policy].""";

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
