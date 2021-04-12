import xml.etree.ElementTree as Xet
import pandas as pd

cols = []
rows = []

xmlparse = Xet.parse('*.xml')
root = xmlparse.getroot()
for i in root:
    #column variables

    rows.append({#columnVar: val})

df = pd.DataFrame(rows, columns=cols)

df.to_csv('*.csv')

