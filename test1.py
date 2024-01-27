#%%
# If not already installed, do: pip install pandas fastparquet
import pandas as pd

URL_DATA = 'https://storage.dosm.gov.my/population/population_district.parquet'

df = pd.read_parquet(URL_DATA)
if 'date' in df.columns: df['date'] = pd.to_datetime(df['date'])
print(df)
#%%
df = df[['date' ,'district','population']]
df1 = df[df['date']=='2020-01-01']

for i in range (2,4):
    globals()[f"df{i}"] = df[df['date']==f'202{i-1}-01-01']

#%%
for i in range(1,4):
    globals()[f"df{i}"]=  globals()[f"df{i}"].groupby(["district"])["population"].sum()

#%%
import shapefile as shp  # Requires the pyshp package
import matplotlib.pyplot as plt

sf = shp.Reader(r"C:\Users\USER\OneDrive\Desktop\Master\nuclear-wind\Mapping\Malaysia_shp\gadm36_MYS_2.shp")

plt.figure()
for shape in sf.shapeRecords():
    x = [i[0] for i in shape.shape.points[:]]
    y = [i[1] for i in shape.shape.points[:]]
    plt.plot(x,y)
plt.show()