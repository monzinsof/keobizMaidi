public without sharing class ContactSynchronizationQueueable
    implements Queueable, Database.AllowsCallouts {

    private final Set<Id> contactIds;

    public ContactSynchronizationQueueable(
        Set<Id> contactIds
    ) {
        this.contactIds =
            contactIds == null
            ? new Set<Id>()
            : new Set<Id>(contactIds);
    }

    public void execute(QueueableContext context) {

        if (contactIds.isEmpty()) {
            return;
        }

        List<Contact> contacts = [
            SELECT Id, IsActive__c
            FROM Contact
            WHERE Id IN :contactIds
        ];

        ContactSynchronizationApi.synchronize(contacts);
    }
}