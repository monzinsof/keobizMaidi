public without sharing class ContactDeactivationQueueable
    implements Queueable {

    private static final String STATUS_CANCELED = 'canceled';

    private final Set<Id> canceledAccountIds;

    public ContactDeactivationQueueable(
        Set<Id> canceledAccountIds
    ) {
        this.canceledAccountIds =
            canceledAccountIds == null
            ? new Set<Id>()
            : new Set<Id>(canceledAccountIds);
    }

    public void execute(QueueableContext context) {

        if (canceledAccountIds.isEmpty()) {
            return;
        }

        Set<Id> impactedContactIds = new Set<Id>();

        for (AccountContactRelation relation : [
            SELECT ContactId
            FROM AccountContactRelation
            WHERE AccountId IN :canceledAccountIds
            AND IsActive = true
        ]) {
            impactedContactIds.add(relation.ContactId);
        }

        if (impactedContactIds.isEmpty()) {
            return;
        }

        Map<Id, Set<Id>> accountIdsByContactId =
            new Map<Id, Set<Id>>();

        Set<Id> allRelatedAccountIds = new Set<Id>();

        for (AccountContactRelation relation : [
            SELECT ContactId, AccountId
            FROM AccountContactRelation
            WHERE ContactId IN :impactedContactIds
            AND IsActive = true
        ]) {
            if (!accountIdsByContactId.containsKey(
                relation.ContactId
            )) {
                accountIdsByContactId.put(
                    relation.ContactId,
                    new Set<Id>()
                );
            }

            accountIdsByContactId
                .get(relation.ContactId)
                .add(relation.AccountId);

            allRelatedAccountIds.add(relation.AccountId);
        }

        Map<Id, Account> relatedAccounts =
            new Map<Id, Account>([
                SELECT Id, MissionStatus__c
                FROM Account
                WHERE Id IN :allRelatedAccountIds
            ]);

        List<Contact> contactsToDeactivate =
            new List<Contact>();

        for (Contact contactRecord : [
            SELECT Id, IsActive__c
            FROM Contact
            WHERE Id IN :impactedContactIds
        ]) {
            Set<Id> relatedAccountIds =
                accountIdsByContactId.get(contactRecord.Id);

            if (
                relatedAccountIds == null
                || relatedAccountIds.isEmpty()
            ) {
                continue;
            }

            Boolean allMissionsAreCanceled = true;

            for (Id accountId : relatedAccountIds) {
                Account relatedAccount =
                    relatedAccounts.get(accountId);

                if (
                    relatedAccount == null
                    || relatedAccount.MissionStatus__c
                        != STATUS_CANCELED
                ) {
                    allMissionsAreCanceled = false;
                    break;
                }
            }

            if (
                allMissionsAreCanceled
                && contactRecord.IsActive__c
            ) {
                contactsToDeactivate.add(
                    new Contact(
                        Id = contactRecord.Id,
                        IsActive__c = false
                    )
                );
            }
        }

        if (contactsToDeactivate.isEmpty()) {
            return;
        }

        update contactsToDeactivate;

        Set<Id> updatedContactIds =
            new Map<Id, Contact>(
                contactsToDeactivate
            ).keySet();

        System.enqueueJob(
            new ContactSynchronizationQueueable(
                updatedContactIds
            )
        );
    }
}