"""
ldr.py
[Originally for Arduino]
Display analog data from Micropython board using Python (matplotlib)

Author: Mahesh Venkitachalam
Website: electronut.in
Edited for Micropython by: Joshua Thompson (jbthompson.eng@gmail.com)
"""

import subprocess
import argparse
from time import sleep
from collections import deque
from threading import Thread

import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
#from filter_motion import filterX
import time
import math


# plot class
class AnalogPlot:
    # constr
    def __init__(self, strPort, maxLen):
        # open serial port
        self.ser = serial.Serial(port=strPort, baudrate=115200)
        self.ax = deque([0.0]*maxLen)
        self.ay = deque([0.0]*maxLen)
        self.az = deque([0.0]*maxLen)
        self.count = 0
        self.max = 20
        self.average_y = 0
        self.average_sum_y= 0
        self.average_z = 0
        self.average_sum_z= 0
        self.maxLen = maxLen
        self.prev_time = 0
        self.current_time = 0
        self.xsum = 0
        self.running_average_y = 0
        self.running_average_z = 0
        self.max_ave_count = 15
        self.calc_average_y = [0 for i in range(self.max_ave_count)]
        self.calc_average_z = [0 for i in range(self.max_ave_count)]
        self.average_count = 0
        self.accel_scale_y = 16675.0 #lsb / 1g
        self.accel_scale_z = 17809.0 #lsb / 1g
        self.angle = 0.0

    # add to buffer
    def addToBuf(self, buf, val):
        if len(buf) < self.maxLen:
            buf.append(val)
        else:
            buf.pop()
            buf.appendleft(val)

    # add data
    def add(self, data):
        assert(len(data) == 3)
        self.addToBuf(self.ax, data[0])
        self.addToBuf(self.ay, data[1])
        self.addToBuf(self.az, data[2])
    # update plot
    def update(self, frameNum, a0, a1, a2):
        data = []
        try:
            print "writing"
            self.ser.write('x')

            #raw x = note data
            print "reading"
            yl = self.ser.read()
            yh = self.ser.read()
            #raw z

            zl = self.ser.read()
            zh = self.ser.read()


            print "calculating"
            y = (ord(yh) << 8) + ord(yl)
            if y >= 32768:
                y = y - 65536

            z = (ord(zh) << 8) + ord(zl)
            if z >= 32768:
                z = z - 65536

            if self.count < self.max:
                self.average_sum_y += y
                self.average_sum_z += z
                self.count+=1
            elif self.count == self.max:
                self.count+=1
                self.average_y = float(self.average_sum_y) / float(self.max)
                self.average_z = float(self.average_sum_z) / float(self.max)

            elif self.count == (self.max + 1):
                #y = y - self.average_y
                #y = float(y) / self.accel_scale_y

                #z = z - self.average_z
                #z = float(z) / self.accel_scale_z
                pass
            
            if self.average_count < self.max_ave_count and self.count >= (self.max +1):
                self.calc_average_y[self.average_count] = y
                self.calc_average_z[self.average_count] = z
                self.average_count += 1

            elif self.average_count == self.max_ave_count:
                self.running_average_y = 0
                self.running_average_z = 0
                for i in range(self.max_ave_count):
                    self.running_average_y += self.calc_average_y[i]
                    self.running_average_z += self.calc_average_z[i]
                
                self.running_average_y = self.running_average_y/float(self.max_ave_count)
                self.running_average_z = self.running_average_z/float(self.max_ave_count)
                self.average_count = 0
    
            if self.running_average_y >= -1*self.accel_scale_y and self.running_average_y <= 1*self.accel_scale_y:
                if self.running_average_z >= -1*self.accel_scale_z and self.running_average_z <= 1*self.accel_scale_z:
                    #self.angle = math.asin(self.running_average/1.0)*180.0/math.pi
                    self.angle = math.atan2(self.running_average_y, self.running_average_z)*180.0/math.pi
            
            print "y %f" % y
            print "running ave y %f" % self.running_average_y
            print "average y %f" % self.average_y
            print "z %f" % z
            print "running ave z %f" % self.running_average_z
            print "average z %f" % self.average_z
            print "angle %f" % self.angle
            




            #raw y = raw x accel data
            """
            yl = self.ser.read()
            yh = self.ser.read()
            y = (ord(yh) << 8) + ord(yl)
            if y >= 32768:
                y = y - 65536
            """
            
            


            data.append(self.angle)
            data.append(10.0*self.running_average_y) #multiply by 10 to scale with angle
            data.append(10.0*self.running_average_z)
            #data.append(int(z))

            # print data
            if(len(data) == 3):
                self.add(data)
                a0.set_data(range(self.maxLen), self.ax)
                a1.set_data(range(self.maxLen), self.ay)
                a2.set_data(range(self.maxLen), self.az)

        except KeyboardInterrupt:
            print('exiting')

        return a0,

    # clean up
    def close(self):
        # close serial
        self.ser.flush()
        self.ser.close()

# main() function
def main():
    # create parser
    parser = argparse.ArgumentParser(description="LDR serial")
    # add expected arguments
    parser.add_argument('--port', dest='port', required=True)
    # parse args
    args = parser.parse_args()

    #strPort = '/dev/tty.usbmodem1412'
    strPort = args.port

    print('reading from serial port %s...' % strPort)
    # plot parameters
    analogPlot = AnalogPlot(strPort, 200)
    print('plotting data...')

    # set up animation
    fig = plt.figure()
    ax = plt.axes(xlim=(0, 200), ylim=(-180, 180))
    a0, = ax.plot([], [], '-ro', markersize=3)
    a1, = ax.plot([], [], '-bo', markersize=3)
    a2, = ax.plot([], [], '-go', markersize=3)
    #anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0, a1, a2), interval=50)
    anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0, a1, a2), interval=10)

    # show plot
    plt.show()

    # clean up
    analogPlot.close()
    print('exiting.')
  

# call main
if __name__ == '__main__':
    main()
