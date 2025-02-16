name "moltiplicazione di numeri tramite somma e ciclo while"

data segment
    num1 DW 0   ; Inizializzo una variabile da 2 byte (DW) e le assegno il valore zero
    num2 DW 0   ; Inizializzo una seconda variabile nella stessa modalità
    product DW ?    ; variabile inizializzata senza valore (?) che conterrà il prodotto di num1 e num2
    productDigits DB 4 dup(0)   ; vettore contenente 4 byte inizializzati a zero
    msg1 DB "Enter the first number (3 digits):$"
    msg2 DB "Enter the second number (1 digit):$"
    msg3 DB "The result of the multiplication is:$"
    errMsg  DB "ERROR: You can't divide by zero.$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    MOV AX, data    ; muovo il riferimento al data segment nel registro ax perché richiesto da ds
    MOV DS, AX  ; muovo in ds (registro del data segment) il riferimento salvato in ax
                 
    ;-MESSAGGIO 1 e INPUT NUM1-
    LEA DX, msg1             
    CALL printStr
    
    MOV BX, 64h   ; registro bl tiene traccia della posizione della cifra inserita, inizializzata come centinaia
    LEA SI, num1    ; salvo l'indirizzo del primo numero in si per determinare dove salvare il valore di input
    CALL input  ; chiamo la subroutine input per prendere il primo numero
    
    CALL return ; chiamo la subroutine per tornare a capo riga
    
    ;-MESSAGGIO 2 e INPUT NUM2-
    LEA DX, msg2
    CALL printStr
    
    MOV BX, 1   ; muovo in bx come numero di cifre solo 1
    LEA SI, num2    ; definisco come indirizzo in cui salvare num2
    CALL input  ; chiamo la subroutine input
    
    CALL return ; torna a capo riga
    
    CMP num2, 0000h ; comparazione tra il divisore e zero...
    JE error_handling   ; se il divisore è zero salta alla label che gestisce l'errore 
            
    ;-CICLO WHILE DI SOMMA-
    MOV AX, num1    ; muovo in ax num1, il numero da moltiplicare/sommare
    MOV BX, num2    ; muovo in bx num2,  il numero di moltiplicazioni/somme da fare
multiplying:    ; label che indica l'inizio del loop delle somme
    ADD AX, num1    ; sommo ad ax, che mantiene il calcolo delle somme, num1, ovvero il numero da moltiplicare
    DEC BX  ; decremento di uno il numero di somme ancora da effettuare, perché appena fatta
    CMP BX, 1   ; comparazione con 1 perché equivale a sottrarre una moltiplicazione, perché num*1 si salta
    JG multiplying  ; se sono più di une le moltiplicazioni da fare riesegue il ciclo
    
    MOV product, AX ; salvo nella variabile product il risultato delle somme
          
    ;-MESSAGGIO 3 e STAMPA RISULTATO-
    LEA DX, msg3    ; salvo in dx l'indirizzo della stringa da stampare
    CALL printStr   ; stampo la stringa finale con la subroutine apposita
    
    CALL productSplit   ; eseguo lo splitting in cifre singole del prodotto per poterlo stampare
    JMP end_program ; salta alla fine del programma in maniera incondizionata
    
error_handling:
    LEA DX, errMsg  ; muovo in dx l'indirizzo di memoria della stringa da stampare
    CALL printStr   ; stampo la stringa di errore
    
end_program:
    MOV AH, 1   ; richiede come input un carattere qualunque per chiudere il programma
    int 21h
    
    MOV AX, 4c00h   ; ritorna il controllo al sistema operativo
    int 21h    
ENDS
;---------------------------------------------------------------------------------------------
printStr PROC NEAR
    MOV AH, 9   ; muovo in ah il numero della funzione dell'interrupt da eseguire, ovvero stampare una stringa che termina con $
    int 21h ; chiamata all'interrupt 21
    CALL return
    RET ; ritorna alla routine da cui è stata chiamata
printStr ENDP
;---------------------------------------------------------------------------------------------
input PROC NEAR
        MOV AX, 0000h   ; reset del registro ax
        MOV CX, 0Ah ; muovo nel registro cx il valore 10, poiché è necessario un registro o indirizzo come parametro della divisione
    input_loop:
        MOV AH, 1   ; muovo in ah la funzione read con echo di un singolo carattere
        int 21h ; chiamata interrupt 21
        SUB AL, 30h ; sottraggo 48 al codice ASCII inserito per ottenere il corrispondente numero
        CBW ; converte registro al, quello in cui viene salvato il valore inserito, in ax passando quindi da 8 bit a 16 bit
        MUL BX  ; moltiplico il registro sottinteso ax per bl, il valore viene automaticamente salvato in ax
        ADD [SI], AX    ; aggiorno la variabile relativa sommando il valore di ax al suo interno
        CMP BX, 1   ; comparo la posizione della cifra con 1 (unità), in seguito eseguo la divisione per scalare la posizione
        MOV AX, BX  ; muovo la posizione della cifra in ax perché obbligatorio per eseguire la divisione  
        DIV CX  ; divido il registro sottinteso ax per cx (ovvero 10) per scendere all'unità subito più piccola
        MOV BX, AX  ; rimuovo il risultato della divisione in bx
        JNE input_loop  ; se la posizione della cifra non è una unità (cifra meno significativa) allora torna all'inizio del ciclo
        RET
input ENDP    
;---------------------------------------------------------------------------------------------
return PROC NEAR
    MOV DL, 0Ah ; muovo in dl, registro che DEVE contenere il codice ASCII da stampare, 10 ovvero line feed (\n)
    MOV AH, 2   ; richiedo la funzione 2 dell'interrupt 21, che stampa un codice ASCII
    int 21h ; chiamata all'interrupt
    
    MOV DL, 0Dh ; muovo in dl il codice ASCII carriage return (\r) per spostare il cursore a capo riga
    MOV AH, 2   ; sempre la funzione 2 per stampare il codice ASCII
    int 21h
    RET ; ritorno alla subroutine che ha chiamato questa funzione
return ENDP ; fine subroutine
;---------------------------------------------------------------------------------------------
productSplit PROC NEAR 
        MOV AX, product ; in ax muovo il risultato da scomporre in cifre
        MOV BX, 0Ah ; in bx muovo 10, il numero per cui dividere ad ogni iterazione
        MOV SI, 3   ; muovo in si, l'offset, 3 ovvero l'ultima posizione del vettore productDigits
    splitting:
        MOV DX, 0000h   ; reset di dx, che conterrà ad ogni divisione il resto
        DIV BX  ; divido ax per 10, il risultato della divisione è salvato in ax e il resto in dx
        ADD DL, 30h ; sommo al resto, la cifra, 48 per ottenere il codice ASCII corrispondente
        MOV productDigits[SI], DL   ; muovo nella posizione determinata da si del vettore la parte meno significativa del resto
        CMP SI, 0000h   ; comparazione con zero di si, per vedere se è arrivato alla prima posizione del vettore
        DEC SI  ; decremento si per puntare alla posizione del vettore precedente
        JGE splitting   ; se si >= 0 allora rieseguo il ciclo
        CALL printResult    ; chiama la funzione per stampare il risultato nella console
        RET
productSplit ENDP
;---------------------------------------------------------------------------------------------
printResult PROC NEAR
        MOV SI, 1   ; set di si alla seconda posizione del vettore
        MOV DX, 0000h   ; reset del registro dx
        MOV DL, productDigits[0000h]    ; muovo in dl il primo valore del vettore
        CMP DL, 30h   ; comparazione a 48, equivalente ASCII di zero, del primo valore
        JE loopingChars  ; se dl è uguale a zero viene saltata la stampa, altrimenti...
        CALL printChar  ; ...chiamo la subroutine per stampare il primo valore
    loopingChars:
        MOV DL, productDigits[SI]   ; muovo in dl il codice ASCII da stampare
        CALL printChar  ; chiamo la subroutine e stampo il valore in console
        CMP SI, 3   ; comparazione di si al valore massimo del vettore
        INC SI  ; incremento si di uno per puntare alla posizione seguente nel vettore
        JB loopingChars ; se minore torna all'inizio del ciclo. Uso JB (Jump Below) invece di JL (Jump Lower) perché si è senza segno
        RET
printResult ENDP
;---------------------------------------------------------------------------------------------
printChar PROC NEAR
    MOV AH, 2   ; uso la funzione 2 dell'interrupt 21, per stampare un codice ASCII
    int 21h ; chiamata all'interrupt
    RET
printChar ENDP
;---------------------------------------------------------------------------------------------
       
END start
