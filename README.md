# QDK_TOOLS
This package of routines is for generating several inputs
and the necessary SLURM submission scripts to run several 
trotterization and/or qubiization calculations at the same 
time. This package also contains a singularity file for the 
.NET execution so one does not have to install .NET themselves.

You will need to have a way to obtain a '.yaml' file, either through
a build of NWChem or a URL.

INSTALL
*******
You will need t download the singularity:

	wget https://www.dropbox.com/s/rp8w7xzaku2ysf0/qdk.sif

You will need to compile one file:

	gfortran -ffixed-line-length-none Generate_Input.F -o Generate_Input

To make sure you have all of the QDK files to run execute the following commands:

	singularity shell qdk.sif
	dotnet new -i Microsoft.Quantum.ProjectTemplates
	exit


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
