import rclpy
from rclpy.node import Node
from std_msgs.msg import String
from geometry_msgs.msg import Twist
import serial

class SimpleAbotInterface(Node):
    def __init__(self):
        super().__init__('simple_abot_interface')
        self.subscription = self.create_subscription(
            Twist,
            'abot/cmd_vel',
            self.cmd_vel_cb,
            10)
        
        self.encoder_pub = self.create_publisher(String, 'abot/encoder_string', 10)
        # run about twice as fast as the 10Hz encoder pub from arduino
        self.timer = self.create_timer(0.05, self.run_serial)

        self.port = "/dev/ttyACM0"
        self.ser = serial.Serial(self.port, 115200, timeout=0.01)
        self.cmd_string = b'rn00.00,ln00.00,' # init to 0 vel

    def cmd_vel_cb(self, msg):
        v = msg.linear.x
        omega = msg.angular.z

        # set left and right wheel speeds in m/s-ish
        vel_l = v - omega
        vel_r = v + omega
        # TODO: edit Arduino code to use RPM instead to avoid updating based on robot dimensions
        # something like:
        # vel_l = ((msg.linear.x - (msg.angular.z * self.wheel_bias / 2.0)) / self.wheel_radius) * 60/(2*3.14159)
        # vel_r = ((msg.linear.x + (msg.angular.z * self.wheel_bias / 2.0)) / self.wheel_radius) * 60/(2*3.14159)

        if vel_l < 0.0:
            sign_l = 'n'
            vel_l = -vel_l
        else:
            sign_l = 'p'
        if vel_r < 0.0:
            sign_r = 'n'
            vel_r = -vel_r
        else:
            sign_r = 'p'
        # format: b'rn00.00,ln00.00,'
        self.cmd_string = ("r%s%02.2f,l%s%02.2f" %(sign_r, vel_r, sign_l, vel_l)).encode("UTF-8")
    
    def run_serial(self):
        encoders = self.ser.read_until('\n')
        self.get_logger().warn('Received (possibly incomplete) serial message: ' + encoders.decode("UTF-8"))
        # if we timed out, \n should NOT be included at the end
        if encoders != None and len(encoders) > 0 and encoders[-1] != '\n':
            self.encoder_pub.publish(encoders)

        self.ser.write(self.cmd_string)
        self.get_logger().warn('Sent serial command: ' + self.cmd_string.decode("UTF-8"))


def main(args=None):
    rclpy.init(args=args)
    simple_abot_interface = SimpleAbotInterface()

    rclpy.spin(simple_abot_interface)


if __name__ == "__main__":
    main()