from pyb import USB_VCP
from pyb import Accel
from pyb import delay
from pyb import LED

accel = Accel()
delay(1000)
usb = USB_VCP()
led = LED(1)

while True:
    if usb.any():
        data = usb.read(1)
        if data[0]==ord('x'):
            led.toggle()
            usb.send("%d,%d,%d\r\n" % (accel.x(), accel.y(), accel.z()))
            delay(20)





    



    

