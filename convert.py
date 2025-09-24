#!/usr/bin/python3

from datetime import datetime
import json


# hiit: 1
# swim: 2
# soccer: 3
# walk: 4
# other: 5

type2021 = {"hiit":1, "swim":2, "soccer":3, "walk":4, "other":5}
type2022 = {"hiit":1, "swim":2, "soccer":3, "surfskate":4, "other":5}
type2023 = {"hiit":1, "swim":2, "soccer":3, "surfskate":4, "other":5}
type2024 = {"hiit":1, "swim":2, "soccer":3, "surfskate":4, "other":5}


finType = type2024
csvFileName = "2024.csv"

value = 6
data = {}

with open(csvFileName) as f:
    for line in f:
        print(line.strip().split(','))
        x = line.strip().split(',')
        if not x[1] :
            continue;
        day,sportType = x[0],x[1]
        y,m,d = day.strip().split('/')
        dt = datetime(int(y), int(m), int(d), 0, 0, 0)
        if sportType in  finType:
            data["%d"%(int(dt.timestamp()))] = int(finType[sportType])
        else:
            data["%d"%(int(dt.timestamp()))] = int(finType["other"])

wf = open("data.json", "w")
wf.write(json.dumps(data))
