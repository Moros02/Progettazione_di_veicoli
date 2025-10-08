Il codice è così strutturato:

- cartella: +convert - vi sono le funzioni di conversione si chiamano come: "convert.funzione(valore)" (e.g "convert.ft_m(20)" converte da piedi in metri).

- cartella: +workfunction - vi sono le funzioni che servono per effettuare operazioni nel codice principale. Attualmente l'unica importante è linear_regression, questa RESTITUISCE IL MODELLO LINEARE mdl e prende 4 input:
	1.var_x variabile indipendente dell'interpolazione lineare (quella sull'asse x) NB: si immette come NOME DELLA VARIABILE NEL DATABASE e.g. 'seats'
	2.var_y variabile dipendente dell'interpolazione lineare (quella sull'asse y) NB: si immette come NOME DELLA VARIABILE NEL DATABASE e.g. 'W_MTO'
	3.Display è una flag, si può mettere true o false, se si inserisce true si vede il grafico dell'interpolazione, se si inserisce false il grafico non viene mostrato (questo perché i grafici ci servono relativamente poco e se vogliamo solo i valori possiamo andare avanti così).
	4.Array: questo prende un vettore riga o colonna, in pratica quando fai l'input della retta di interpolazione devi scegliere il dominio nell'asse x ovvero prendi un certo numero di punti su cui effettuare l'interpolazione. Questo è il ruolo di Array. e.g."linspace(0,10000,300)" interpola usando 300 punti tra 0 e 10000.

Esempio finale di utilizzo mdl=workfunction.linear_regression('seats','W_MTO',true,linspace(0,300,200)) in questo caso si effettua un interpolazione lineare utilizzando il numero di passeggeri su x, su y il peso massimo al take off, si vuole visualizzare il grafico e la retta di interpolazione nel grafico deve andare da 0 a 200 posti con 300 punti totali.

- dati.m: è il file che si occupa di tutti i dati "preliminari" ovvero quelli che non vengono esplicitamente ricavati dal codice o da un'interpolazione. Questo serve per inserire i prerequisiti di progetto, le stime dei valori dei dati del motore e quelli dell'ala. 

- matching_chart.m: è il file che esegue il plot del matching chart, utilizza le equazioni di Q_MTO/S, autonomia e quella della condizione di cruise. ovviamente non sono dati dei valori specifici ma si esegue un plot di tutte le curvette. 

- dati_velivoli.csv: è il database contenente i dati dei velivoli, ha le etichette modificate ed è salvato in comma serparated values (.csv) in modo da essere importato senza errori.

- risoluzione_definitiva.m: è il codice principale, ovvero quello in cui si eseguono le interpolazioni, si prende una stima del peso e si cercano di risolvere le altre equazioni.


su Extras vi sono diversi database (quello delle slides) e in diverse versioni (.xmls,.txt) e poi si trovano altri files/altre versioni del codice, in particolare vi è un file in cui Riccardo ha inserito le equazioni per il Cd0 ma va rivisto perché alcune variabili sono scritte male e poi vi è un file in cui io avevo scritto l'equazione dei pesi ma i nomi delle variabili non sono più coerenti con quelli del nuovo codice perché sono state modificate, pertanto da modificare.

%%%%%%%%%%%%%%%%%%%%%% COSE PRINCIPALI DA VEDERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IMPORTANTE: un problema principale è che il valore di alfa è preso a caso, io penso che alfa sia il carburante che rimane a fine volo in percentuale, ma non ne sono sicurissimo, per cui se deve consumare il 90% allora alfa=0.1 ma è una cosa molto moolto poco sicura, potrebbe tranquillamente essere il contrario.

Ho inserito un'efficienza del profilo probabilmente esagerata. da aggiustare.

COME PROSEGUIRE: se il peso statistico stimato è 46314 si prende tipo 46500 o 47000 e si procede con i calcoli della roba dalle equazioni. 