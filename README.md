# Thrust Stand

A motor thrust measurement system built around the STM32F446RE (NUCLEO-F446RE) that measures thrust, current draw, and battery voltage in real time, streaming data to MATLAB for analysis and plotting.

## Overview

This project characterizes the performance of brushless DC motors by measuring:

- **Thrust (g)** — via a 20kg cantilever beam load cell and HX711 24-bit ADC
- **Current (A)** — via an ACS758 50A hall-effect current sensor
- **Voltage (V)** — via a resistor voltage divider scaled to the STM32 ADC input range

Throttle is controlled by a time-based PWM sweep generated directly by the STM32, ramping from 1000µs to 1800µs over 15 seconds. Data streams over UART at 115200 baud as CSV, logged and plotted in MATLAB.

## Hardware

| Component       | Details                                        |
| --------------- | ---------------------------------------------- |
| Microcontroller | STM32F446RE (NUCLEO-F446RE)                    |
| Load cell       | 20kg cantilever beam, full bridge              |
| Load cell ADC   | HX711 24-bit module                            |
| Current sensor  | ACS758LCB-050B (HW-525 module), 50A            |
| Voltage sensing | 10kΩ / 3kΩ resistor divider                    |
| Motor           | A2212 1000KV brushless outrunner               |
| ESC             | 40A brushless ESC                              |
| Battery         | 3S LiPo 11.1V 5200mAh                         |
| Frame           | 2020 aluminum extrusion with 3D printed mounts |

## Pin Mapping

| Signal            | STM32 Pin | Arduino Header           |
| ----------------- | --------- | ------------------------ |
| HX711 DT (data)   | PA0       | A0                       |
| HX711 SCK (clock) | PA1       | A1                       |
| Voltage divider   | PC1       | A4                       |
| ACS758 VIOUT      | PC0       | A5                       |
| PWM output        | PB10      | D6                       |
| UART TX to PC     | PA2       | USART2 (onboard ST-Link) |

## Voltage Divider

Scales 3S LiPo voltage (max 12.6V) down to safe ADC input range (max 3.3V):

```
LiPo (+) → 10kΩ → node → 3kΩ (1kΩ + 2kΩ) → GND
                     ↓
                    PC1 (A4)
```

Firmware reverse formula:

```c
voltage = pin_voltage * (13000.0f / 3000.0f);
```

## Load Cell Calibration

Calibrated using known weights with a scale factor of **104.26 counts/gram**.

Tare is performed automatically on startup — ensure no load is applied to the motor mount when powering on.

## Data Format

CSV streamed over UART at 115200 baud:

```
time_ms,thrust_g,voltage_v,current_a
1024,0.0,11.51,0.00
1127,245.3,11.48,4.23
```

## Throttle Sweep

The STM32 generates a time-based PWM sweep automatically after startup:

- 0 to 15s: linear ramp from 1000µs to 1800µs
- 15 to 17s: hold at 1800µs
- 17 to 32s: linear ramp back down to 1000µs
- Motor off after 32s

Note: this ESC's effective PWM range is 1000 to 1800µs. Signals above 1800µs trigger ESC protection cutoff.

## Build Instructions

1. Open project in **STM32CubeIDE 2.1.1+**
2. Build in **Debug** configuration
3. Flash via onboard ST-Link (USB)
4. Run MATLAB script before resetting the Nucleo
5. Press reset on the Nucleo when prompted — sweep starts automatically after arming delay

## MATLAB Integration

MATLAB script reads the serial stream and plots:

- Thrust curve vs time
- Current draw vs time
- Battery voltage sag vs time
- Specific thrust (g/W) vs time

## Results

- Peak thrust: 1391g at 1800µs
- Peak current: 20A (sensor readable limit)
- Voltage sag: 12.0V idle to 11.3V under full load
- Scale factor: 104.26 counts/gram
- PWM range: 1000 to 1800µs

## Project Status

- [x] Hardware assembly
- [x] Load cell calibration
- [x] Voltage monitoring
- [x] Current sensing
- [x] UART data streaming
- [x] Current noise filtering
- [x] MATLAB plotting script
- [x] Automated PWM throttle sweep
- [x] Full throttle sweep dataset
- [ ] PCB design

## Author

Victory — Aerospace Engineering, UT Arlington
