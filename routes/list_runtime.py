from flask import Blueprint,render_template
from flask import request
from flask.json import jsonify
import constants
import json
import requests
import datetime

list_runtime = Blueprint("list_runtime",__name__)

@list_runtime.route('')
def list_project_runtime():
    period_start, period_end = getOneHour()
    url = constants.FLASK_APP_URL + '/list_runtime/' + period_start + '/'+ period_end
    headers=getRequestHeader()
    r = requests.get(url, headers=headers, verify=False)
    input_json = r.text
    input_dict = json.loads(input_json)
    list_key_value = _countNumberOfHours(input_dict)
    return jsonify(list_key_value)

@list_runtime.route('/<period_start>/<period_end>')
def list_project_runtime_search(period_start, period_end):
    url = constants.METERING_ROUTE_LIST_ALL_PROJECTS
    headers = getRequestHeader()
    r = requests.get(url, headers=headers, verify=False)
    input_json = r.text
    input_dict = json.loads(input_json)
    output_dict = [x for x in input_dict if x['period_start'] >= period_start]
    data = [x for x in output_dict if x['period_end'] <= period_end]
    list_key_value = _countNumberOfHours(data)
    return jsonify(list_key_value)

def _countNumberOfHours(input_dict):
    ht=dict()
    for x in input_dict:
        if x['namespace'] in ht:
            ht[x['namespace']] += 1
        else:
            ht[x['namespace']] = 1 
    list_key_value = [ dict(namespace=k, activation_time=v) for k, v in ht.items() ]
    return list_key_value

def getRequestHeader():
    if constants.OPENSHIFT_TOKEN == False:
        return "Please set environment variables, execute config.sh first"
    headers = {'Authorization': 'Bearer ' + constants.OPENSHIFT_TOKEN,
    'Accept': 'application/json', 'Content-Type': 'application/json'}
    return headers

def getOneHour():
    now = datetime.datetime.utcnow()
    period_end = now.strftime("%Y-%m-%d"+"T"+"%H:00:00"+"Z")
    hour = int(now.strftime("%H"))
    if hour == 0: 
        hour = '23'
    else:
        hour = str(hour-2)
    if int(hour) < 12: 
        period_start = now.strftime("%Y-%m-%d"+"T0") + hour + ":00:00Z"
    else:
        period_start = now.strftime("%Y-%m-%d"+"T") + hour + ":00:00Z"
    return period_start, period_end