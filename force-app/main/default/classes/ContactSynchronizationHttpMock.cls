@IsTest
public class ContactSynchronizationHttpMock
    implements HttpCalloutMock {

    public HttpResponse respond(
        HttpRequest request
    ) {
        System.assertEquals(
            'PATCH',
            request.getMethod()
        );

        System.assertEquals(
            'salesforceAuthToken',
            request.getHeader('Authorization')
        );

        System.assertEquals(
            'application/json',
            request.getHeader('Content-Type')
        );

        List<Object> payload =
            (List<Object>) JSON.deserializeUntyped(
                request.getBody()
            );

        System.assert(
            !payload.isEmpty(),
            'The payload must contain at least one contact.'
        );

        for (Object row : payload) {
            Map<String, Object> item =
                (Map<String, Object>) row;

            System.assertEquals(2, item.size());
            System.assert(item.containsKey('id'));
            System.assert(item.containsKey('is_active'));
        }

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('OK');

        return response;
    }
}