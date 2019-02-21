# QDK_TOOLS
This package of routines is for generating several inputs
and the necessary SLURM submission scripts to run several 
trotterization and/or qubiization calculations at the same 
time. This package also contains a singularity file for the 
.NET execution so one does not have to install .NET themselves.

You will need to have a way to obtain a '.yaml' file, either through
a build of NWChem or a URL.

If there is ever a problem contact Nicholas Bauman (nicholas.bauman@pnnl.gov).

INSTALL
*******
You will need to download the singularity:

	wget https://www.dropbox.com/s/rp8w7xzaku2ysf0/qdk.sif

This may need to be downloaded on your local machine and 
transferred to the desired machine. Make sure this is placed
in the 'QDK_TOOLS' directory.

Next you will need to compile one file:

	gfortran -ffixed-line-length-none Generate_Input.F -o Generate_Input

To make sure you have all of the QDK files to run execute the following commands:

	singularity shell qdk.sif
	dotnet restore
	exit

	singularity shell qdk.sif
	dotnet new -i Microsoft.Quantum.ProjectTemplates
	exit

TESTING
*******
To see if the singularity is working change directories into the 
'Teleportation' subdirectory. Execute the folowing command:

	singularity run ../qdk.sif

All of the teleportations should be successful.


SUBMITTING
**********
To set up a job, type:

	./Generate_Input

This will promt you for the input file, parameters for the calculation
and information for the SLURM script(s). It will generate a directory
for your job with several subdirectories for the individual runs. There
will be an executable "SUBMIT-ALL" that will submit the '.sbatch' files
in all of the subdirectories.


GRABBING DATA
*************
In each directory there is a file "Grab_Data". Executing this will grab
the energy estimates from each of the outputs.
*** This will execute at the current state of all of the calculations!!!
*** So if all of the calculations are not complete it will not grab all of the data!!!
