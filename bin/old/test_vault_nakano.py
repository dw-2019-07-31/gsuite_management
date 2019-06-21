def create_hold_drive_org(service, matter_id, org_unit_id):
    drive_query = {'includeTeamDriveFiles': True}
    org_unit = {'orgUnitId': org_unit_id}
    wanted_hold = {
        'name': 'My First Drive OU Hold',
        'corpus': 'DRIVE',
        'orgUnit': org_unit,
        'query': {
            'driveQuery': drive_query
        }
    }
    return service.matters().holds().create(
        matterId=matter_id, body=wanted_hold).execute()
