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
from filter_motion import filterX


class GenerateSound(object):
    """Generate sounds class
     Makes sounds based on the accelerometer value
    """
    def __init__(self):
        self.generate_command = subprocess.call
        self.cmds_dict = {}
        self.prev_note = None
        self.init_cmds_dict()

    def test(self):
        """test beat
        """
        note = "high"
        self.start_beat_thread(note, '200')

    def init_cmds_dict(self):
        """fill dict with lists of commands
           corresponding to ranges of accel values
        """

        #sys cmd = ['say','di']
        self.cmds_dict["high"] = ['say', '-r', '0', ' ']
        self.cmds_dict["low"] = ['say', '-r', '0', ' ']
        self.cmds_dict["off"] = ['say', '-r', '0', 'boom']

    def get_velocity(self, value, ref_value):
        """calculate velocity/amp of sound
        """
        rate = abs(value/ref_value) * 100
        rate = int(rate)
        rate = str(rate)
        return rate

    def make_beat(self, value):
        """make beat data from value
        """
        note = None
        value = int(value)
        ref_value = 12
        velocity = None
        if value >= ref_value:
            note = "high"
        elif value <= -ref_value:
            note = "low"

        elif value <= 5 and value >= -5:
            note = "off"

        print "beat value / note: %s / %s" % (value, note)

        #todo: use velocity

        if note:
            velocity = self.get_velocity(value, ref_value)
            print "start beat thread"
            self.toggle_beat(note, velocity)


    def toggle_beat(self, note="off", velocity='200'):
        """if beat was just played then turn it off
           otherwise generate the beat
        """
        if note in self.cmds_dict:

            #if not the same note from prev beat, then generate, otherwise skip
            if note != self.prev_note:
                self.prev_note = note
                self.start_beat_thread(note, velocity)


    def generate_beat(self, note="off", velocity='200'):
        """generate sound based on beat / velocity
           Todo: use midi?
        """

        #currently just using mac say module to make simple sounds (no velocity)
        if note in self.cmds_dict:
            cmds = self.cmds_dict[note]
            #override velocity
            cmds[2] = velocity
            self.generate_command(cmds)
            sleep(0.5)

    def start_beat_thread(self, note="off", velocity='200'):
        """generate a beat via thread
        """
        thread = Thread(target=self.generate_beat, args=[note, velocity])
        thread.start()

    
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
        self.sound_gen = GenerateSound()
        self.filter_x = filterX()
        self.start = True

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
    def update(self, frameNum, a0, a1):
        data = []
        try:
            self.ser.write('x')
            line = self.ser.readline().rstrip()
            line = line.split(",")
            x, y, z = line[0], line[1], line[2]

            x = int(x)
            n = self.filter_x.get_note(x)

            data.append(float(line[0]))
            data.append(float(n))
            data.append(float(line[1]))
            #data.append(float(line[2]))

            # print data
            if(len(data) == 3):
                self.add(data)
                a0.set_data(range(self.maxLen), self.ax)
                a1.set_data(range(self.maxLen), self.ay)
                #a2.set_data(range(self.maxLen), self.az)

            #self.sound_gen.make_beat(x)

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
    ax = plt.axes(xlim=(0, 200), ylim=(-40, 40))
    a0, = ax.plot([], [], '-ro', markersize=3)
    a1, = ax.plot([], [])
    #a2, = ax.plot([], [])
    #anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0, a1, a2), interval=50)
    anim = animation.FuncAnimation(fig, analogPlot.update, fargs=(a0,a1), interval=10)

    # show plot
    plt.show()

    # clean up
    analogPlot.close()
    print('exiting.')
  

# call main
if __name__ == '__main__':
    main()
