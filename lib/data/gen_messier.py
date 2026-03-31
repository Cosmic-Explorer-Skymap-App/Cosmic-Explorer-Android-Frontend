import json

with open('c:/projects/astronomy_app/lib/data/messier_parsed.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

dart_code = '''import '../models/messier_object.dart';

const List<MessierObject> messierData = [
'''

for d in data:
    name = d.get('name', '').replace("'", "\\'")
    type_ = d.get('type', '').replace("'", "\\'")
    distance = d.get('distance', '').replace("'", "\\'")
    constellation = d.get('constellation_latin', '').replace("'", "\\'")
    id_val = d.get('id', '')
    mag = d.get('magnitude', 0.0)
    ra = d.get('raHours', 0.0)
    dec = d.get('decDegrees', 0.0)
    
    dart_code += f'''  MessierObject(
    id: '{id_val}',
    name: '{name}',
    type: '{type_}',
    distance: '{distance}',
    constellationLatin: '{constellation}',
    magnitude: {mag},
    raHours: {ra},
    decDegrees: {dec},
  ),
'''

dart_code += '];\n'

with open('c:/projects/astronomy_app/lib/data/messier_data.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)
