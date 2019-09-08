import matplotlib as mplt
mplt.use('Agg')

import matplotlib.pyplot as plt
import Nio, sys, argparse
import numpy as np
from scipy import signal
from pprint import pprint

def mavg(y, span):
 
    N = len(y)
    yy = np.zeros((N,))
    if span == 1:
        yy[:] = y

    else: 
        for i in range(N):
            if i < span:
                rng = slice(0, i+1)
                yy[i] = np.nan
            else:
                rng = slice(i-span,i)
                yy[i] = np.mean(y[rng])
        
    return yy


parser = argparse.ArgumentParser()
parser.add_argument('--input-dir')
parser.add_argument('--output-dir')
parser.add_argument('--casenames')
parser.add_argument('--legends')
parser.add_argument('--data-file')
parser.add_argument('--varname')
parser.add_argument('--mavg', type=int, default=1)
parser.add_argument('--yscale', type=float, default=1.0)
parser.add_argument('--ylabel', default="")
parser.add_argument('--extra-title', default="")
parser.add_argument('--colors')
parser.add_argument('--linestyles', type=str)
parser.add_argument('--t-offset', type=float, default=0.0)
parser.add_argument('--indexing', default=":")

args = parser.parse_args()

pprint(args)

casenames = args.casenames.split(",")
legends   = args.legends.split(",")
colors = args.colors.split(",")
linestyles = args.linestyles.split(",")

indices = []
print("Constructing indexing")
for i, content in enumerate(indexing):
    if content == ":":
        indices.append(slice(None))
    else:
        indices.append(int(content))

indices = tuple(indices)
print("Indices: ", indices)    
 
print("Going to compare these models:")
pprint(casenames)

tss = []

new_casenames = []

for i in range(len(casenames)):

    try:

        f = Nio.open_file("%s/%s/%s" % (args.input_dir, casenames[i], args.data_file), "r")

    except Exception as e:
    
        print("Error happens when doing casename %s. Going to ignore this one..." % casenames[i])

        continue
    
    
    new_casenames.append([casenames[i], legends[i], colors[i], linestyles[i]])
    ts = mavg(f.variables[args.varname][indices] / args.yscale, args.mavg)

    tss.append(ts)
    
    f.close()

casenames = new_casenames

N = len(tss[0])
time = np.arange(N) / 12 + args.t_offset
nyears = N / 12.0

fig, ax = plt.subplots(1, 1, figsize=(12, 8))


ax.set_title("%s (%d years) %s" % (args.varname, nyears, args.extra_title))
ax.set_xlabel("Time [years]")
ax.set_ylabel(args.ylabel)
ax.grid()
for i, (casename, legend, color, linestyle) in enumerate(casenames): 
    ax.plot(time, tss[i], linewidth=2, label=legend, color=color, linestyle=linestyle)

ax.legend()
ax.grid()

fig.savefig("%s/mc_timeseries_%s.png" % (args.output_dir, args.varname), dpi=200)

#plt.show()
