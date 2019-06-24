#定数
DOMAIN = '@dadway.com'
ALL = 'all@dadway.com'
ALL_NAME = 'ALL'
ALL_DESCRIPTION = 'Whole Company Common'
EXECUTIVE = 'executive@dadway.com'
EXECUTIVE_NAME = 'EXECUTIVE'
EXECUTIVE_DESCRIPTION = 'Executive Conference'
DETERMINATION = 'determination@dadway.com'
DETERMINATION_NAME = 'DETERMINATION'
DETERMINATION_DESCRIPTION = 'Determination Report Conference'
ORGANIZATION_DESCRIPTION = 'Organization'
INTERNAL_DESCRIPTION = 'Internal Office'
EXTERNAL_DESCRIPTION = 'External Office'
PASSWORD = 'Dad880188'
HEAD = 'DW_'
MEMBER_ROLE = 'MEMBER'
#EMPLOYEE_FILE_NAME = '/mnt/gsuite/temporary/urano/社員情報.xlsx'
EMPLOYEE_FILE_NAME = '/script/tmp/社員情報.xlsx'
INTERNAL_FILE_NAME = '/mnt/gsuite/open/01_全社共通/GSuite_社内限定用アドレス_中村和寛/社内限定用アドレス管理表.xlsx'
EXTERNAL_SHOP_FILE_NAME = '/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表（店舗用）.xlsx'
EXTERNAL_PUBLIC_FILE_NAME = '/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表.xlsx'
#ORGUNIT = '/Gmail、HOのみ'
ORGUNIT = '/全許可'
#MANAGEMENT_GROUP = 'ICTG'
#PUBLIC_RELATION_GROUP = 'PRAG'
#WEB_GROUP = 'OSG'

#認証
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Directory API Ruby Quickstart'
CLIENT_SECRETS_PATH = '/script/etc/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "admin-directory_v1.yaml")
SETTING_CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "group_setting_v1.yaml")
VAULT_CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "vault_v1.yaml")
ADMIN_SCOPE = [Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP_MEMBER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT]
SETTING_SCOPE = [Google::Apis::GroupssettingsV1::AUTH_APPS_GROUPS_SETTINGS]
VAULT_SCOPE = [Google::Apis::VaultV1::AUTH_EDISCOVERY_READONLY]
# こっちが正解？　VAULT_SCORE = [Google::Apis::VaultV1]

