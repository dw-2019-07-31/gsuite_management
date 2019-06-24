#ドメイン
DOMAIN = '@dadway.com'
#会議体アドレス
HEAD = 'DW_'
ORGANIZATION_DESCRIPTION = "Organization"
#ファイルパス
EMPLOYEE_FILE_NAME = ['/home/gsuite/社員情報.xlsx']
#組織部門
ORGUNIT = '/全許可'
ORGUNIT_ICTG = '/ICTG'
MANAGEMENT_GROUP = 'ICTG'
#認証関連
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Directory API Ruby Quickstart'
CLIENT_SECRETS_PATH = '/script/etc/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "admin-directory_v1.yaml")
SETTING_CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "group_setting_v1.yaml")
ADMIN_SCOPE = [Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP_MEMBER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT]
SETTING_SCOPE = [Google::Apis::GroupssettingsV1::AUTH_APPS_GROUPS_SETTINGS]
