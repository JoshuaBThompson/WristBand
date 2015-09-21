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


# plot class
class AnalogPlot:
    # constr
    def __init__(self, strPort, maxLen):
        # open serial port
        self.ser = serial.Serial(strPort, 9600)
        self.ax = deque([0.0]*maxLen)
        self.ay = deque([0.0]*maxLen)
        self.az = deque([0.0]*maxLen)
        self.maxLen = maxLen
        self.prev_time = 0
        self.current_time = 0

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
            #time.sleep(0.040)
            self.ser.write('x')

            #raw x = note data
            xl = self.ser.read()
            xh = self.ser.read()
            x = (ord(xh) << 8) + ord(xl)
            if x >= 32768:
                x = x - 65536

            #raw y = raw x accel data

            yl = self.ser.read()
            yh = self.ser.read()
            y = (ord(yh) << 8) + ord(yl)
            if y >= 32768:
                y = y - 65536


            #raw z

            zl = self.ser.read()
            zh = self.ser.read()
            z = (ord(zh) << 8) + ord(zl)
            z = z*1000;
            #if z >= 32768:
            #    z = z - 65536
            
            #print "z: %d" % z


            data.append(int(x))
            data.append(int(y))
            data.append(int(z))

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
    ax = plt.axes(xlim=(0, 200), ylim=(-30000, 80000))
    a0, = ax.plot([], [], '-ro', markersize=3)
    a1, = ax.plot([], [], '-bo', markersize=3)
    a2, = ax.plot([], [], '-go', markersize=3)
    #anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0, a1, a2), interval=50)
    anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0,a1,a2), interval=50)

    # show plot
    plt.show()

    # clean up
    analogPlot.close()
    print('exiting.')
  

# call main
if __name__ == '__main__':
    main()
