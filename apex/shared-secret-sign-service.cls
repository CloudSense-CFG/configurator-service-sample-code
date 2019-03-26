public class SharedSecretSignService {

	private HttpRequest getHeadersSharedSecret(HttpRequest request, String payload) {
		Long csTime = System.currentTimeMillis();
		request.setHeader('Organization', ORG_ID);
		request.setHeader('Authorization', getAuthorizationHeader(csTime));
		request.setHeader('CS-Time', String.valueOf(csTime));
		request.setHeader('CS-Signature', getSignedPayload(payload));
		request.setHeader('Content-Type', 'application/json');
		return request;
	}

	private String getSignedPayload(String payload) {
		Blob digest = Crypto.generateDigest('sha1', Blob.valueOf(payload));
		String hexDigest = EncodingUtil.convertToHex(digest);
		Blob hash = Crypto.generateMac(
			'hmacSHA256',
			Blob.valueOf(hexDigest),
			Blob.valueOf(CLIENT_SECRET)
		);

		return EncodingUtil.convertToHex(hash);
	}

	private String getAuthorizationHeader(Long csTime) {
		String data = 'CS' + CLIENT_ID + '\n' +
			csTime + '\n' +
			HTTP_POST + '\n' +
			EXECUTE_SCRIPT + '\n';
		Blob hash = Crypto.generateMac(
			'hmacSHA256',
			Blob.valueOf(data),
			Blob.valueOf(CLIENT_SECRET)
		);
		String hex = EncodingUtil.convertToHex(hash);
		String signature = EncodingUtil.base64Encode(Blob.valueOf(hex));

		return EncodingUtil.base64Encode(Blob.valueOf('CS' + CLIENT_ID)) + ':' + signature;
	}
}
