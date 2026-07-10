public without sharing class AccountTriggerHandler {

    private static final String STATUS_CANCELED = 'canceled';

    public static void beforeUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldMap
    ) {
        for (Account currentAccount : newAccounts) {
            Account oldAccount = oldMap.get(currentAccount.Id);

            Boolean becameCanceled =
                oldAccount.MissionStatus__c != STATUS_CANCELED
                && currentAccount.MissionStatus__c == STATUS_CANCELED;

            if (becameCanceled) {
                currentAccount.MissionCanceledDate__c = Date.today();
            }
        }
    }

    public static void afterUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldMap
    ) {
        Set<Id> newlyCanceledAccountIds = new Set<Id>();

        for (Account currentAccount : newAccounts) {
            Account oldAccount = oldMap.get(currentAccount.Id);

            Boolean becameCanceled =
                oldAccount.MissionStatus__c != STATUS_CANCELED
                && currentAccount.MissionStatus__c == STATUS_CANCELED;

            if (becameCanceled) {
                newlyCanceledAccountIds.add(currentAccount.Id);
            }
        }

        if (!newlyCanceledAccountIds.isEmpty()) {
            System.enqueueJob(
                new ContactDeactivationQueueable(
                    newlyCanceledAccountIds
                )
            );
        }
    }
}