# ISIS Installation Notes

## Introduction

### Purpose
The purpose of this document is to provide a brief overview of the software, ISIS, and the procedure for installing ISIS on a Linux and a Mac OSx system.

### Overview of ISIS
“The Integrated System for Imagers and Spectrometers (ISIS) is a free, specialized, digital image processing software package developed by the USGS for NASA. ISIS key feature is the ability to place many types of data in the correct cartographic location, enabling disparate data to be co-analyzed. ISIS also includes standard image processing applications such as contrast, stretch, image algebra, filters, and statistical analysis. ISIS can process two-dimensional images as well as three-dimensional cubes derived from imaging spectrometers. The production of USGS topographic maps of extraterrestrial landing sites relies on ISIS software. ISIS is able to process data from NASA and International spacecraft missions including Lunar Orbiter, Apollo, Voyager, Mariner 10, Viking, Galileo, Magellan, Clementine, Mars Global Surveyor, Cassini, Mars Odyssey, Mars Reconnaissance Orbiter, MESSENGER, Lunar Reconnaissance Orbiter, Chandrayaan, Dawn, Kaguya, and New Horizons.”
See [https://isis.astrogeology.usgs.gov/documents/Overview/Overview.html](https://isis.astrogeology.usgs.gov/documents/Overview/Overview.html)	

## Installing ISIS 3 on Red Hat Linux Systems
*Disclaimer:* Installation scripts exist, however I found it easiest to manually install ISIS using rsync, so that procedure to outlined below.

Make working directory:
   
    >> cd /working_directory
    >> mkdir isis3
    >> cd isis3

Download the ISIS binaries for Red Hat:

    >> rsync -azv –-delete –-partial isisdist.astrogeology.usgs.gov::x86-64_linux_RHEL6/isis .

*Note:* If ‘rsync’ fails, add alternative port number to the ‘rsync’ command.

Download base ISIS3 data:

    >> rsync -azv –-delete –-partial isisdist.astrogeology.usgs.gov::isis3data/data/base data/

*Note:* This is for partial data download. If you don’t include “/base”, all mission data will be included (>130 GB of disk space!).

Download ISIS SPICE data for the mission(s) you’re interested in (e.g. Galileo):

    >> rsync -azv --delete –partial isisdist.astrogeology.usgs.gov::isis3data/data/galileo data/

UNIX environment set up (for Bourne shells):

    >> ISISROOT = /working_directory/isis3/isis
    >> export ISISROOT

I have added the ISISROOT environment variable to my .bashrc file so this step doesn’t need to be done each time.

Run start up script:

    >> . $ISISROOT/scripts/isis3Startup.sh

## Installing ISIS 3 on Mac OSx (version 10.4 or greater)
In January 2017, USGS released a Mac OSx 10.11 and 10.12 compatible version of ISIS. I was able to successfully download it on my macOS Sierra 10.12.2 using the installation script found in the [ISIS install guide](https://isis.astrogeology.usgs.gov/documents/InstallGuide/). 

## Notes on Getting Started
Download Galileo SSI data (.lbl + .img) from PDS: [http://pds-imaging.jpl.nasa.gov/search/](http://pds-imaging.jpl.nasa.gov/search/)

Run start up script:

    >> . $ISISROOT/scripts/isis3Startup.sh

Import Galileo data into ISIS “cubes”:
    
    >> gllssi2isis FROM=8178r.lbl TO=myCube.cub

View ISIS image cubes:
    
    >> qview

The ISIS “cube” has the following three dimensions: samples, lines, and bands. Sample 1, Line 1 is the top left pixel. 

Each pixel contains a numerical value: “DN”: digital number, which represents real world values. A low DN is usually dark and a high DN is usually light.
-	For 8-bit and 16-bit cubes, DN = Base + (stored value * multiplier). For 8-bit, DN = 0 to 255. This conversion is not needed for 32-bit cubes.

## References
[ISIS Installation Guide](https://isis.astrogeology.usgs.gov/documents/InstallGuide/index.html)

[ISIS Manual Installation using rsync] (https://isis.astrogeology.usgs.gov/documents/InstallGuide/index.html#rsyncInstallation)