
[Common]
# Indicates whether its the first start of the application.
FirstStart=1


BackupFolder=./data/backup/

[Translation]
# The directory of the translation files.
Directory=./translations/

[Engine:Providers]
# Authenticator.
# Types: off, basic
AuthenticationStatus=basic

# User view provider.
# Types: off, passwd, ldap
UserViewProviderType=ldap

# User edit provider.
# Types: off, passwd (no ldap here!)
UserEditProviderType=off

# Group view provider.
# The type 'ldap' can only be used here, if the 'UserViewProviderType' is 'ldap', too.
# Types: off, svnauthfile, ldap
GroupViewProviderType=ldap

# Group edit provider.
# Types: off, svnauthfile (no ldap here!)
GroupEditProviderType=off

# Access-Path view provider.
# Types: off, svnauthfile
AccessPathViewProviderType=svnauthfile

# Access-Path edit provider.
# Types: off, svnauthfile
AccessPathEditProviderType=svnauthfile

# Repository view provider.
# Types: off, svnclient
RepositoryViewProviderType=svnclient

# Repository edit provider.
# Types: off, svnclient
RepositoryEditProviderType=svnclient

[ACLManager]
# The path to the file which will contain the web interface role assignments for users.
UserRoleAssignmentFile=./data/userroleassignments.ini

[Subversion]
# The path to your subversion authorization file.
# It is the file where you configured all your repository permissions for the users.
SVNAuthFile=/etc/subversion/passwd

[Repositories:svnclient]
# The path where all the repositories takes place.
# Only a local path! (NOT: http:// or svn://)
# Note: No ending slash (/)!
SVNParentPath=/home/svn

# Absolute path to your svn.exe executable binary.
# If your svn directory is on PATH variable the value 'svn.exe' is enough.
SvnExecutable=/usr/bin/svn

# Absolute path to your svnadmin.exe executable binary.
# If your svn directory is on PATH variable the value 'svnadmin.exe' is enough.
SvnAdminExecutable=/usr/bin/svnadmin

[Users:passwd]
# The user database file.
SVNUserFile=/etc/subversion/passwd

[Users:digest]
# The user digest database file.
SVNUserDigestFile=
SVNDigestRealm=SVN Privat

[Ldap]
# The URL + port to the LDAP server.
HostAddress=ldap://192.168.1.133/

# The LDAP protocol version.
# (ActiveDirectory tested with 3 and OpenLDAP tested with 3)
ProtocolVersion=3

# The user which is used to connect to the LDAP and reads out all other users.
BindDN=CN=userbind,DC=edu,DC=br

# The password of the connection user.
BindPassword=mypassword

# Enables/disables the LDAP user and group caching provider.
CacheEnabled=false

# Storage file of LDAP user and group cache.
CacheFile=./data/ldap.cache.json

[Users:ldap]
# The organisation unit, where all other users takes place.
BaseDN=OU=Users,DC=edu,DC=br

# The filter, which identifies the object as a user object.
SearchFilter=(&(!(sAMAccountName=aluno))(objectClass=person)(!(objectClass=computer))(objectClass=user)(whenChanged>=20220105223344.0Z))

# The attribute which contains the user name, which is used by subversion(apache)
# and the iF.SVNAdmin application to authenticate the user.
# It's possible to define multiple attributes (comma separated) here to use them later
# in the "DisplayNameFormat" config-key. But keep in mind, that the first attribute is the
# one which is used to login.
Attributes=sAMAccountName

# Allows a custom format of the displayed user's name.
# It's possible to use additional user attributes from LDAP.
# Using LDAP attributes requires to fetch them by adding them to the "Attributes" config key.
# e.g.: %givenName %sn (%sAMAccountName)
DisplayNameFormat=%givenName %sn (%sAMAccountName)

[Groups:ldap]
# The organisation unit, where all groups take place.
BaseDN=OU=Groups,DC=edu,DC=br

# The filter, which identifies the object as a group object.
SearchFilter=(objectClass=group)

# The attribute which contains the group name, which is used by subversion(apache) to authorize the user.
Attributes=sAMAccountName

# The attribute which stores the association to the group members(user).
GroupsToUserAttribute=member

# The name of the user-attribute, which is stored in the 'groups_to_users_attribute'.
GroupsToUserAttributeValue=distinguishedName

[Update:ldap]
# Indicates whether the direct-permissions (not derived from a group)
# of deleted or unkown users (not found on LDAP server) should be removed on update.
AutoRemoveUsers=true

# Indicates whether the direct-permissions (not derived from a group)
# of deleted or unkown groups (not found on LDAP server) should be removed on update.
AutoRemoveGroups=true

[GUI]
# Allows the deletion of repositories via GUI.
# Set this to "false", if you don't want to allow the deletion of repositories in iF.SVNAdmin GUI.
RepositoryDeleteEnabled=false

# Allows the dumping of repositories via GUI.
# Set this to "false", if you don't want to allow the dumping of repositories in iF.SVNAdmin GUI.
# Note: This is an experimental feature! We do not recommend to use it!
RepositoryDumpEnabled=false

# Allows the update (synchronization) of updateable providers inside the GUI.
# If 'false', the update have to be started by 'cli.php' (command line) script.
AllowUpdateByGui=true

# The web url to the Apache WebDAV directory listing.
# Placeholders: %1=Repository name; %2=Relative path (no leading slash)
;ApacheDirectoryListing=https://svn.insanefactory.com/repositories/%1/%2

# The web url to the custom web-application to browse the subversion repository (e.g. ViewVC, WebSVN, ...)
# Placeholders: %1=Repository name; %2=Relative path (no leading slash)
;CustomDirectoryListing=http://localhost/svnadmin/repositoryview.php?r=%1&p=%2