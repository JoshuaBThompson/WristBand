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

while True:
    if usb.any():
        data = usb.read(1)
        if data[0]==ord('x'):
            led.toggle()
            note = filter_x.get_note(accel.x())
            usb.send("%d,%d,%d\r\n" % (note, accel.y(), accel.z()))
            delay(20)





    



    

