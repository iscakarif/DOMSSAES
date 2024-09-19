In this folder, all the necessary files to control the FPGA board, as well as the oscilloscope, are present. It also contains a Visual Studio project, as it may be useful, but be aware that the paths and versions are most likely going to be incorrect.
This code is provided for Windows machines only. If you want to run it on a Linux machine, please refer to how to interface with VISA on Linux. A lot of the code should remain usable.

For more information, please contact me at mael.gay@informatik.uni-stuttgart.de. Some important informations on how to build the project are available below.

Important information
	Do not forget to install NI_Visa
	Do not forget to add the paths to the Visual Studio Project:
		Project properties -> C++ -> General -> Additional Include Directories:
			"C:\Program Files (x86)\IVI Foundation\VISA\WinNT\Include"
		Project properties -> Linker -> General -> Additional Library Directories:
			"<source>\FTD2xx"
			"C:\Program Files (x86)\IVI Foundation\VISA\WinNT\lib\msc"
			"C:\Program Files (x86)\IVI Foundation\VISA\WinNT\Lib_x64\msc"
	Do not forget to build in x86