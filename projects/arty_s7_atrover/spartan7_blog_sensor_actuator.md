****

# 🚎 Arty-S7-Rover (sensor+actuator)

### Disclaimer

> ==**Build a project** with the Arty S7==, [7 Ways to Leave Your Spartan-6 FPGA](https://community.element14.com/technologies/fpga-group/w/documents/27537/7-ways-to-leave-your-spartan-6-fpga) [<img src="https://community.element14.com/e14/cfs/e14core/images/logos/e14_Profile_206px.png" alt="element14 Community" style="height:2em;" />](https://community.element14.com/) challenge.

The Arty-S7-Rover is a small functional autonomous vehicle based on the [Digilent Arty S7-50 board](https://digilent.com/reference/programmable-logic/arty-s7/start). The project was done for the [7 Ways to Leave Your Spartan-6 FPGA](https://community.element14.com/technologies/fpga-group/w/documents/27537/7-ways-to-leave-your-spartan-6-fpga) [<img src="https://community.element14.com/e14/cfs/e14core/images/logos/e14_Profile_206px.png" alt="element14 Community" style="height:2em;" />](https://community.element14.com/) challenge.

All the files are open-source, MIT license and can be downloaded from [<img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png" alt="GitHub Logo" style="height:1em;" />-<img src="https://avatars.githubusercontent.com/u/34524370?v=4" alt="img" style="height:1em;" />dramoz](https://github.com/dramoz/arty-s7)

### Sensor + Actuator

In this second part, a range ultrasound sensor and a 2xDC motor driver would be implemented.

If you have note read it yet, please check the first blog [🚎 Arty-S7-Rover (base architecture)](spartan7_blog_project.md) as this section relay on that.

## The Hardware

### <img src="https://www.makerfabs.com/image/cache/makerfabs/HC-SR04%20Ultrasonic%20Range%20Measurement%20Module/HC-SR04%20Ultrasonic%20Range%20Measurement%20Module_2-1000x750.jpg" alt="img" style="height:2em;" /> Ultrasonic HC-SR04 distance sensor

|                            &nbsp;                            | &nbsp;                                                       |
| :----------------------------------------------------------: | :----------------------------------------------------------- |
| <img src="https://hackster.imgix.net/uploads/attachments/991537/uploads2ftmp2f95250d93-b617-40b9-956c-3294973543a02fultrasonic428229_UYEDpDPTPU.png?auto=compress%2Cformat&w=680&h=510&fit=max" alt="Ultrasonic Sensor HC-SR04 Configuration and Specification" style="height:20em;" /><br /><img src="https://hackster.imgix.net/uploads/attachments/991535/uploads2ftmp2f32fa411f-a038-48d7-88ce-7de713550efd2fultrasonic3_oEttj9k6S3.png?auto=compress%2Cformat&w=680&h=510&fit=max" alt="Ultrasonic Sensor HC-SR04 Principle" style="height:20em;" /> | **Features**<br />- Ranging distance: 2cm to 4m<br />- Ranging accuracy: 3mm<br />- Operating Voltage: 5V<br />- Current: 15 mA<br />- Frequency: 40 Hz<br />- Measuring angle: 30 degrees<br />- Effectual angle: 15 degrees<br /> |

####  References

- [Ultrasonic Sensor HC-SR04 with Arduino Tutorial](https://create.arduino.cc/projecthub/abdularbi17/ultrasonic-sensor-hc-sr04-with-arduino-tutorial-327ff6)
- [HC-SR04 Ultrasonic Range Sensor on the Raspberry Pi](https://thepihut.com/blogs/raspberry-pi-tutorials/hc-sr04-ultrasonic-range-sensor-on-the-raspberry-pi)

### DC Motor Driver

The Arty-S7-ROVER has two 12V/40W DC motors. The [ZK-5AD](https://www.aliexpress.com/item/1005002100401855.html) with two [TA6586](https://www.micros.com.pl/mediaserver/UITA6586_0001.pdf) monolithic IC can drive both motors with a full H-bridge for bi-directional control.

- Working Voltage: DC 3.0V-14V
- Input Signal Voltage: DC 2.2V-6.0V
- Drive Current: 5A
- Standby Current: 10uA
- Working Temperature:-20 to 85 Celsius

As with any H-Bridge, it can be controlled with two PMW per motor to move forward or backward.

| DC Motor 1 |  D0  |  D1  |  D2  |  D3  |
| ---------- | :--: | :--: | :--: | :--: |
| Forward    | PMW  |  0   |      |      |
| Reverse    |  0   | PWM  |      |      |
| Stop       |  0   |  0   |      |      |
| Break      |  1   |  1   |      |      |

| DC Motor 2 |  D0  |  D1  |  D2  |  D3  |
| ---------- | :--: | :--: | :--: | :--: |
| Forward    |      |      | PWM  |  0   |
| Reverse    |      |      |  0   | PWM  |
| Stop       |      |      |  0   |  0   |
| Break      |      |      |  1   |  1   |

<p align = "center">
  <img src="assets/dc_motor_driver.jpg" style="zoom:100%;" title="ZK-5AD DC Motor Driver" />
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/H_bridge_operating.svg/620px-H_bridge_operating.svg.png" style="zoom:100%;" title="H-Bridge Operation" />
</p>
<p align = "center">
<i>ZK-5AD DC Motor Driver</i>
</p>

#### DC Motors

For the Arty-S7-ROVER I am using two [CHIHAI GM37-550 DC motor ](https://www.aliexpress.com/item/4000808942638.html?pdp_ext_f={"sku_id":"10000008104483462","ship_from":""}&gps-id=pcStoreJustForYou&scm=1007.23125.137358.0&scm_id=1007.23125.137358.0&scm-url=1007.23125.137358.0&pvid=49f50fc1-c29b-4a45-91ae-5cb7468be7b7&spm=a2g0o.store_pc_home.smartJustForYou_718209649.0)with a gear ratio of 50:1 and 12Vdc with a maximum input power of 40W.

> ⚠These motors are kind of powerful. I am using them as that is the chassis and hardware I already have from a previous project.

<p align = "center">
  <img src="https://ae01.alicdn.com/kf/H3e242e43a0a44acfabd93f7a09ffe272c.jpg" alt="img" style="height:20em;" style="zoom:100%;" title="CHIHAI GM37-550 DC motor " />
</p>
<p align = "center">
<i>CHIHAI GM37-550 DC motor</i>
</p>

## The RTL

The DC motors are controlled by four independent PWM blocks. All have the same PWM frequency of 500 Hz[^1].

[^1]: Finding the right PWM frequency and duty cycle was an interesting experiment, for more details check my post [🚎 Arty-S7-Rover (experiments)](spartan7_blog_experiments.md)

