#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul 11 11:59:01 2022

@author: ali
"""

#!pip install xarray
#!pip install pyreadr

import numpy as np
import pyreadr


data_path='/Users/daniel/Downloads/Archive/' 
x=np.load(data_path +"connectivity.npy")
x.shape
xx=x.transpose()
xx.shape
x=xx


####age

y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Age_Months"]








########################### diet
y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Diet"]
y[y=="HFD"]=-1;
y[y=="Control"]=1;
type(y)
y


########################### geno
y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Genotype"]
print(np.unique(y))
y[y=="APOE22"]=1;
y[y=="APOE22HN"]=1;
y[y=="APOE33"]=2;
y[y=="APOE33HN"]=2;
y[y=="APOE44"]=3;
y[y=="APOE44HN"]=3;

y

########################### sex
y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Sex"]
y[y=="male"]=-1;
y[y=="female"]=1;
type(y)
y

########################### geno,diet 
#########################
####################
############3
y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Genotype"]
print(np.unique(y))
y[y=="APOE22"]=1;
y[y=="APOE22HN"]=1;
y[y=="APOE33"]=2;
y[y=="APOE33HN"]=2;
y[y=="APOE44"]=3;
y[y=="APOE44HN"]=3;

y1=y



y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Diet"]
y[y=="HFD"]=-1;
y[y=="Control"]=1;
type(y)
y2=y


y=np.column_stack((y1,y2))





########################### geno,diet , age, sex
#########################
####################
############3
y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Genotype"]
print(np.unique(y))
y[y=="APOE22"]=1;
y[y=="APOE22HN"]=1;
y[y=="APOE33"]=2;
y[y=="APOE33HN"]=2;
y[y=="APOE44"]=3;
y[y=="APOE44HN"]=3;

y1=y



y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Diet"]
y[y=="HFD"]=-1;
y[y=="Control"]=1;
type(y)
y2=y


y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Age_Months"]
y3=y


y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
print(y)
y=y["Sex"]
y[y=="male"]=-1;
y[y=="female"]=1;
type(y)
y4=y

y=pyreadr.read_r(data_path + 'response.rda')
y=y["response"]
day0y=y["Day0_Learning_Slope"]
day1y=y["Day1_Contextual_Freezing"]
day2y=y["Day2_Tone_Freezing"]

#y=np.column_stack((y1,y2, y3, y4))
#y=np.column_stack((y1,y2, y4))
#y=np.column_stack((y1,y2))
#y=np.column_stack((y2,y4))
y=np.column_stack((day0y, day1y, day2y))


#


#V,c,d, plt = vertex(x,y,z=y4, return_plot=True, verbose=True)
V,c,d, figure = vertex(x,y, return_plot=True, verbose=True)



no_read_path='/Users/daniel/Downloads/Archive/noreadcsf.rda'
no_read=pyreadr.read_r(no_read_path)
no_read=no_read['noreadcsf'].to_numpy()

all_index=list(range(360))
python_no_read = [int(x[0] - 1) for x in no_read ]

labels = [i for i in V]

for i in range(len(labels)):
    for j in python_no_read:
        if j <= labels[i]:
            labels[i] += 1


# all_index=[i for i in all_index if i not in python_no_read]

# atlas=all_index





'''
import pandas
atlas=pandas.read_csv('/Users/ali/Desktop/Jul/apoe/mouse_anatomy.csv')
#noreadcsf=[148,152,161,314,318,327]
# remove white matter too:
noreadcsf=[ 148, 152, 161, 314, 318, 327, 120, 121, 122, 134, 102, 118, 119, 123, 124, 125, 126,
127, 128, 129, 130, 131, 132, 133, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144,
145, 146, 147, 150, 268, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295,
296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312,
313, 316]


noreadcsf=[x - 1 for x in noreadcsf]



atlas=atlas.drop(atlas.index[noreadcsf])


report=atlas.iloc[V]
'''

import pandas as pd

# labels = [atlas[i] + 1 for i in V]

report = pd.DataFrame(list(zip(labels, c.tolist())), columns =['Label Index', 'DCor'])

'''
report = [atlas[i] for i in V]
print(report)

report=atlas[V]
report['score']=c
'''
report=report.sort_values('DCor', ascending=False)

print(report)

report.to_csv('/Users/daniel/Downloads/regions.csv', index=False)

