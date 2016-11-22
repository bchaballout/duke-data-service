import dredd_hooks as hooks
import imp
import os
import json
import uuid
#if you want to import another module for use in this workflow
from dataservice.config import create_config
from dataservice.core.remotestore import RemoteStore, RemoteAuthRole
from dataservice.core.ddsapi import DataServiceApi, DataServiceError, DataServiceAuth
config = create_config()
auth = DataServiceAuth(config)
data_service = DataServiceApi(auth, config.url)


###############################################################################
###############################################################################
#           PROJECTS
###############################################################################
###############################################################################
@hooks.before("Projects > Projects collection > Create project")
def change_proj_name(transaction):
    name = str(uuid.uuid4())
    description = "Created by dredd under: Projects > Projects collection > Create project"
    requestBody = json.loads(transaction[u'request'][u'body'])
    requestBody['name'] = name
    requestBody['description'] = description
    transaction[u'request'][u'body'] = json.dumps(requestBody)
@hooks.after("Projects > Projects collection > Create project")
def set_project_id(transaction):
    global project_id
    json_trans = json.loads(transaction[u'real'][u'body'])
    project_id = json_trans['id']
@hooks.before("Projects > Projects collection > List projects")
@hooks.before("Projects > Project instance > View project")
def change_trans_id(transaction):
    url = transaction['fullPath']
    transaction['fullPath'] = str(url).replace('ca29f7df-33ca-46dd-a015-92c46fdb6fd1',project_id)
@hooks.before("Projects > Project instance > Update project")
def change_proj_name2(transaction):
    url = transaction['fullPath']
    transaction['fullPath'] = str(url).replace('ca29f7df-33ca-46dd-a015-92c46fdb6fd1',project_id)
    name = str(uuid.uuid4())
    description = "Created by dredd unders: Projects > Projects collection > Create project"
    requestBody = json.loads(transaction[u'request'][u'body'])
    requestBody['name'] = name
    requestBody['description'] = description
    transaction[u'request'][u'body'] = json.dumps(requestBody)
@hooks.before("Projects > Project instance > Delete project")
def create_a_del_project(transaction):
    name = str(uuid.uuid4())
    description = "Created by dredd under: Projects > Projects collection > Create project"
    neww = data_service.create_project(name,description)
    url = transaction['fullPath']
    transaction['fullPath'] = str(url).replace('ca29f7df-33ca-46dd-a015-92c46fdb6fd1', str(json.loads(neww.text)['id']))
@hooks.before("Projects > Project instance > NOT_IMPLEMENTED_NEW Project usage")
def skippy3(transaction):
    transaction['skip'] = True
