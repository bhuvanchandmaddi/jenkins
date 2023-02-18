### Managing users and groups
* When we create users then by default they will get all the access
* We can restrict that behaviour using plugin called *Role based authentication Strategy*
* After installing the plugin set Authorization Role based policy in Configure Global Security

### Create a user and assign role to view the jobs
* Navigate to Manage jenkins -> Manage users and create user
* Navigate to Manage Jenkins -> Manage and Assign Roles and create a role
* Give overall read and read jobs permissions only
* Bind user to the role by navigating to assign roles
* Verify by logging into the jenkins with newly create user

### Create a user and assign role to execute the jobs
* Perform samesteps but in role select build jobs option

### Few tips
* You can create global variables variables(Manage Jenkins ->
Configure System->Global properties) in jenkins, so that they can be used in any pipeline.
