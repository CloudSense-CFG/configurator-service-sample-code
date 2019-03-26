/*
 * Preparing payload data
 * Example 1. Creating Product Configuration
 */
Map<String, Object> data = new Map<String, Object>();
data.put('definitionId', 'a0g1t0000009mub');
data.put('containerId', '0061t000004BBee');
data.put('script', 'function() { return { status: \'done\' }; }');

HttpClient.sendRequest(data);

/*
 * Example 2. Set Attribute value
 */
String attributeRef = 'User_Input_0';
String newAttributeValue = 'New value';

Map<String, Object> data = new Map<String, Object>();
data.put('configurationData', model);
data.put('script', 'function() {' +
	'CS.setAttributeValue("' + attributeRef + '", "' + newAttributeValue + '");' +
		'return { status: \'done\' };' +
	'}'
);
data.put('persistConfiguration', true);

HttpClient.sendRequest(data);

/*
 * Example 3. Add related product
 */
Map<String, String> attributes = new Map<String, String>();
attributes.put('name', 'User input2');
attributes.put('value', 'Test');

Map<String, Object> relatedProd = new Map<String, Object>();
relatedProd.put('relatedProducts', new String[]());
relatedProd.put('relatedProductName', 'Related Pro');
relatedProd.put('definitionId', 'a0g1t0000009xpRAAQ');
relatedProd.put('basketId', 'a0b1t000000DKtFAAW');
relatedProd.put('attributes', attributes);

Map<String, Object> data = new Map<String, Object>();
data.put('configurationId', 'a0e1t000000EoX3AAK');
data.put('script', 'return addRelatedProduct(' + JSON.serialize(relatedProd) + ');');
data.put('persistConfiguration', true);

/*
 * Contents of file staticResources/config-test-service.resource
 * which is loaded through the UX Plugin loading mechanism.
 *
async function addRelatedProduct(relatedProductData) {
	if (relatedProductData) {
		const relatedProduct = await CS.Service.addRelatedProduct(
			CS.Util.generateReference(relatedProductData.relatedProductName, ''),
			relatedProductData.definitionId,
			true
		);

		relatedProductData.attributes.forEach((attribute) => {
			const reference = CS.Util.generateReference(
				attribute.name,
				{ ref: relatedProduct.reference }
			);
			CS.setAttribute(reference, attribute.value, true);
		});

		CS.Rules.rulesSuspended(false);

		return CS.Rules.evaluateAllRules();
	}
}
*/

HttpClient.sendRequest(data);
