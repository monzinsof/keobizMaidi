public without sharing class ContactSynchronizationApi {

    @TestVisible
    private static final String ENDPOINT =
        'https://fxyozmgb2xs5iogcheotxi6hoa0jdhiz'
        + '.lambda-url.eu-central-1.on.aws/';

    @TestVisible
    private static final String AUTHORIZATION_TOKEN =
        'salesforceAuthToken';

    public static void synchronize(
        List<Contact> contacts
    ) {
        if (contacts == null || contacts.isEmpty()) {
            return;
        }

        List<ContactPayload> payload =
            new List<ContactPayload>();

        for (Contact contactRecord : contacts) {
            payload.add(
                new ContactPayload(
                    contactRecord.Id,
                    contactRecord.IsActive__c
                )
            );
        }

        HttpRequest request = new HttpRequest();

        request.setEndpoint(ENDPOINT);
        request.setMethod('PATCH');

        request.setHeader(
            'Authorization',
            AUTHORIZATION_TOKEN
        );

        request.setHeader(
            'Content-Type',
            'application/json'
        );

        request.setTimeout(120000);
        request.setBody(JSON.serialize(payload));

        HttpResponse response =
            new Http().send(request);

        if (response.getStatusCode() != 200) {
            throw new ContactSynchronizationException(
                'Contact synchronization failed. HTTP '
                + response.getStatusCode()
                + ' - '
                + response.getBody()
            );
        }
    }

    public class ContactPayload {
        public String id;
        public Boolean is_active;

        public ContactPayload(
            Id contactId,
            Boolean isActive
        ) {
            this.id = String.valueOf(contactId);
            this.is_active = isActive;
        }
    }

    public class ContactSynchronizationException
        extends Exception {
    }
}