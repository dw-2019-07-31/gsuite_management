#ドメイン
DOMAIN = '@dadway.com'
#会議体アドレス
#ALL = 'all@dadway.com'
#CONFERENCES = ['executive@dadway.com',
#                'mirai@dadway.com',
#                'business_managers@dadway.com',
#                'contact@dadway.com']
#EXECUTIVE = 'executive@dadway.com'
#DETERMINATION = 'determination@dadway.com'
#会議体名
#ALL_NAME = 'ALL'
#EXECUTIVE_NAME = 'EXECUTIVE'
#DETERMINATION_NAME = 'DETERMINATION'
#グループ概要
#ALL_DESCRIPTION = 'Whole Company Common'
#DETERMINATION_DESCRIPTION = 'Determination Report Conference'
#EXECUTIVE_DESCRIPTION = 'Executive Conference'
ORGANIZATION_DESCRIPTION = 'Organization'
INTERNAL_DESCRIPTION = 'Internal Office'
EXTERNAL_DESCRIPTION = 'External Office'
#その他
PRIVATE = 'ALL_IN_DOMAIN_CAN_POST'
PUBLIC = 'ANYONE_CAN_POST'
SHOW_DIRECTORY = 'true'
PASSWORD = 'Dad880188'
HEAD = 'DW_'
MEMBER_ROLE = 'MEMBER'
#ファイルパス
EMPLOYEE_FILE_NAME = ['./tmp/社員情報.xlsx']
#INTERNAL_FILE_NAME = '/mnt/gsuite/open/01_全社共通/GSuite_社内限定用アドレス_中村和寛/社内限定用アドレス管理表.xlsx'
INTERNAL_FILE_NAME = ['C:/Users/s_urano/Desktop/社内限定用アドレス管理表.xlsx']
#EXTERNAL_SHOP_FILE_NAME = '/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表（店舗用）.xlsx'
#EXTERNAL_PUBLIC_FILE_NAME = '/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表.xlsx'
#EXTERNAL_FILE_NAME = ['/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表（店舗用）.xlsx',
#                    '/mnt/gsuite/close/ADIV/ADIV_Share/GSuite_アドレス帳/外部公開用アドレス管理表.xlsx']
EXTERNAL_FILE_NAME = ['C:/Users/s_urano/Desktop/外部公開用アドレス管理表（店舗用）.xlsx',
                        'C:/Users/s_urano/Desktop/外部公開用アドレス管理表.xlsx']
#組織部門
ORGUNIT = '/全許可'
ORGUNIT_ICTG = '/ICTG'
MANAGEMENT_GROUP = 'ICTG'
#認証関連
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Directory API Ruby Quickstart'
#CLIENT_SECRETS_PATH = '/script/etc/client_secret.json'
CLIENT_SECRETS_PATH = './etc/client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "admin-directory_v1.yaml")
SETTING_CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "group_setting_v1.yaml")
ADMIN_SCOPE = [Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP_MEMBER,
         Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT]
SETTING_SCOPE = [Google::Apis::GroupssettingsV1::AUTH_APPS_GROUPS_SETTINGS]
