# %% Trajectory
import os 
metDir = 'C:/HYSPLIT/met/NARR'
outDir = 'C:/HYSPLIT/output'
workingDir = 'C:/HYSPLIT/working'
os.chdir(workingDir)
print ('Current directory: ' + os.getcwd())

import datetime

lon = '115.2'
lat = '40.1'
shour = '06'
heights = ['100.0','500.0','1000.0']
hnum = len(heights)
hours = '48'
vertical = '0'
top = '10000.0'

fns = []
fn = 'gdas1.oct22.w2'
fns.append(fn)

# Set start/end time
stime = datetime.datetime(2022,10,8)


ctFile = './CONTROL'
print(stime.strftime('%Y-%m-%d ') + shour + ':00')
ctf = open(ctFile, 'w')
ctf.write(stime.strftime('%y %m %d ') + shour + "\n")
ctf.write(str(hnum) + '\n')
for i in range(0,hnum):
  ctf.write(lat + ' ' + lon + ' ' + heights[i] + '\n')
ctf.write(hours + '\n')
ctf.write(vertical + '\n')
ctf.write(top + '\n')
fnnum = len(fns)
ctf.write(str(fnnum) + '\n')
for i in range(0,fnnum):
    ctf.write(metDir + '/' + '\n')
    ctf.write(fns[i] + '\n')
ctf.write(outDir + '/' + '\n')
outfn = stime.strftime('traj_%Y%m%d')
ctf.write(outfn)
ctf.close()

os.system("C:\HYSPLIT\exec\hyts_std.exe")

print ('Finish...')
# %%
