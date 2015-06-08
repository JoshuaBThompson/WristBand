from pyb import USB_VCP
from pyb import Accel
from pyb import delay
from pyb import LED
from filter_motion import *

filter_x = filterX()
accel = Accel()
delay(1000)
usb = USB_VCP()
led = LED(1)

def note_on(port, note, velocity=127):
    port.send(0x90)
    port.send(note)
    port.send(velocity)

    return

def note_off(port, note, velocity=0):
    port.send(0x80)
    port.send(note)
    port.send(velocity)
    return

delay(10000)
prev_note = None
scale = 1.5

while True:

    note = filter_x.get_note(accel.x())
    if note > 0:
        led.toggle()
        #debug
        #usb.send("%d,%d,%d\r\n" % (note, accel.y(), accel.z()))
        note = note*scale
        note = int(note)
        if prev_note:
            note_off(usb, prev_note, 0)

        note_on(usb, note, 127)
        prev_note = note

    delay(50)





    



    

