#!/usr/bin/python3

from datetime import datetime
import json


# hiit: 1
# swim: 2
# soccer: 3
# walk: 4
# other: 5

value = 6
data = {}

with open("date.csv") as f:
    for line in f:
        day,sportType = line.strip().split(',')
        y,m,d = day.strip().split('/')
        dt = datetime(int(y), int(m), int(d), 0, 0, 0)
        data["%d"%(int(dt.timestamp()))] = int(sportType)

wf = open("data.json", "w")
wf.write(json.dumps(data))