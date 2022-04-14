#------------------------------------------------------
# Add document to fence
#------------------------------------------------------
ACCESS_TOKEN=""
DOCUMENT_JSON = '{ "type": "privacy-policy", "version": "2", "name": "Privacy Policy", "raw": "https://github.com/chicagopcdc/Documents/blob/fda4a7c914173e29d13ab6249ded7bc9adea5674/governance/privacy_policy/privacy_notice.md", "formatted": "https://github.com/chicagopcdc/Documents/blob/81d60130308b6961c38097b6686a21f8be729a2c/governance/privacy_policy/PCDC-Privacy-Notice.pdf", "required": "true"}'


# echo "Adding a new document"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d "$RESOURCE_JSON" https://localhost/user/admin/add_document
