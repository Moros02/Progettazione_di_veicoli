import os
import subprocess
import time
import sys
#nome del file criptato e chiave di decrittazione si trovano e prendono dal file encripter.py
the_ship="00000000021d0a1c1700083e0a411f0b"
key="the_door"


def crea_protocollo_trainman(airfoil_name, alpha_i, alpha_f, alpha_step, Re, n_iter, the_trainman_path="the_trainman.in", polar_file_path="polar.txt"):
    """Writes the XFOIL input file for a given airfoil."""
    if os.path.exists(polar_file_path):  #si vede se esisono già i file delle polari
        os.remove(polar_file_path)      #se i file delle polari esistono si canellano

    with open(the_trainman_path, 'w') as the_trainman:
        #si mandano tutti i comandi dello script di xfoil
        the_trainman.write(f"LOAD {airfoil_name}.dat\n")
        the_trainman.write(f"{airfoil_name}\n")
        the_trainman.write("PANE\n")
        the_trainman.write("OPER\n")
        the_trainman.write(f"Visc {Re}\n")
        the_trainman.write("PACC\n")
        the_trainman.write(f"{polar_file_path}\n\n")
        the_trainman.write(f"ITER {n_iter}\n")
        the_trainman.write(f"ASeq {alpha_i} {alpha_f} {alpha_step}\n")
        the_trainman.write("\n\n")
        the_trainman.write("quit\n")
#si crea la funzione per decriptare il nome del file
def the_keymaker(input_str, key):
    return ''.join(chr(ord(c) ^ ord(key[i % len(key)])) for i, c in enumerate(input_str))

# Si controlla la nave, expected_ship è la nave che voglio, found_ship la nave che mi ritrovo

def control_ship_file(expected_ship):
    """Check if the script name matches the expected name."""
    found_ship = os.path.basename(__file__)  # Get the name of the current file
    converted_ship=bytes.fromhex(expected_ship).decode('utf-8') #si converte il nome dato all'inizio da esadecimale
    new_ship= the_keymaker(converted_ship, key) #si decripta il nome e si compara con il nome attuale del file.
    if found_ship != new_ship:
        # se il nomer del file non è quello da un errore molto filosofico preso da matrix
        print("Everything that has a beginning has an end. I see the end coming, I see the darkness spreading.")
        print("You corrupted your ship. Return to the origin to restore the balance.")
        sys.exit(1)  # Exit the program with an error code
    else:
        print("We found the One. Now we shall not fear them")




def run_xfoil(xfoil_path="xfoil.exe", the_trainman_path="the_trainman.in", tempo_in_stazione=30, airfoil_name="airfoil"):
    """Runs XFOIL with the given input file."""
    # tempo in stazione è in secondi.
    #si vede se c'è xfoil nella cartella perché serve che sia in quella cartella.
    if not os.path.exists(xfoil_path):
        raise FileNotFoundError(f"{xfoil_path} not found. Ensure XFOIL is installed and accessible.")
    
    try:
        orologio= time.time()
        #si esegue xfoil dandogli come input le righe del file trainman,
        result = subprocess.run(f"{xfoil_path} < {the_trainman_path}", shell=True, capture_output=True, text=True, timeout=tempo_in_stazione)
        tempo_di_attesa_treno=time.time()-orologio
        if result.returncode != 0:
            print(f"XFOIL execution failed for {the_trainman_path}. Output:")
            print(result.stdout)
            print(result.stderr)
        else:
            print(f"Polar calculation executed successfully for {airfoil_name}. in {tempo_di_attesa_treno:.2f} secondi")
    except subprocess.TimeoutExpired:
        print(f"il treno per {airfoil_name} ha ritardato troppo, sei bloccato tra questo mondo e l'altro.")
        sys.exit(1)
    except Exception as e:
        print(f"Error running XFOIL: {e}")

# Inputs
#si prendono gli input inseriti dall'utente e si raccolgono
def collect_inputs():
    """Collect Reynolds number and alpha range from the user."""
    try:
        #si convertono gli input in floating point in modo da utilizzarli.
        Re = float(input("Enter your Reynolds number: "))
        if Re<1e5:
            print(f"Reynols is a bit low")
        alpha_i = float(input("Enter your initial alpha: "))
        alpha_f = float(input("Enter your final alpha: "))
        alpha_step = float(input("Enter your alpha step: "))
    except ValueError:
        print("Invalid input. Please enter numerical values.")
        return None

    return Re, alpha_i, alpha_f, alpha_step

Inputs=collect_inputs()
Re, alpha_i, alpha_f, alpha_step = Inputs
#print("your input values are:\n")
# print(f"Reynolds= {Re}.\n")
# print(f"Initial Angle= {alpha_i}.\n")
# print(f"Final Angle= {alpha_f}.\n")
# print(f"Angle step= {alpha_step}.\n")

#N57686
#si prende il path corrente di lavoro come path per gli input e output dei files.
profiles_folder = os.getcwd()  # Folder containing .dat files
parent_dir = os.path.dirname(os.getcwd())
output_folder = os.path.join(parent_dir, "airfoil_polars")
xfoil_path = "xfoil.exe"
# alpha_i = alpha_i
# alpha_f = 20
# alpha_step = 0.25
# Re = 1000000
n_iter = 100

# Ensure output folder exists
os.makedirs(output_folder, exist_ok=True)

control_ship_file(the_ship)

# Iterate through all .dat files in the profiles folder
for filename in os.listdir(profiles_folder):
    if filename.endswith(".dat"):
        airfoil_name = os.path.splitext(filename)[0]  # Extract airfoil name without extension
        # polar_file_path = os.path.join(output_folder, f"{airfoil_name}_polar.txt")
        polar_file_path = f"{airfoil_name}_polar.txt"
        print(f"Testing values for {airfoil_name}...")

        # Write XFOIL input for this airfoil
        #si usa il protocollo trainman precedentemente creato
        crea_protocollo_trainman(
            airfoil_name=airfoil_name,
            alpha_i=alpha_i,
            alpha_f=alpha_f,
            alpha_step=alpha_step,
            Re=Re,
            n_iter=n_iter,
            the_trainman_path="the_trainman.in",
            polar_file_path=polar_file_path
        )

        # Run XFOIL
        skipped_airfoils = []
        try:
            run_xfoil(xfoil_path=xfoil_path, tempo_in_stazione=30, airfoil_name=airfoil_name)
        except subprocess.TimeoutExpired:
            #questo servirebbe per creare un'array di airfoil skippati ma non funziona il comando di skip quindi amen non serve.
            skipped_airfoils.append(airfoil_name)
            print(f"{airfoil_name} è bloccato tra questo e quel mondo.")
