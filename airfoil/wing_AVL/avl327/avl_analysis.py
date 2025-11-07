# codice per l'analisi dell'ala in pianta su AVL:

import os
import subprocess
# import time
import sys
import math

preInput_name="preInput.avl"

################# Parte uno del Preinput #############################
Case_title="FrullaPlano"
Simm=[0, 0, 0.0] #sono iYsym, iZsym e Zsym
center_gravity=[0.0,0.0,0.0] #Sistema di riferimento Xref Yref Zref nel centro di massa
# CDp=0
Mach=0.75 #Mach 
S=78.1  #Superficie [m^2]
c_aer=3.03  #Corda di riferimento per calcolo mom [m]
b_ref=29.46 #span di riferimento [m] TUTTA L'APERTURA ALAERE 
##################### Parte due del preinput ##################################
N_chor=10 #numero di vortici sulla direzione della corda
Cspace= 1.0 #come vengono spaziati i vortici lungo la corda
N_span=20 #numero di vortici lungo lo span
Sspace=-2.0 #spaziatura dei vortici lungo lo span
AoA=0.0
Translate=[0.0,0.0,0.0]
#Informazioni del profilo
C_LE_sect1=[0.0,0.0,0.0]#Xle, Yle, Zle
c_sect_1=5.6126
AoA_root=0.0
profile_name="sc20610.dat"
polare_CL=[-0.0348,0.27,0.3594]
polare_CD=[0.00654,0.000511,0.00519]
t_c=0.1
CLaf= 1+0.77*t_c
##########SECONDA SEZIONE DELL'ALA##############################
Sweep_1=29.76
c_sect_2=2.768
span_1=4.96 #span della prima porzione
x_sect_2=span_1*math.tan(math.radians(Sweep_1))
C_LE_sect2=[x_sect_2,span_1,0.0]
Sweep_2=26.4
span_2=14.73 #span della seconda porzione
x_sect_3=span_2*math.tan(math.radians(Sweep_2))
c_sect_3=0.971
C_LE_sect3=[x_sect_3,span_2,0.0]

def creazione_preinput(preInput_nome):
    with open(preInput_nome, 'w') as preInput:
        preInput.write(f"{Case_title}\n")
        preInput.write(f"{Mach}\n")
        preInput.write(f"{Simm[0]} {Simm[1]} {Simm[2]}\n")
        preInput.write(f"{S} {c_aer} {b_ref}\n")
        preInput.write(f"{center_gravity[0]} {center_gravity[1]} {center_gravity[2]}\n")
        # preInput.write(f"{CDp}\n")
        preInput.write("SURFACE\n")
        preInput.write("Wing\n") #Wing è solo il nome dell'ala
        preInput.write(f"{N_chor} {Cspace} {N_span} {Sspace}\n")
        preInput.write("YDUPLICATE\n")
        preInput.write("0.0\n") #Yduplicate se vogliamo duplicare la geometria
        preInput.write("ANGLE\n")
        preInput.write(f"{AoA}\n")
        preInput.write("TRANSLATE\n")
        preInput.write(f"{Translate[0]} {Translate[1]} {Translate[2]}\n")
        #Prima section
        preInput.write("SECTION\n")
        preInput.write(f"{C_LE_sect1[0]} {C_LE_sect1[1]} {C_LE_sect1[2]} {c_sect_1} {AoA_root} 0 0\n")
        preInput.write("AFILE\n")
        preInput.write(f"{profile_name}\n")
        preInput.write("CDCL\n")
        preInput.write(f"{polare_CL[0]} {polare_CD[0]} {polare_CL[1]} {polare_CD[1]} {polare_CL[2]} {polare_CD[2]}\n")
        preInput.write("CLAF\n")
        preInput.write(f"{CLaf}\n")
        #Seconda section
        preInput.write("SECTION\n")
        preInput.write(f"{C_LE_sect2[0]} {C_LE_sect2[1]} {C_LE_sect2[2]} {c_sect_2} {AoA_root} 0 0\n")
        preInput.write("AFILE\n")
        preInput.write(f"{profile_name}\n")
        preInput.write("CDCL\n")
        preInput.write(f"{polare_CL[0]} {polare_CD[0]} {polare_CL[1]} {polare_CD[1]} {polare_CL[2]} {polare_CD[2]}\n")
        preInput.write("CLAF\n")
        preInput.write(f"{CLaf}\n")
        #Terza section
        preInput.write("SECTION\n")
        preInput.write(f"{C_LE_sect3[0]} {C_LE_sect3[1]} {C_LE_sect3[2]} {c_sect_3} {AoA_root} 0 0\n")
        preInput.write("AFILE\n")
        preInput.write(f"{profile_name}\n")
        preInput.write("CDCL\n")
        preInput.write(f"{polare_CL[0]} {polare_CD[0]} {polare_CL[1]} {polare_CD[1]} {polare_CL[2]} {polare_CD[2]}\n")
        preInput.write("CLAF\n")
        preInput.write(f"{CLaf}\n")

creazione_preinput(preInput_nome=preInput_name)



# Si genera un file di input

CL=0.3  #CL di crociera
V=271  #Velocità di crociera

def creazione_file_input(file_preinput,path_input="AvlInput.in"):
    
    with open(path_input, 'w') as AvlInput:
        AvlInput.write(f"load {file_preinput}\n")
        AvlInput.write("oper\n")
        AvlInput.write("c1\n")
        AvlInput.write("X\n")
        AvlInput.write("T\n")

def run_avl(path_avl, path_input):
    path_program = os.path.join(os.getcwd(), path_avl)
    if not os.path.exists(path_program):
        raise FileNotFoundError(f"{path_program} non trovato, vedi se AVL sta nella cartella")
    try:
        result=subprocess.run(f"{path_program} < {path_input}", shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"AVL execution failed for {path_input}. Output:")
            print(result.stdout)
            print(result.stderr)
        else:
            print("Calcoli su AVL effettuati con successo")
    except Exception as e:
        print(f"Errore runnando avl {e}")


creazione_file_input("preInput.avl")

path_avl="avl.exe"
path_input="AvlInput.in"

run_avl(path_avl=path_avl, path_input=path_input)