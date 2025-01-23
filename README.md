# Project Overview

## Data Model

- **Song Title**: Stores the name of each song.
- **Tempo**: Adjustable using a dial and savable with the song.
- **Beat Pattern**: A single array representing a 16-beat sequence where each value (0, 1, 2) corresponds to different playback volumes and Grid lighting:
  - `0`: No playback.
  - `1`: Half volume.
  - `2`: Full volume.
- **Samples**: Paths to individual audio samples for each drum sound.

## Software Components

### User Interface
- **Dials, Buttons, and Grid**: For setting tempo, triggering samples, and programming beats.
- **Screen Display**: For updating and showing current system status.

### Data Management
- **I/O Operations**: To load and save song data and samples to disk using XML.

### Audio Engine
- **Softcut**: Utilized for playback and recording of loops, supporting up to six voices.

### Control Logic
- **MIDI Support**: For sending MIDI notes to an external device to offload drum sample playback.

## Hardware Components

- **Norns**: The main platform for running the software, handling audio processing, and interfacing with the Grid and MIDI devices.
- **Grid**: A tactile interface for programming beats and controlling playback.
- **MIDI Hub**: To connect the Norns to the MIDI device for sending note data.
- **MIDI Device**: Used for offloading drum sample playback.

Feel free to adjust or expand as needed!```
