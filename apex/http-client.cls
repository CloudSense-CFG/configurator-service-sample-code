public class HttpClient {

	static final String CS_ENDPOINT = '<engine service url needs to go here>';
	static final String EXECUTE_SCRIPT = '/executeScript';
	static final String HTTP_POST = 'POST';

	public static HttpResponse sendRequest(Map<String, String> data) {
		String payload = JSON.serialize(data);

		HttpRequest request = new HttpRequest();

		// Setting headers using RSA strategy
		RsaSignService svc = new RsaSignService();
		request = svc.getHeadersRSA(request, payload);

		// Setting headers using shared secret strategy
		// SharedSecretSignService svc = new SharedSecretSignService();
		// request = svc,getHeadersSharedSecret(request, payload);

		request.setMethod(HTTP_POST);
		request.setEndpoint(CS_ENDPOINT + EXECUTE_SCRIPT);
		request.setBody(payload);

		Http http = new Http();
		HttpResponse response = http.send(request);

		return response;
	}
}
