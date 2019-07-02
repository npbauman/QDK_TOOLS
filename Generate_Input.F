      PROGRAM GENERATE_INPUT
      IMPLICIT NONE
      INTEGER, PARAMETER   :: INP=500
      INTEGER, PARAMETER   :: SUB=501
      INTEGER, PARAMETER   :: SUBA=502
      CHARACTER*75         :: DIRECTORY, SUBDIRECTORY
      CHARACTER*500        :: FILENAME
      INTEGER              :: TROTTERITER
      INTEGER              :: QUBITITER
      INTEGER              :: RUNS
      INTEGER              :: BITS
      REAL                 :: TROTTERSTEP
      INTEGER              :: TROTTERORDER
      CHARACTER*2          :: ROOT
      INTEGER              :: I
      CHARACTER*10         :: TIMELENGTH
      CHARACTER*15         :: ACCOUNT
      CHARACTER*200        :: PATH
      INTEGER*4            :: GETCWD, STATUS

      STATUS = GETCWD( PATH )
      IF(STATUS.NE.0) STOP 'GETCWD: ERROR'
      WRITE(*,*) PATH

      WRITE(*,'(
     &" THIS PROGRAM WILL GENERATE ''Program.cs'' FILES FOR"/
     &" TROTTERIZATION AND/OR QUBITIZATION SIMULATIONS. THEY"/
     &" ARE PLACED IN SUBDIRECTORIES IN ONE COMMON DIRECTORY."/
     &" ALL OTHER NECESSARY FILES ARE PUT IN THESE DIRECTORIES"/
     &" ALONG WITH A SUBMISSION SLURM SCRIPTS AND A EXECUTABLE"/
     &" TO COLLECT ALL THE DATA IN A ''.csv'' FILE"/
     &""/
     &" YOU WILL BE PROMPTED FOR LENGTH OF TIME AND CHARGE"/
     &" ACCOUNT FOR THE SLURM SCRIPT, SO HAVE THEM READY."/
     &" YOU CAN ALWAYS MAKE CHANGES TO SEVERAL FILES EASILY WITH:"/
     &"    sed -i ''s/foo/bar/g'' {LIST OF FILES} "/
     &)')

      WRITE(*,*)"ENTER A JOB NAME FOR THE DIRECTORY"
      READ(*,"(A)")DIRECTORY
      CALL SYSTEM("mkdir " // DIRECTORY)

      OPEN(INP,FILE='Program.cs')

      WRITE(*,*)"ENTER YAML FILE NAME (WITH FULL PATH) OR URL:"
      READ(*,"(A)")FILENAME

      WRITE(*,'(
     &""/
     &" NEXT WE SET THE NUMBER TROTTERIZAION AN/OR QUBITIZATION"/
     &" ITERATIONS **PER INDIVIDUAL RUN** AND THE TOTAL NUMBER "/
     &" OF RUNS TO BE EXECUTED."/
     &" -- SETTING EITHER VALUE OF THE FOLLOWING NUMBER OF "/
     &" -- ITERATIONS TO ZERO SKIPS THAT PARTICULAR SAMPLING"/
     &""/
     &)')

      WRITE(*,*)"ENTER THE NUMBER OF TROTTERIZATION ITERATIONS **PER RUN**:"
      READ(*,*)TROTTERITER

      WRITE(*,*)"ENTER THE NUMBER OF QUBITIZATION ITERATIONS **PER RUN**:"
      READ(*,*)QUBITITER

      WRITE(*,*)"ENTER THE NUMBER OF RUNS:"
      READ(*,*)RUNS

      WRITE(*,"(5(I5,A))")RUNS," DIRECTORIES, EACH FOR ",TROTTERITER," TROTTERIZATION ITERATIONS AND ",
     &QUBITITER," QUBITIZATION ITERATIONS,"//NEW_LINE('A')//" WILL BE CREATED FOR A TOTAL OF ",RUNS*TROTTERITER,
     &" TROTTERIZAION SAMPLINGS AND ",RUNS*QUBITITER," QUBITIZATION SAMPLINGS."

      WRITE(*,'(
     &""/
     &" NEXT WE SET THE BITS OF PRECISION. THE LARGER THE VALUE THE"/
     &" SMALLER THE STANDARD DEVIATION. STANDARD DEVIATION GOES AS"/
     &" ~O(1/RUNTIME) AND RUNTIME SCALES AS ~O(2^BITS)."/
     &" -- FROM NICHOLAS BAUMAN: I WOULD NOT RECOMMEND A VALUE LESS THAN 7."/
     &" --                       A VALUE OF 9 OR HIGHER IS USUALLY NEEDED FOR A"/
     &" --                       STANDARD DEVIATION AT THE MILLIHARTREE LEVEL."/
     &""/
     &)')

      WRITE(*,*)"ENTER THE BITS OF PRECISION:"
      READ(*,*)BITS

      WRITE(*,'(
     &""/
     &" NEXT WE SET THE STEP-SIZE OF THE SIMULATED TIME-EVOLUTION AND THE TROTTER"/
     &" INTEGRATOR ORDER. THE TROTTER-SUZUKI INTEGRATOR IMPLMENTED IS BASED OFF"/
     &" http://arxiv.org/abs/quant-ph/0508139 . THE PAPER DESCRIBES HOW THE BOUNDS"/
     &" OF THE ERROR DEPEND ON THE STEP-SIZE AND INTEGRATOR ORDER, ALTHOUGH THESE"/
     &" ARE LOOSE BOUNDS. THE SMALLER THE STEP-SIZE THE SMALLER THE ERROR. UNFORTUNATELY,"/
     &" THE STEP-SIZE FOR A PARTICULAR ACCURACY CAN ONLY BE DETERMINED EMPIRICALLY"/
     &" -- FROM NICHOLAS BAUMAN: STEP-SIZES OF 0.1-0.5 AND THE INTEGRATOR ORDER"/
     &" --                       OF 1 WORK WELL."/
     &""/
     &)')

      WRITE(*,*)"ENTER THE STEP-SIZE:"
      READ(*,*)TROTTERSTEP

      WRITE(*,*)"ENTER THE INTEGRATOR ORDER:"
      READ(*,*)TROTTERORDER

      WRITE(*,*)"WHAT STATE/ROOT ARE YOU INTERESTED IN?"
      WRITE(*,*)"-- TYPE G FOR THE GROUND-STATE (OTHERWISE THE FIRST ROOT IN THE YAML FILE)"
      WRITE(*,*)"-- TYPE 1 FOR THE FIRST EXCITED STATE, 2 FOR THE SECOND, ETC."
      READ(*,"(A)")ROOT

      WRITE(*,'(
     &""/
     &" THE FOLLOWING STEPS ARE TO SET UP THE SLURM FILES"/
     &""/
     &)')

      WRITE(*,*)"ENTER THE TIME LIMIT PER RUN (hh:mm:ss):"
      READ(*,"(A)")TIMELENGTH
      WRITE(*,*)"ENTER THE CHARGE ACCOUNT:"
      READ(*,"(A)")ACCOUNT


      WRITE(INP,"(A)")     "// INFO CARD"
      WRITE(INP,"(A)")     "// *********"
      WRITE(INP,"(A)")     "// FILE NAME         : "//TRIM(FILENAME)
      WRITE(INP,"(A,I5)")  "// TROTTER ITER.     : ",TROTTERITER
      WRITE(INP,"(A,I5)")  "// QUBIT ITER.       : ",QUBITITER
      WRITE(INP,"(A,I5)")  "// NUMBER OF RUNS    : ",RUNS
      WRITE(INP,"(A,I5)")  "// BITS OF PRECISION : ",BITS
      WRITE(INP,"(A,F5.3)")"// STEP SIZE         : ",TROTTERSTEP
      WRITE(INP,"(A,I5)")  "// INTEGRATOR ORDER  : ",TROTTERORDER
      WRITE(INP,"(A)")     "// ROOT              : "//ROOT
      WRITE(INP,"(A)")     "// *********"



      WRITE(INP,'(
     &"// Copyright (c) Microsoft Corporation. All rights reserved."/
     &"// Licensed under the MIT License."/
     &""/
     &"#region Using Statements"/
     &"// We will need several different libraries in this sample."/
     &"// Here, we expose these libraries to our program using the"/
     &"// C# ""using"" statement, similar to the Q# ""open"" statement."/
     &""/
     &"// We will use the data model implemented by the Quantum Development Kit Chemistry"/
     &"// Libraries. This model defines what a fermionic Hamiltonian is, and how to"/
     &"// represent Hamiltonians on disk."/
     &"using Microsoft.Quantum.Chemistry;"/
     &""/
     &"// To count gates, we''ll use the trace simulator provided with"/
     &"// the Quantum Development Kit."/
     &"using Microsoft.Quantum.Simulation.Simulators;"/
     &""/
     &"// The System namespace provides a number of useful built-in"/
     &"// types and methods that we''ll use throughout this sample."/
     &"using System;"/
     &""/
     &"// The System.Diagnostics namespace provides us with the"/
     &"// Stopwatch class, which is quite useful for measuring"/
     &"// how long each gate counting run takes."/
     &"using System.Diagnostics;"/
     &""/
     &"// The System.Collections.Generic library provides many different"/
     &"// utilities for working with collections such as lists and dictionaries."/
     &"using System.Collections.Generic;"/
     &""/
     &"// We use the logging library provided with .NET Core to handle output"/
     &"// in a robust way that makes it easy to turn on and off different messages."/
     &"using Microsoft.Extensions.Logging;"/
     &""/
     &"// We use this for convnience functions for manipulation arrays."/
     &"using System.Linq;"/
     &"#endregion"/
     &""/
     &"namespace Microsoft.Quantum.Chemistry.Generic"/
     &"{"/
     &"    class Program"/
     &"    {"/
     &"        static void Main(string[] args)"/
     &"        {"/
     &"            //////////////////////////////////////////////////////////////////////////"/
     &"            // FILE INPUT LINES //////////////////////////////////////////////////////"/
     &"            //////////////////////////////////////////////////////////////////////////"/
     &""/
     &"            //NOTE :: By default OpenMP uses all available hardware threads, which means "/
     &"            //        that programs with small numbers of qubits will often run slowly "/
     &"            //        because the coordination required will dwarf the actual work."/
     &"            //        Be sure to change OMP_NUM_THREADS!!!!!!"/
     &""/
     &""/
     &"            #region Building the Hamiltonian through orbital integrals"/
     &""/
     &"            // This is the name of the file we want to load"/
     &)')

      IF(INDEX(FILENAME,"http").EQ.0) THEN
        WRITE(INP,"(A)")"            var filename = """//TRIM(FILENAME)//""";"
        WRITE(INP,"(A)")"            Console.WriteLine(""YAML Data File: "" + filename);"
      ELSE
        WRITE(INP,"(A)")"            var filename = """//TRIM(FILENAME)//""";"
        WRITE(INP,'(
     &"                Console.WriteLine(""----- Reading data from url"");"/
     &"                var client = new HttpClient();"/
     &"                var task = client.GetAsync(filename);"/
     &"                var yaml = task.Result.Content.ReadAsStringAsync().Result;"/
     &"                Console.WriteLine(""----- YAML Data"");"/
     &"                Console.WriteLine(yaml);"/
     &""/
     &"                filename = ""myqdk.yaml"";"/
     &"                File.WriteAllText($@""{filename}"", yaml);"/
     &)')
        WRITE(INP,"(A)")"            Console.WriteLine(""YAML Data File: "" + filename);"
      ENDIF

      WRITE(INP,'(
     &""/
     &"            // This constructs the `FermionHamiltonian` from `Broombridge` format."/
     &"            var hamiltonian = FermionHamiltonian.LoadFromYAML($@""{filename}"").Single();"/
     &"            // Note that the `LoadFromYAML` schema returns a list of `FermionHamiltonian`"/
     &"            // instances as the file might describe multiple Hamiltonians. In this example,"/
     &"            //there is only one Hamiltonian. So we use `.Single()`, which selects the first"/
     &"            //element of the list."/
     &""/
     &"            // These orbital integral terms are automatically expanded into"/
     &"            // spin-orbitals. We may print the Hamiltonian to see verify what it contains."/
     &"            Console.WriteLine(""----- Print Hamiltonian"");"/
     &"            Console.Write(hamiltonian);"/
     &"            Console.WriteLine(""----- End Print Hamiltonian \n"");"/
     &""/
     &"            //////////////////////////////////////////////////////////////////////////"/
     &"            // PARAMETERS ////////////////////////////////////////////////////////////"/
     &"            //////////////////////////////////////////////////////////////////////////"/
     &"            // Set the number of iterations for Trotter and Qubitization."/
     &"            // Set either to 0 to skip that calculation."/
     &)')

      WRITE(INP,"(A,I5,A)")"            var trottiter = ",TROTTERITER,";"

      WRITE(INP,"(A,I5,A)")"            var qubititer = ",QUBITITER,";"

      WRITE(INP,'(
     &""/
     &"            // We specify the bits of precision desired in the phase estimation"/
     &"            // algorithm"/
     &)')

      WRITE(INP,"(A,I5,A)")"            var bits = ",BITS,";"

      WRITE(INP,'(
     &""/
     &"            // We specify the step-size of the simulated time-evolution"/
     &"            // and Trotter integrator order"/
     &)')

      WRITE(INP,"(A,F5.3,A)")"            var trotterStep = ",TROTTERSTEP,";"

      WRITE(INP,"(A,I5,A)")"            Int64 trotterOrder = ",TROTTERORDER,";"

      WRITE(INP,'(
     &""/
     &"            #endregion"/
     &""/
     &"            #region Jordan-Wigner representation"/
     &"            // The Jordan-Wigner encoding converts the Fermion Hamiltonian,"/
     &"            // expressed in terms of Fermionic operators, to a qubit Hamiltonian,"/
     &"            // expressed in terms of Pauli matrices. This is an essential step"/
     &"            // for simulating our constructed Hamiltonians on a qubit quantum"/
     &"            // computer."/
     &"            Console.WriteLine(""----- Creating Jordan-Wigner encoding"");"/
     &"            var jordanWignerEncoding = JordanWignerEncoding.Create(hamiltonian);"/
     &"            Console.WriteLine(""----- End Creating Jordan-Wigner encoding \n"");"/
     &"            #endregion"/
     &""/
     &"            #region Performing the simulation "/
     &""/
     &"            // This Jordan-Wigner data structure also contains a representation "/
     &"            // of the Hamiltonian made for consumption by the Q# algorithms."/
     &)')

      IF(INDEX(ROOT,"G").GT.0) THEN
        WRITE(INP,"(A)")"            var qSharpData = jordanWignerEncoding.QSharpData(""|G>"");"
      ELSEIF(INDEX(ROOT,"g").GT.0) THEN
        WRITE(INP,"(A)")"            var qSharpData = jordanWignerEncoding.QSharpData(""|G>"");"
      ELSE
        WRITE(INP,"(A)")"            var qSharpData = jordanWignerEncoding.QSharpData(""|E"//TRIM(ROOT)//">"");"
      ENDIF

      WRITE(INP,'(
     &""/
     &"            // Here, we make an instance of the simulator used to run our Q# code."/
     &"            using (var qsim = new QuantumSimulator())"/
     &"            {"/
     &"                if (trottiter > 0 )"/
     &"                {"/
     &"                    Console.WriteLine(""----- Performing quantum energy estimation by Trotter simulation algorithm"");"/
     &"                    Console.WriteLine("""");"/
     &"                    for (int i = 0; i < trottiter; i++)"/
     &"                    {"/
     &"                        var (phaseEst, energyEst) = GetEnergyByTrotterization.Run(qsim, qSharpData, bits, trotterStep, trotterOrder).Result;"/
     &""/
     &"                        Console.WriteLine($""Rep #{i+1}/{trottiter}: Trotterization Energy estimate: {energyEst}; Phase estimate: {phaseEst}"");"/
     &"                    }"/
     &"                    Console.WriteLine(""----- End Performing quantum energy estimation by Trotter simulation algorithm\n"");"/
     &"                }"/
     &"                if (qubititer > 0)"/
     &"                {"/
     &"                    Console.WriteLine(""----- Performing quantum energy estimation by Qubitization simulation algorithm"");"/
     &"                    Console.WriteLine("""");"/
     &"                    for (int i = 0; i < qubititer; i++)"/
     &"                    {"/
     &"                        var (phaseEst, energyEst) = GetEnergyByQubitization.Run(qsim, qSharpData, bits).Result;"/
     &""/
     &"                        Console.WriteLine($""Rep #{i+1}/{qubititer}: Qubitization Energy estimate: {energyEst}; Phase estimate: {phaseEst}"");"/
     &"                    }"/
     &"                    Console.WriteLine(""----- End Performing quantum energy estimation by Qubitization simulation algorithm\n"");"/
     &"                }"/
     &"            }"/
     &""/
     &"            Console.WriteLine(""Calculation Complete"");"/
     &"            if (System.Diagnostics.Debugger.IsAttached)"/
     &"            {"/
     &"                Console.ReadLine();"/
     &"            }"/
     &"            #endregion"/
     &"        }"/
     &"    }"/
     &"}"/
     &)')

      CALL SYSTEM("mv Program.cs " // DIRECTORY)

      DO I = 1, RUNS
        WRITE(SUBDIRECTORY,"(A,I4.4)")TRIM(DIRECTORY)//'/',I
        CALL SYSTEM("mkdir " // SUBDIRECTORY)
        CALL SYSTEM("cp " // TRIM(DIRECTORY)//'/Program.cs ' // SUBDIRECTORY)
        CALL SYSTEM("cp Driver.qs " // SUBDIRECTORY)
        CALL SYSTEM("cp Driver.csproj " // SUBDIRECTORY)
      ENDDO

      DO I = 1, RUNS
      OPEN(SUB,FILE='run.sbatch')
      WRITE(SUBDIRECTORY,"(A,I4.4)")TRIM(DIRECTORY)//'/',I
      WRITE(SUB,'(
     &"#!/bin/csh -f"/
     &"#SBATCH -N 1"/
     &"#SBATCH --ntasks-per-node 1"
     &)')
      WRITE(SUB,"(A)")"#SBATCH -t "//TIMELENGTH
      WRITE(SUB,"(A)")"#SBATCH -A "//ACCOUNT
      WRITE(SUB,'(
     &"#SBATCH -o out.%j"/
     &"#SBATCH -e err.%j"/
     &"#SBATCH --export ALL"/
     &""/
     &"setenv OMP_NUM_THREADS 1"/
     &)')
      WRITE(SUB,"(A)")"cd "//TRIM(PATH)//"/"//SUBDIRECTORY
      WRITE(SUB,"(A)")"singularity run "//TRIM(PATH)//"/"//"qdk.sif"
      WRITE(SUB,'(
     &""/
     &"exit 0"
     &)')
      CLOSE(SUB)
      CALL SYSTEM("mv run.sbatch " // TRIM(PATH) // "/" // SUBDIRECTORY)
      ENDDO

      OPEN(SUBA,FILE='SUBMIT-ALL')
      DO I = 1, RUNS
        WRITE(SUBDIRECTORY,"(A,I4.4)")TRIM(DIRECTORY)//'/',I
        WRITE(SUBA,"(A)")"cd " // TRIM(PATH) // "/" // SUBDIRECTORY
        WRITE(SUBA,"(A)")"sbatch run.sbatch"
      ENDDO

      CALL SYSTEM("chmod u+x SUBMIT-ALL")
      CALL SYSTEM("mv SUBMIT-ALL " // DIRECTORY)

      CALL SYSTEM("cp Grab_Data " // DIRECTORY)

      END
