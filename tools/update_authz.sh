#------------------------------------------------------
# Populate Arborist DB
#------------------------------------------------------
ACCESS_TOKEN=""
RESOURCE_JSON = '{"parent_path": "/services/", "name": "test", "description": "Amanuensis admin resource"}'
# permissions within the role could be an already existing permission, however it will be duplicated
# TODO see how to pull an existing permission and assign it to the create-role method
ROLE_JSON = '{"id": "test_admin", "description": "can do admin work on project/data request", "permissions": [{"id": "test_admin_action", "action": {"service": "test", "method": "*"}}]}'
POLICY_JSON = '{"id": "services.amanuensis-admin", "description": "admin access to amanunsis", "resource_paths": ["/services/amanuensis"], "role_ids": ["amanuensis_admin"]}'
USER_POLICY_JSON = '{"policy_name" = "services.amanuensis-admin", "username" = "graglia01@gmail.com"}'

# echo "Adding a resource"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d "$RESOURCE_JSON" http://localhost/user/admin/add_resource

# echo "Adding role"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d "$ROLE_JSON" http://localhost/user/admin/add_role

# echo "Adding a policy"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d "$POLICY_JSON" http://localhost/user/admin/add_policy

# echo "Assigning a policy to a user"
curl -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" -d "$USER_POLICY_JSON" http://localhost/user/admin/add_policy_to_user

