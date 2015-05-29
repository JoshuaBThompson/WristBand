import pyb
from midi import Controller
from pyb import delay

switch = pyb.Switch()
serial = pyb.USB_VCP()
instrument1 = Controller(serial, channel=1)

def make_beat():
    if instrument1.beat_set:
        instrument1.note_off(65)
        instrument1.beat_set = False
    else:
        instrument1.note_on(65, 127)
        instrument1.beat_set = True

class GenerateSound(object):
    """Generate sounds class
     Makes sounds based on the accelerometer value
    """
    def __init__(self):
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



