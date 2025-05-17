# SVD
Sar Vertical Destriper

An utility/tool to remove vertical bands from SAR tomography images, coming from Filippo Biondi site or papers [(https://www.harmonicsar.com/)](https://www.harmonicsar.com/).   
The images can be captured directly with the windows "Capture Tool" and saved as .png
The ispiration was coming from a very antique tool I created long time ago for eliminating similar artifacts from raw, uncalibrated,  CDD satellite imagery from Mars Global Surveyor (MGS).
Supposed the mean of the luminosity of the vertical, adjacient, strips is similar the tool normalizes the luminosity of each vertical line, using the mean luminosity from the adjacient N lines.
Thanks to chat GPS the v 1.0 is publicly available.


Prerequisites:
 -Python and packages listed in the first lines of the script
 -Image to enhance
 -colorbar
 
Usage examples:

 
 # Image directly converted in B/W, then elaborated 
 python3 sar5.py --bw_input SanGottardo.png --colorbar colorbar.png --output SanGottardo --N 10

 # Image levels mapped on colorbar.png 
 python3 sar5.py --input GranSasso.png --colorbar colorbar.png --output GranSasso --N 10

NOTE: for images captured directly from Biondi/Malanga paper another image, the 'colorbar' is required.
This is used for the normalization of colours in levels (0-1 / BW) used internally to elaborate the image.  

GALLERY:


Another, better, version maybe will be coming in the future.

 TESTED ON WSL / UBUNTU 
