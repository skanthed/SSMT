from flask import Flask
from flask import request
from flask.json import jsonify
from flask_cors import CORS
import signal
import os
import sys
import json
import requests
import datetime

app = Flask(__name__)
OPENSHIFT_TOKEN = os.environ.get("OS_OPENSHIFT_TOKEN")
FLASK_APP_URL = 'http://' + str(os.environ.get("HOST","localhost")) +':'+str(os.environ.get("PORT", 8000))
METERING_ROUTE_LIST_ALL_PROJECTS = os.environ.get("OS_LIST_ALL_PROJECTS_URL")
cors = CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/list_projects')
def list_projects():
    now = datetime.datetime.utcnow()
    period_end = now.strftime("%Y-%m-%d"+"T"+"%H:00:00"+"Z")
    hour = int(now.strftime("%H"))
    if hour == 0: 
        hour = '23'
    else:
        hour = str(hour-1)
    if int(hour) < 12: 
        period_start = now.strftime("%Y-%m-%d"+"T0") + hour + ":00:00Z"
    else:
        period_start = now.strftime("%Y-%m-%d"+"T") + hour + ":00:00Z"
    url = FLASK_APP_URL + '/list_projects/' + period_start + '/'+ period_end
    r = requests.get(url, verify=False)
    return r.text

@app.route('/list_projects/<period_start>/<period_end>')
def get_project_reports(period_start, period_end):
    if OPENSHIFT_TOKEN == False:
        return "Please set environment variables, execute config.sh first"
    headers = {'Authorization': 'Bearer ' + OPENSHIFT_TOKEN,
    'Accept': 'application/json', 'Content-Type': 'application/json'}
    url = METERING_ROUTE_LIST_ALL_PROJECTS
    r = requests.get(url, headers=headers, verify=False)
    input_json = r.text
    input_dict = json.loads(input_json)
    output_dict = [x for x in input_dict if x['period_start'] >= period_start]
    data = [x for x in output_dict if x['period_end'] <= period_end]
    if len(data) == 0:
        return "Report are not Generated. Please Wait until OpenShift Cluster Collect Metrics"
    else:
        return jsonify(data)

def signal_term_handler(signal, frame):
    app.logger.warn('got SIGTERM')
    sys.exit(0)

if __name__ == '__main__':
    signal.signal(signal.SIGTERM, signal_term_handler)
    app.run(host=str(os.environ.get("HOST","localhost")), port=int(os.environ.get("PORT", 8000)))
