

import xml.etree.ElementTree as ET

tree = ET.parse('export.xml')
root = tree.getroot()

for workout in root.findall('Workout'):
    type = workout.get('workoutActivityType')
    startDate =  workout.get('startDate')
    createDate = workout.get('creationDate')
    endDate = workout.get('endDate')
    duration = workout.get('duration')
    durationUnit =workout.get('durationUnit')
    print("{},{},{},{},{},{}".format(type, duration, durationUnit, createDate, startDate, endDate))
    
