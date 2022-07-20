#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul 13 14:19:34 2022

@author: ali
"""

import dcor
import math

import numpy as np
from timeit import timeit
import matplotlib.pyplot as plt
from numpy import random
import time

def vertex(x, y, delta=0.05, z=None, return_plot = False, verbose=False):
    
    V=np.arange(0, x.shape[2], 1, dtype=int)

    V_temp=V
    V_dim=V_temp.shape
    V_dim,=V_dim
    x_reduced=x

    dcors=[]
    V_temp_all = []
    k=0
    V_temp_all = []
    c_all=[]
    V_temp_all.append(V)
    if verbose:
        print('Begin iterating process')
    while V_dim > 1:
        time1= time.time()
        c=[]
        V_index=[]
        for u in V_temp:
            xtemp=x[:,V_temp,:]
            #print(xtemp.shape)
            xtemp=xtemp[:,:,u]
            #print(xtemp)
            #print(dcor.distance_correlation(xtemp, y))
            if z is None:
                c=np.append(c,dcor.distance_correlation(xtemp, y))
            else:
                c=np.append(c,dcor.partial_distance_correlation(xtemp, y,z)) #partial distance correlation

        dcors.append(np.max(c))
        t_temp=np.quantile(c,delta) 
        index_temp=c>t_temp
        
        V_temp = np.array(V_temp_all[k])[index_temp]
        V_temp_all.append(V_temp)
        c_all.append(c)         
        V_dim=np.size(V_temp)
        time_step = time.time() - time1
        if verbose:
            print(f'Step {k} accomplished in {np.round(time_step)} secs, max time {np.round(x.shape[1]*time_step*(1-delta)**k)}')
        k=k+1
        
    index_winner=np.max(np.argwhere(dcors == np.amax(dcors)))
    
    if verbose:    
        print(dcors[index_winner])
        print(V_temp_all[index_winner].shape)

    V_winner=V_temp_all[index_winner]
    c_winner=c_all[index_winner]
    
    if return_plot:
        import matplotlib.pyplot as plt
        dimensions=[x.shape[0]for x in V_temp_all]
        plt.scatter( dimensions[0:len(dimensions)-1] , dcors )
        plt.title("Signal Distance Correlation")
        plt.xlabel("Dimension of Vertices")
        plt.ylabel("Maximum Distance Correlation")
        plt.savefig('/Users/daniel/Downloads/algo1fig.png', dpi=1000)
        return V_winner, c_winner, dcors, plt
    else:
        return V_winner, c_winner, dcors