This repository is a home assistant addon that runs the OpenSprinkler firmware as a docker container. This allows using Home Assistant OS with the OpenSprinkler Firmware on the same Raspberry Pi.

Normally, home assistant OS does not allow direct installation of applications on the OS to prevent instability and data loss. The addon works around this by installing the firmware inside a docker container. 

One of the side benefits of this is that Home Assistant will automatically back up the firmware settings for you!

[OpenSprinkler Firmware Docs](https://openthings.freshdesk.com/support/solutions/articles/5000631599-installing-and-updating-the-unified-firmware)

## GPIO Pins (Sprinkler Control)

The add on supports downloading the current OpenSprinkler Pi firmware from [GitHub](https://github.com/OpenSprinkler/OpenSprinkler-Firmware).

The GPIO support is tested and validated with a real sprinkler system with a raspberry pi 5.

> [!CAUTION]
> Note that for the Raspberry Pi 5 to work, I had to use a USB-C power source in addition to the 24v AC transformer.

The OpenSprinkler Pi firmware relies on access to the Raspberry Pi's GPIO pins to control the sprinkler valves. Home Assistant OS runs as a host operating system on the Pi, and by default, it does not expose these pins to containerized applications for security reasons. The firmware uses the `liblgpio` library to interface with the GPIO pins, which requires access to specific device files.

To enable the OpenSprinkler Pi to control the sprinkler valves, you must configure the add-on to request access to the GPIO devices. This is done by specifying the required devices in the add-on configuration in Home Assistant. The firmware uses the following devices:

* `/dev/gpiomem`: Required for basic GPIO access.
* `/dev/gpiochip0`, `/dev/gpiochip1`, etc.: Required for the `liblgpio` library to access the GPIO chips.

## LCD Screen Support

> Note: this functionality is currently untested as I was too lazy to change the config.txt file on my Pi.

The OpenSprinkler LCD relies on the I2C bus (/dev/i2c-1). Home Assistant OS completely disables the Raspberry Pi I2C interface by default for security. Since it's turned off at the host operating system level, the Add-on has no way to access the screen.

The Fix: You have to enable I2C on your Home Assistant Raspberry Pi. Since you are using Home Assistant OS, you have to do this manually on the host:

* Turn off your Raspberry Pi and remove the SD Card / SSD.
* Plug it into your computer.
* Open the drive named hassos-boot.
* Open the config.txt file located in the root of that drive.
* Add the following two lines to the very bottom of the file:

```text
dtparam=i2c_arm=on
dtparam=i2c_vc=on
```

* Save the file.
* Next, inside the hassos-boot drive, create a new folder named CONFIG (all caps).
* Inside CONFIG, create a folder named modules.
* Inside modules, create a text file named rpi-i2c.conf.
* Open rpi-i2c.conf and paste this exact word inside: i2c-dev. Save it.
* Plug the drive back into the Raspberry Pi and boot it up.

Once Home Assistant boots back up, I2C will be permanently enabled on the Pi. Your OpenSprinkler Add-on will automatically detect it and your LCD screen will instantly light up!

## Backups

> Note: I have not validated the backups yet.

Home Assistant handles the backups of OpenSprinkler automatically. 

In Home Assistant Add-ons, any file stored inside the container's `/data` directory is permanently saved to the host drive and is automatically included whenever Home Assistant runs a backup. 

The add-on's `run.sh` script automatically redirects OpenSprinkler's critical files (`progs.dat`, `stns.dat`, `nvm.dat`, `log.json`, etc.) directly into the Home Assistant `/data` folder. 

Whenever you create a Backup in Home Assistant (either a Full Backup, or a Partial Backup that includes your OpenSprinkler Add-on):
1. Home Assistant will zip up the entire `/data` folder.
2. All of your OpenSprinkler settings, schedules, and history are safely stored inside that backup.

If your system crashes and you restore from a Home Assistant backup, Home Assistant will automatically reinstall the Docker container, drop your data files exactly back where they were, and OpenSprinkler will boot up with all your schedules exactly as you left them!