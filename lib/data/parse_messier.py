import urllib.request as r
import json
import re

with open('c:/projects/astronomy_app/lib/data/messier_w_page.html', 'r', encoding='utf-8') as f:
    html = f.read()

table_match = re.search(r'<table class="wikitable sortable">(.*?)</table>', html, re.DOTALL)
if not table_match:
    table_match = re.search(r'<table class="wikitable sortable.*?>.*?(<tbody>.*?)</table>', html, re.DOTALL)
    if not table_match:
        print('table not found')
        exit(1)
        
table_html = table_match.group(1)

rows = re.findall(r'<tr.*?>(.*?)</tr>', table_html, re.DOTALL)
objects = []

def clean(t):
    t = re.sub(r'<.*?>', '', t)
    t = re.sub(r'&#160;', ' ', t)
    t = re.sub(r'\[.*?\]', '', t)
    t = t.replace('&amp;', '&').replace('\n', '')
    return t.strip()

for row in rows:
    th_match = re.search(r'<th.*?>(.*?)</th>', row, re.DOTALL)
    if not th_match: continue
    
    m_num = clean(th_match.group(1))
    if not m_num.startswith('M'): continue
    
    tds = re.findall(r'<td.*?>(.*?)</td>', row, re.DOTALL)
    if len(tds) >= 8:
        common_name = clean(tds[1])
        if common_name == '' or common_name == '-':
            common_name = m_num
            
        obj_type = clean(tds[3])
        dist = clean(tds[4])
        constel = clean(tds[5])
        mag_str = clean(tds[6])
        ra_str = clean(tds[7])
        dec_str = clean(tds[8])
        
        try:
            mag_clean = re.search(r'[-+]?\d*\.\d+|\d+', mag_str.replace(',','.')).group(0)
            mag = float(mag_clean)
        except:
            mag = 5.0
            
        try:
            h = float(re.search(r'(\d+)h', ra_str).group(1))
            m = float(re.search(r'(\d+)m', ra_str).group(1))
            s_match = re.search(r'(\d+(\.\d+)?)s', ra_str)
            s = float(s_match.group(1)) if s_match else 0
            ra = h + m/60.0 + s/3600.0
        except BaseException as e:
            ra = 0.0
            
        try:
            deg_match = re.search(r'([-+]?\d+)°', dec_str)
            d = float(deg_match.group(1))
            min_match = re.search(r'(\d+)′', dec_str)
            m = float(min_match.group(1)) if min_match else 0
            sec_match = re.search(r'(\d+(\.\d+)?)″', dec_str)
            s = float(sec_match.group(1)) if sec_match else 0
            
            sign = 1 if ('+' in dec_str or d >= 0 and '-' not in dec_str) else -1
            if '-' in dec_str and d == 0: sign = -1
            
            dec = abs(d) + m/60.0 + s/3600.0
            dec *= sign
        except:
            dec = 0.0

        objects.append({
            'id': m_num,
            'name': common_name,
            'type': obj_type,
            'distance': dist,
            'constellation_latin': constel,
            'magnitude': mag,
            'raHours': ra,
            'decDegrees': dec
        })

print(f'{len(objects)} objects parsed successfully!')
with open('c:/projects/astronomy_app/lib/data/messier_parsed.json', 'w', encoding='utf-8') as f:
    json.dump(objects, f, ensure_ascii=False, indent=2)
