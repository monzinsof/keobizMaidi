@IsTest
public class AccountTriggerTest {
    
static void handlesTwoHundredAccounts() {
    Test.setMock(
        HttpCalloutMock.class,
        new ContactSynchronizationHttpMock()
    );

    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < 200; i++) {
        accounts.add(new Account(
            Name = 'Bulk Company ' + i,
            MissionStatus__c = 'active'
        ));
    }

    insert accounts;

    List<Contact> contacts = new List<Contact>();

    for (Integer i = 0; i < accounts.size(); i++) {
        contacts.add(new Contact(
            LastName = 'Bulk Contact ' + i,
            AccountId = accounts[i].Id,
            IsActive__c = true
        ));
    }

    insert contacts;

    for (Account accountRecord : accounts) {
        accountRecord.MissionStatus__c = 'canceled';
    }

    Test.startTest();
    update accounts;
    Test.stopTest();

    Integer canceledAccounts = [
        SELECT COUNT()
        FROM Account
        WHERE Id IN :accounts
        AND MissionStatus__c = 'canceled'
        AND MissionCanceledDate__c = TODAY
    ];

    System.assertEquals(
        200,
        canceledAccounts,
        'Les 200 comptes doivent avoir une date d’annulation.'
    );

    Integer inactiveContacts = [
        SELECT COUNT()
        FROM Contact
        WHERE Id IN :contacts
        AND IsActive__c = false
    ];

    System.assertEquals(
        200,
        inactiveContacts,
        'Les 200 contacts doivent devenir inactifs.'
    );
}

}