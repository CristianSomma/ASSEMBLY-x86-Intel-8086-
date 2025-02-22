NAME "somma dei valori presi in input con il ciclo for"

data SEGMENT
    nums DW 5 dup(0)  ; array che conterrà poi i valori presi in input
    sum DW 0    ; variabile che conterrà la somma degli input
    sumDigits DB 4 dup(0)   ; array che conterrà le cifre separate di sum per poterle stampare
    value10 DB 0Ah  ; variabile che contiene il valore 10, poiché utilizzato spesso
    msgP1 DB "Enter 5 numbers (up to 3 digits each).$"
    msgP2 DB "For numbers with fewer than 3 digits, press Enter to proceed to the next:$"
    msgEnd DB "The sum of all numbers equals $"
    inputArrow DB "> $"
ENDS

code SEGMENT
start:
    MOV AX, data
    MOV DS, AX
    
    LEA DX, msgP1    ; muovo in dx l'indirizzo di memoria della stringa da stampare
    CALL printStr  ; chiamo la subroutine per stampare la stringa in dx
    CALL return ; chiamo la subroutine per tornare a capo riga
    
    LEA DX, msgP2    ; muovo in dx l'indirizzo di memoria della stringa da stampare
    CALL printStr  ; chiamo la subroutine per stampare la stringa in dx
    CALL return ; chiamo la subroutine per tornare a capo riga
    
    
    MOV CX, 5   ; inserisco nel registro cx il numero di cicli da effettuare
    MOV DI, 0   ; muovo in di l'offset iniziale da applicare per scorrere l'array nums
get_inputs:
    LEA DX, inputArrow  ; muovo in dx l'indirizzo della stringa da stampare
    CALL printStr  ; stampo la stringa inserita prima dell'inizio del ciclo
    CALL input  ; chiede un numero in input l'input
    CALL return ; torna a capo riga dopo aver ricevuto l'input completo
    ADD DI, 2   ; sommo a di due perché il numero di byte per ogni spazio è 2
    LOOP get_inputs ; con loop decrementa automaticamente cx e ritorna all'inizio del ciclo finché cx != 0

    MOV CX, 5   ; il numero di iterazioni da eseguire equivale alla lunghezza dell'array
    MOV SI, 0   ; muovo in si zero come valore offset iniziale da sommare all'array di input
    MOV AX, sum ; inserisco in ax il valore iniziale della somma, ovvero zero
sum_array_values:
    ADD AX, nums[SI]    ; sommo ad ax, ovvero alla variabile sum, il valore nella posizione corrente dell'array     
    ADD SI, 2   ; sommo a si due perché il numero di byte per ogni spazio è 2
    LOOP sum_array_values
    MOV sum, AX ; aggiorno la variabile sum con il valore effettivo
    
    MOV AX, sum ; muovo in ax il valore della variabile sum per poter effettuare la divisione dei caratteri
    CALL resultSplitter ; chiama la subroutine che divide in singoli caratteri il valore di ax
    
    LEA DX, msgEnd  ; inserisco in dx la stringa da stampare
    CALL printStr
    
    LEA BX, sumDigits   ; muovo in bx l'indirizzo di memoria base da cui partire per iterare l'array
    CALL arrayPrinter   ; chiama la subroutine che stampa i valori nell'array    
    
    MOV AH, 1
    int 21h
    
    MOV AX, 4c00h
    int 21h    
ENDS                                   
;----------------------------------------------------------------------------------------------
printStr PROC NEAR
    MOV AH, 9   ; richiamo la funzione 9 dell'interrupt 21, che stampa una stringa
    int 21h ; chiamata all'interrupt 21
    RET
printStr ENDP   ; fine della subroutine   
;----------------------------------------------------------------------------------------------
return PROC NEAR
    MOV DL, value10 ; muovo in dl, registro che DEVE contenere il codice ASCII da stampare, 10 ovvero line feed (\n)
    MOV AH, 2   ; richiedo la funzione 2 dell'interrupt 21, che stampa un codice ASCII
    int 21h ; chiamata all'interrupt
    
    MOV DL, 0Dh ; muovo in dl il codice ASCII carriage return (\r) per spostare il cursore a capo riga
    MOV AH, 2   ; sempre la funzione 2 per stampare il codice ASCII
    int 21h
    RET ; ritorno alla subroutine che ha chiamato questa funzione
return ENDP ; fine subroutine
;----------------------------------------------------------------------------------------------
input PROC NEAR
        MOV AX, 0   ; reset del registro ax
        MOV BX, 64h ; inserisco in bx il valore per cui moltiplicare il numero per ottenere il suo valore in base alla posizione
    looping_input:    
        MOV AH, 1   ; richiama la funzione 1 dell'interrupt 21
        int 21h ; chiamata all'interrupt 21
        CMP AL, 0Dh ; comparazione del valore ascii inserito con il tasto "Enter" (ASCII = 13) che indica la fine dell'inserimento dell'input
        JE fixed_input  ; salta alla sezione per rivalutare l'input
        MOV AH, 0   ; reset di ah per avere in ax solo il valore contenuto in al
        SUB AL, 30h ; sottraggo al codice ASCII dell'input inserito 48 per ottenere il valore corrisponente
        MUL BX  ; moltiplica l'input per la posizione della cifra per ottenerne il valore corretto
        ADD nums[DI], AX    ; inserisce nell'array l'input risultante
        CMP BX, 1   ; comparazione di bx con la posizione delle unità (1)
        MOV AX, BX  ; muove in ax il valore della posizione per poterla dividere
        DIV value10   ; divide la posizione in ax per 10 così da poter scendere di valore in posizione
        MOV BX, AX  ; rimuovo in bx il valore della posizione
        JG looping_input    ; se bx è maggiore di 1 allora ritorna all'inizio del loop
        JLE end_input   ; altrimenti salta alla fine della subroutine
    fixed_input:
        MOV AX, BX  ; muovo in ax il valore della posizione per poterla moltiplicare
        MUL value10 ; moltiplica per 10 il valore della posizione per ottenere poi, dividendo per questo, un valore valido
        MOV BX, AX  ; rimuovo in bx il valore della posizione per poterlo utilizzare
        MOV AX, nums[DI]    ; muovo in ax il valore preso in input fino ad ora per poterlo dividere
        DIV BX  ; divido per il valore della posizione per correggere il valore inserito fino ad ora
        MOV nums[DI], AX    ; aggiorno il valore nell'array
    end_input:
        RET ; ritorna alla routine padre
input ENDP  ; fine della subroutine
;----------------------------------------------------------------------------------------------
printChar PROC NEAR
    MOV AH, 2   ; uso la funzione 2 dell'interrupt 21, per stampare un codice ASCII
    int 21h ; chiamata all'interrupt
    RET
printChar ENDP
;----------------------------------------------------------------------------------------------
resultSplitter PROC NEAR
        MOV DI, 3   ; l'offset iniziale dell'array, che fa partire la scrittura dall'ultimo elemento
        MOV BX, 000Ah ; muovo in bx il valore del divisore, ovvero 10
    splitting_loop:    
        MOV DX, 0   ; reset del registro ah per evitare errori di sovrascrittura nel ciclo successivo
        DIV BX ; divide il valore della somma per ottenere la singola cifra
        ADD DL, 30h ; somma alla cifra 48 per ottenere il codice ASCII corrispondente 
        MOV sumDigits[DI], DL   ; muovo nell'array la parte meno significativa di dx, che contiene il resto della divisione
        DEC DI  ; decrementa di di 1 scendendo alla posizione precedente nell'array
        CMP AX, 0   ; comparazione di al con zero per controllare se la cifra più significativa è stata raggiunta
        JG splitting_loop   ; se è maggiore di zero effettua un'altra divisione
        RET
resultSplitter ENDP ; fine della subroutine
;----------------------------------------------------------------------------------------------
arrayPrinter PROC NEAR
        MOV AL, 0   ; al contiene zero se nessun numero è ancora stato stampato altrimenti uno
        MOV SI, 0   ; muovo in si l'offset per il primo elemento da stampare
        MOV CX, 4   ; muovo in cx il numero di iterazioni da effettuare
    printing_loop:
        CMP AL, 0   ; compara con zero al per vedere se qualche valore è già stato stampato
        JNE print_instructions ; se almeno un valore è stato stampato stampa incondizionatamente
        CMP BX[SI], 0   ; comparazione dell'elemento dell'array con zero per vedere se bisogna stamparlo
        JE end_printing_loop    ; se il valore dell'elemento è zero salta il processo di stampa
    print_instructions:
        MOV DL, BX[SI]  ; muovo in dl il valore dell'array da stampare        
        CALL printChar  ; chiama la subroutine per stampare il codice ASCII di un carattere in console
    end_printing_loop:
        INC SI  ; incremento dell'offset di uno per passare all'elemento successivo
        LOOP printing_loop
        RET
arrayPrinter ENDP
END start
