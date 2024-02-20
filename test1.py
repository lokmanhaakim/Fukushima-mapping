# %% Trajectory
import os 
metDir = 'C:/HYSPLIT/met/NARR'
outDir = 'C:/HYSPLIT/output'
workingDir = 'C:/HYSPLIT/working'
os.chdir(workingDir)
print ('Current directory: ' + os.getcwd())

import datetime

lon = '115.2'
lat = ['40.1','40.5']
shour = '06'
heights = ['100.0','500.0','1000.0']
hnum = len(heights)
hlat = len(lat)
hours = '48'
vertical = '0'
top = '10000.0'

fns = []
fn = 'gdas1.oct22.w2'
fns.append(fn)

# Set start/end time
stime = datetime.datetime(2022,10,8)

######
ctFile = './CONTROL'
print(stime.strftime('%Y-%m-%d ') + shour + ':00')
#
ctf = open(ctFile, 'w')
ctf.write(stime.strftime('%y %m %d ') + shour + "\n")
ctf.write(str(hnum*hlat) + '\n')
for i in range(0,hnum):
  for j in range (0,hlat):
    ctf.write(lat[j] + ' ' + lon + ' ' + heights[i] + '\n')
ctf.write(hours + '\n')
ctf.write(vertical + '\n')
ctf.write(top + '\n')
fnnum = len(fns)
ctf.write(str(fnnum) + '\n')
for i in range(0,fnnum):
    ctf.write(metDir + '/' + '\n')
    ctf.write(fns[i] + '\n')
ctf.write(outDir + '/' + '\n')
# outfn = stime.strftime('traj_%Y%m%d')
outfn = stime.strftime('tryJaboh')
ctf.write(outfn)
ctf.close()
os.system("C:\HYSPLIT\exec\hyts_std.exe")

print ('Finish...')

# %% Concentration
import os 
metDir = 'C:/HYSPLIT/met/NARR'
outDir = 'C:/HYSPLIT/output'
workingDir = 'C:/HYSPLIT/working'
os.chdir(workingDir)
print ('Current directory: ' + os.getcwd())

import datetime

lon = '115.2'
lat = ['40.1']
shour = '06'
heights = ['100.0']
hnum = 1      #len(heights)
hlat =  1     #len(lat)
hours = '148'
vertical = '0'
mix_layer = '1000.0'
top = '10000.0'

num_polutant = '1'
nuclide = 'C137'
emission = '5.9E14'
emssion_rate='1.0'
start_hourAccident = '17'

num_grids = '1'
centre_lat = '0.0'
centre_lon = '0.0'
spacing_lat = '0.05'
spacing_lon = '0.05'
span_lat = '50.0'
span_lon = '50.0'
output_dir = './'
output_name = 'cdump'
vert_levels = '2'
height_down = '0'
height_up = '50'
type_calc = '00'
hrs = '06'
min = '00'

deposition ='1'
particlediameter = '5.0 6.0 1.0'
constant1 = '0.006 0.0 0.0 0.0 0.0'
constant2 = '0.0 8.0E-05 8.0E-05'
decay = '10960.0'
re_factor = '0.0'

fns = []
fn = ['gdas1.apr22.w1','gdas1.apr22.w2','gdas1.apr22.w3','gdas1.apr22.w4']
for i in range(0,len(fn)):
  fns.append(fn[i])

# Set start/end time
stime = datetime.datetime(2022,4,8)
stimeaccident = datetime.datetime(2022,4,8)
# samplestart=datetime.datetime(0,0,0,0,0)
# sampleend=datetime.datetime(00,00,00,00,00)

#
ctFile = './default_conc'
print(stime.strftime('%Y-%m-%d ') + shour + ':00')
#
ctf = open(ctFile, 'w')
ctf.write(stime.strftime('%y %m %d ') + shour + "\n")
ctf.write(str(hnum*hlat) + '\n')
for i in range(0,hnum):
  for j in range (0,hlat):
    ctf.write(lat[j] + ' ' + lon + ' ' + heights[i] + '\n')
ctf.write(hours + '\n')
ctf.write(vertical + '\n')
ctf.write(top + '\n')
fnnum = len(fns)
ctf.write(str(fnnum) + '\n')
for i in range(0,fnnum):
    ctf.write(metDir + '/' + '\n')
    ctf.write(fns[i] + '\n')
ctf.write(num_polutant + '\n')
ctf.write(nuclide + '\n')
ctf.write(emission+'\n')
ctf.write(emssion_rate+'\n')
# ctf.write(stime.strftime('%y %m %d ') + shour + "\n")
ctf.write(stimeaccident.strftime('%y %m %d ')+start_hourAccident+' 00'+'\n')
ctf.write(num_grids+'\n')
ctf.write(centre_lat+" ")
ctf.write(centre_lon+'\n')
ctf.write(spacing_lat+" ")
ctf.write(spacing_lon+'\n')
ctf.write(span_lat+' ')
ctf.write(span_lon+'\n')
ctf.write(output_dir+'\n')
ctf.write(output_name+'\n')
ctf.write(vert_levels+'\n')
ctf.write(height_down+' ')
ctf.write(height_up+'\n')
ctf.write('00 00 00 00 00'+'\n')
ctf.write('00 00 00 00 00'+'\n')
ctf.write(type_calc+' '+hrs+' '+min+"\n")
ctf.write(deposition+'\n')
ctf.write(particlediameter+'\n')
ctf.write(constant1+"\n")
ctf.write(constant2+"\n")
ctf.write(decay+'\n')
ctf.write(re_factor)
ctf.close()

os.system("C:\HYSPLIT\exec\hycs_std.exe")

os.system("C:\HYSPLIT\working\concplot.bat")
print ('Finish...')