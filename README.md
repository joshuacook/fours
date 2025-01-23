# Project Overview

## Data Model

- `song`: A collection of beats.
    - `title`: Stores the name of each song.
    - `tempo`: Adjustable using a dial and savable with the song.
    - `beat`: A single array representing a 16-beat sequence where each value (0, 1, 2) corresponds to different playback volumes and Grid lighting:
      - `0`: No playback.
      - `1`: Half volume.
    - `2`: Full volume.
- `global`: Global settings
    - `drum_sample_path`: Path to the directory containing the drum samples.
    - `drum_1`: Path to the first drum sample.
    - `drum_2`: Path to the second drum sample.
    - `drum_3`: Path to the third drum sample.
    - `drum_4`: Path to the fourth drum sample.

## Software Components

### User Interface
- **Dials, Buttons, and Grid**: For setting tempo, triggering samples, and programming beats.
- **Screen Display**: For updating and showing current system status.

### Data Management
- **I/O Operations**: To load and save song data and samples to disk using XML.

### Audio Engine
- **Softcut**: Utilized for drum sample playback using two voices:
  - Voice 1: Handles samples for drums in bottom two Grid rows
  - Voice 2: Handles samples for drums in Grid rows 3 and 4 (from bottom)


## Hardware Components

- **Norns**: The main platform for running the software, handling audio processing, and interfacing with the Grid.
- **Grid**: A tactile interface for programming beats and controlling playback.

Feel free to adjust or expand as needed!```
