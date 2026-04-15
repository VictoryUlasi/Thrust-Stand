# Thrust Stand

A motor thrust measurement system built around the STM32F446RE (NUCLEO-F446RE) that measures thrust, current draw, and battery voltage in real time, streaming data to MATLAB for analysis and plotting.

## Overview

This project characterizes the performance of brushless DC motors by measuring:

- **Thrust (g)** — via a 10kg cantilever beam load cell and HX711 24-bit ADC
- **Current (A)** — via an ACS758 50A hall-effect current sensor
- **Voltage (V)** — via a resistor voltage divider scaled to the STM32 ADC input range

Data streams over UART at 115200 baud as CSV, logged and plotted in MATLAB.

## Hardware

| Component       | Details                                        |
| --------------- | ---------------------------------------------- |
| Microcontroller | STM32F446RE (NUCLEO-F446RE)                    |
| Load cell       | 10kg cantilever beam, full bridge              |
| Load cell ADC   | HX711 24-bit module                            |
| Current sensor  | ACS758LCB-050B (HW-525 module), 50A            |
| Voltage sensing | 10kΩ / 3kΩ resistor divider                    |
| Motor           | A2212 1000KV brushless outrunner               |
| ESC             | 30A brushless ESC                              |
| Battery         | 3S LiPo 11.1V 5200mAh                          |
| Frame           | 2020 aluminum extrusion with 3D printed mounts |

## Pin Mapping

| Signal            | STM32 Pin | Arduino Header           |
| ----------------- | --------- | ------------------------ |
| HX711 DT (data)   | PA0       | A0                       |
| HX711 SCK (clock) | PA1       | A1                       |
| Voltage divider   | PC1       | A4                       |
| ACS758 VIOUT      | PC0       | A5                       |
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

Calibrated using known weights with a scale factor of **200.9 counts/gram**.

Tare is performed automatically on startup — ensure no load is applied to the motor mount when powering on.

## Data Format

CSV streamed over UART at 115200 baud:

```
time_ms,thrust_g,voltage_v,current_a
1024,0.0,11.51,0.00
1127,245.3,11.48,4.23
```

## Build Instructions

1. Open project in **STM32CubeIDE 2.1.1+**
2. Build in **Debug** configuration
3. Flash via onboard ST-Link (USB)
4. Open PuTTY or MATLAB serial port at **COM# / 115200 baud**

## MATLAB Integration

MATLAB script (coming soon) reads the serial stream and plots:

- Thrust curve vs time
- Current draw vs time
- Battery voltage sag vs time
- Motor efficiency (g/W)

## Project Status

- [x] Hardware assembly
- [x] Load cell calibration
- [x] Voltage monitoring
- [x] Current sensing
- [x] UART data streaming
- [ ] Current noise filtering
- [ ] MATLAB plotting script
- [ ] Full throttle sweep dataset
- [ ] PCB design

## Author

Victory — Aerospace Engineering, UT Arlington
