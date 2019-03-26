public class RsaSignService {

	private static final String AUTHORIZATION_SCHEME = 'CS-Elastic';
	private static final Integer NONCE_LENGTH = 5;
	private static final String NONCE_CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	private static final Integer NONCE_CHARACTERS_LENGTH = NONCE_CHARACTERS.length();

	private HttpRequest getHeadersRSA(HttpRequest request, String payload) {
		request.setHeader('Organization', ORG_ID);
		request.setHeader('Authorization', getAuthorizationHeader(
			CERTIFICATE_NAME,
			CLIENT_ID,
			HTTP_POST,
			EXECUTE_SCRIPT,
			calculateRsaPayloadHash(data, 'application/json');
		)
		);
		request.setHeader('Content-Type', 'application/json');

		return request;
	}

	public static String generateRsaAuthorizationHeader(String certificateName, String clientId, String method, String url, String hash) {
		Long timestamp = DateTime.now().getTime();
		String nonce = generateNonce(NONCE_LENGTH);
		String signature = generateSignature(
			certificateName,
			timestamp,
			nonce,
			method,
			url,
			hash
		);

		List<String> headerSourceParts = new List<String> {
			getHeaderPart('ts', String.valueOf(timestamp)),
			getHeaderPart('clientId', clientId),
			getHeaderPart('nonce', nonce),
			getHeaderPart('sig', signature)
		};

		if (String.isNotBlank(hash)) {
			headerSourceParts.add(getHeaderPart('hash', hash));
		}

		return AUTHORIZATION_SCHEME + ' ' + String.join(headerSourceParts, ', ');
	}

	public static String calculateRsaPayloadHash(String payload, String contentType) {
		List<String> hashSourceParts = new List<String> {
			AUTHORIZATION_SCHEME.toLowerCase() + '.payload',
			contentType.toLowerCase(),
			payload == null ? '' : payload,
			''
		};
		Blob hash = Crypto.generateDigest(
			'SHA-256',
			Blob.valueOf(String.join(hashSourceParts, '\n'))
		);

		return EncodingUtil.base64Encode(hash);
	}

	private static String generateSignature(String certificateName, Long timestamp, String nonce, String method, String url, String hash) {
		List<String> signatureSourceParts = new List<String> {
			AUTHORIZATION_SCHEME.toLowerCase(),
			String.valueOf(timestamp),
			nonce,
			method == null ? '' : method.toUpperCase(),
			url == null ? '' : url
		};

		if (String.isNotBlank(hash)) {
			signatureSourceParts.add(hash);
		}

		signatureSourceParts.add('');
		Blob signature = Crypto.signWithCertificate(
			'RSA-SHA256',
			Blob.valueOf(String.join(signatureSourceParts, '\n')),
			certificateName
		);

		return EncodingUtil.base64Encode(signature);
	}

	private static String generateNonce(Integer nonceLength) {
		String[] characters = new String[0];
		for (Integer i = 0; i < nonceLength; i++) {
			Integer index = Math.mod(
				Math.abs(Crypto.getRandomInteger()),
				NONCE_CHARACTERS_LENGTH
			);
			characters.add(NONCE_CHARACTERS.substring(index, index + 1));
		}

		return String.join(characters, '');
	}

	private static String getHeaderPart(String key, String value) {
		return key + '="' + value + '"';
	}
}
