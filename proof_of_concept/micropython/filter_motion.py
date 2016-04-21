
#Constants for rising delX1 delX2 and delX3
RX1 = 3
RX2 = 4
RX3 = (RX1 + RX2)*0.75

#Constants for falling delX1 delX2 and delX3
FX1 = -5
FX2 = -5
FX3 = (FX1 + FX2)*1.5

#Max samples to count before throwing out rising slope if not falling slope is found
MaxSamples = 20
MinSamples = 4

#min average xsum
ASum = 6

class filterX(object):

    def __init__(self):
        self.del_x1 = None
        self.del_x2 = None
        self.del_x3 = None
        self.x1 = None
        self.x2 = None
        self.x3 = None
        self.xref = None
        self.xsum = 0
        self.rising = False
        self.falling = False
        self.sample_count = 2


    def get_del_x(self):
        """del_x1 = x2 - x1
           del_x2 = x3 - x2
           del_x3 = x3 - x1
        """
        if self.samples_ready():
            self.del_x1 = self.x2 - self.x1
            self.del_x2 = self.x3 - self.x2
            self.del_x3 = self.x3 - self.x1

        else:
            self.del_x1 = 0
            self.del_x2 = 0
            self.del_x3 = 0

        return self.del_x1, self.del_x2, self.del_x3

    def is_rising(self):
        """check if delx1 2 3 are showing a rising slope
           this indicates user is striking down
        """
        self.rising = (self.del_x1 > RX1) or (self.del_x2 > RX2) or (self.del_x3 > RX3)
        if self.rising:
            if self.x2 < self.x1 and self.x2 < self.x3:
                self.xref = self.x2
                self.x1 = self.x2
            else:
                self.xref = self.x1

        return self.rising

    def is_falling(self):
        """check if delx1 2 3 are showing a falling slope
           this indicates user is strike is rebounding
        """
        self.falling = (self.del_x1 < FX1) or (self.del_x2 < FX2) or (self.del_x3 < FX3)
        return self.falling

    def samples_ready(self):
        """see if all three x values have been filled
        """
        return self.x1 is not None

    def get_x_sum(self, xk):
        """xsum = xref + xk
           k = index of current sample
        """
        if self.rising:
            if not self.is_falling():
                self.xsum += xk - self.xref
                self.sample_count += 1

        elif self.is_rising():
            self.xsum += (self.x3 - self.xref) + (self.x2 - self.xref)
            self.sample_count += 1
        else:
            self.xsum = 0

        return self.xsum

    def update_x(self, xk):
        self.x1 = self.x2
        self.x2 = self.x3
        self.x3 = xk


    def reset(self):
        self.rising = False
        self.falling = False
        self.xsum = 0
        self.xref = None
        self.sample_count = 2

    def note_invalid(self):
        if self.falling:
            valid = self.sample_count <= MaxSamples\
            and self.sample_count >= MinSamples\
            and self.xsum/self.sample_count >= ASum
            return not valid
        else:
            return True

    def reset_needed(self):
        if self.falling:
            return True
        elif self.rising:
            return self.sample_count > MaxSamples
        else:
            return False


    def is_oversampled(self):
        return self.sample_count >= MaxSamples

    def is_undersampled(self):
        return self.sample_count <= MinSamples

    def get_note(self, xk):
        self.update_x(xk)
        self.get_del_x()
        xsum = self.get_x_sum(xk)
        valid = not self.note_invalid()
        note = (xsum * self.falling / self.sample_count)*(valid)
        reset = self.reset_needed()

        if reset:
            self.reset()


        return note











