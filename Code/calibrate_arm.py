import serial
import struct
import time
from config_robot import MicroROS_Robot

if __name__ == "__main__":
    bot = MicroROS_Robot(debug=False)
    version = bot.read_version()
    print("version:", version)
    bot.set_arm_torque(1)
    time.sleep(.5)
    bot.set_arm_torque(0)
    time.sleep(.5)
    adjust = input("Input y for end of adjusting:")
    if adjust == 'y' or 'Y':
        for i in range(1,7):
            state = bot.set_arm_calib_offset(i)
            if state < 0:
                state = bot.set_arm_calib_offset(i)
            print("state=", i, state)
        print("Calibration successfully!")
        bot.set_arm_torque(1)
        del bot