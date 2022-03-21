#------------------------------------------------------
# Populate Amanuensis DB
#------------------------------------------------------
ACCESS_TOKEN=
USER_ID=

echo "Adding states to the Amanuensis DB"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name": "In Review", "code": "IN_REVIEW"}' http://localhost/amanuensis/admin/states
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name": "Rejected", "code": "REJECTED"}' http://localhost/amanuensis/admin/states
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name": "Approved", "code": "APPROVED"}' http://localhost/amanuensis/admin/states


echo "Adding consortiums to the Amanuensis DB"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name": "INRG", "code": "INRG"}' http://localhost/amanuensis/admin/consortiums
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name": "INSTRUCT", "code": "INSTRUCT"}' http://localhost/amanuensis/admin/consortiums


echo "Adding Search in Amanuensis DB"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"user_id": '"$USER_ID"', "name": "inrg-test-1", "description": "admin creates a search list for a user", "ids_list": ["COG_0xA4CE42BAEAFFD85A5A573F7C0488647D","COG_0x2B1D2E3C4648236211D982AA60BAC9BD", "COG_0xE23B0F16F4B158D1A417B2B422AEB303"]}' http://localhost/amanuensis/admin/filter-sets
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"user_id": '"$USER_ID"', "name": "inrg-test-2", "description": "admin creates a search list for a user", "ids_list": ["COG_0xA4CE42BAEAFFD85A5A573F7C0488647D","COG_0x2B1D2E3C4648236211D982AA60BAC9BD", "COG_0xE23B0F16F4B158D1A417B2B422AEB303"]}' http://localhost/amanuensis/admin/filter-sets
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"user_id": '"$USER_ID"', "name": "inrg-test-3", "description": "admin creates a search list for a user", "ids_list": ["COG_0xA4CE42BAEAFFD85A5A573F7C0488647D","COG_0x2B1D2E3C4648236211D982AA60BAC9BD", "COG_0xE23B0F16F4B158D1A417B2B422AEB303"]}' http://localhost/amanuensis/admin/filter-sets

echo "Adding Project in Amanuensis DB"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"user_id": '"$USER_ID"', "name": "inrg-test-req1", "description": "inrg-test-req description", "filter_set_ids": [1,2], "institution": "UChicago"}' http://localhost/amanuensis/admin/projects
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"user_id": '"$USER_ID"', "name": "inrg-test-req1", "description": "inrg-test-req description", "filter_set_ids": [3], "institution": "UChicago"}' http://localhost/amanuensis/admin/projects

echo "Changing data request state"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"project_id": 1, "state_id": 3}' http://localhost/amanuensis/admin/projects/state

echo "Adding download URL for approved data request"
curl -X PUT  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"project_id": 1, "approved_url": "https://luca-pcdc-dev-approved-data-bucket.s3.amazonaws.com/PCDC-request_form.docx"}' http://localhost/amanuensis/admin/projects
