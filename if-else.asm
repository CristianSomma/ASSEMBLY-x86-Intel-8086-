    name "Somma o sottrazione in base alla condizione"
 
    ;NOTA:
    ;Se la somma supera le due cifre, diventando una centinaia il calcolo non viene effettuato
    ;correttamente.
    
    data segment
        num1 DB 2 dup(?)    ; inizializzo degli pseudo array che conterranno le cifre dei due numeri
        num2 DB 2 dup(?)
        msg1 DB "Enter the first number (Two digits):$"
        msg2 DB "Enter the second number (Two digits):$"
        msg3 DB "Il risultato dell'operazione e' $"
    ENDS
    
    stack segment
        DW   128  dup(0)
    ENDS
    
    code segment
    start:
        MOV AX, data    ; muove la reference al data segment nel registro ax
        MOV DS, AX  ; muove nel registro del data segmente il registro ax (contiene la reference al data segment)
        
        ;-MESSAGGIO N.1 E INPUT NUM1-
        LEA DX, msg1    ; Muovo nel registro DX l'indirizzo di memoria della stringa da stampare
        CALL print  ; Chiamo la subroutine creata per stampare una stringa      
        
        LEA SI, num1    ; Assegno ad SI, ovvero l'indice, l'indirizzo di memoria della variabile num1
        CALL input  ; Chiamo la subroutine creata per prendere un input
        
        ;-MESSAGGIO N.2 E INPUT NUM2-
        LEA DX, msg2    ; Eseguo lo stesso procedimento effettuato per msg1 e input num1
        CALL print
       
        LEA SI, num2
        CALL input
        
        ;-CICLO FOR-             
        MOV CX, 2h  ; Assegna al registro contatore il numero di cicli da effettuare, ovvero due
        LEA SI, num1    ; muovo in SI l'indirizzo di memoria del num1                
        ;LEA DI, num2    ; LINEA CHE DOVREBBE ESSERCI MA NON SEMBRA NECESSARIA ???
        compare_loop:   ; Label che segna l'inizio del ciclo for
        CMP CX, 2h  ; se il contatore (CX) è 2...
        JE cx_equ   ; ... salta alla label cx_equ
        MOV AL, num1[SI]    ; altrimenti salva in al il valore all'indirizzo SI di num1
        MOV BL, num2[DI]    ; salva in bl il valore all'indirizzo DI di num2
        JMP end_compare_loop    ; salta incondizionatamente alla label end_compare_loop
        
        cx_equ: ; Label che indica il blocco di codice dell'if true
        MOV AH, num1[SI]    ; muove in ah il valore all'indirizzo SI di num1    
        MOV BH, num2[DI]    ; stessa cosa viene fatta per num2 in bh
           
        end_compare_loop:   ; label che indica la parte del ciclo comune ad entrambi i blocchi
        INC SI  ; incremento di 1 il registro si per puntare all'indirizzo subito seguente
        INC DI  ; faccio lo stesso anche con di
        LOOP compare_loop   ; se cx != 0 allora decrementa di uno e torna all'inizio del ciclo for
        
        ;-COMPARAZIONI-
        CMP AH, BH  ; esegue una comparazione delle cifre più significative, se ah...
        JG exe_subtraction  ; ...è maggiore di bh allora va al blocco exe_subtraction...
        JL exe_addition ; ...altrimenti salta al blocco di addizione
        ; se AH == BH allora esegue un'altro controllo sulle unità... 
        CMP AL, BL  ; esegue una comparazione delle due cifre meno significative, se al...
        JGE exe_subtraction ; ...è maggiore o uguale a bl allora chiama la sottrazione...
        JL exe_addition    ; ...se invece è minore di bl chiama l'addizione
        
        exe_subtraction:    ; blocco condizionale chiamato quando bisogna eseguire la sottrazione
        CALL subtraction    ; chiama la subroutine di sottrazione
        JMP end_program ; salta incondizionalmente al blocco end_program
        
        exe_addition:   ; blocco condizionale chiamato quando bisogna eseguire la somma
        CALL addition   ; chiama la subroutine di somma
        
        ;-PARTE CONCLUSIVA-
        end_program:    ; blocco di codice comune
        ; per evitare sovrascrizione involontarie:
        MOV BH, AH  ; bh assume il valore di ah
        MOV BL, AL  ; bl assume il valore di al
        
        LEA DX, msg3    ; si stampa il messaggio finale
        CALL print
        
        MOV DL, BH  ; si muove nel registro dl il codice ASCII da stampare
        CALL print_convert_char ; si chiama la subroutine che stampa il carattere
        
        MOV DL, BL  ; si fa lo stesso anche con la cifra delle unità
        CALL print_convert_char
        
        MOV AH, 1   ; si richiede un input per chiudere la finestra
        int 21h   
        
        MOV AX, 4c00h   ; il controllo ritorna al sistema operativo
        int 21h    
    ends
    ;---------------------------------------------------------------------------------------------          
    input PROC NEAR
        MOV CX, 2   ; assegno al counter 2, ovvero il numero di input da ricevere
        input_loop:  ; Label che indica l'inizio del loop
        MOV AH, 01h ; Utilizzo la funzione di input con echo
        int 21h ; Richiamo l'interrupt
        SUB AL, 30h ; Sottraggo 48 (30h) al codice ASCII inserito per ottenere il valore numerico
        MOV [SI], AL   ; Inserisco in num1, all'indirizzo determinato tramite SI l'input
        INC SI  ; Incremento di uno il registro SI (Source Index)
        LOOP input_loop:   ; se cx != 0 salta alla label input_loop e riesegue il codice
        CALL return ; chiamo la subroutine per tornare a capo riga
        RET ; Ritorna alla routine Main
    input ENDP    ; Fine della subroutine
    ;---------------------------------------------------------------------------------------------   
    print PROC NEAR
        MOV AH, 09h ; Richiamo la funzione per stampare una stringa che termina con $ dell'int 21
        int 21h ; Richiamo l'interrupt 21   
        CALL return ; chiamo al subroutine per tornare a capo riga
        RET
    print ENDP  ; Fine della subroutine   
    ;---------------------------------------------------------------------------------------------
    return PROC NEAR
        MOV DL, 0Ah ; muove nel registro dl il codice ASCII del Line Feed (\n)
        MOV AH, 02h ; Richiamo la funzione per stampare un carattere dato codice ASCII in dl
        int 21h
        
        MOV DL, 0Dh ; muove nel registro dl il codice ASCII del carriage return (\r)
        MOV AH, 02h
        int 21h 
        RET
    return ENDP ; Fine della subroutine
    ;---------------------------------------------------------------------------------------------
    addition PROC NEAR  ; subroutine per eseguire l'addizione dei due numeri
        ADD AL, BL  ; somma le due cifre meno significative dei due numeri
        CMP AL, 0Ah ; se il risultato è maggiore di 10...
        JGE carry   ; ...salta alla label carry che gestisce il riporto
        ADD AH, BH  ; altrimenti somma le due cifre più significative
        RET ; ritorna alla routine main
        
        carry:  ; blocco che viene chiamato nel momento in cui c'è un riporto
        SUB AL, 0Ah ; sottrae 10 per ottenere un numero a cifra singola
        ADD AH, BH  ; somma le due cifre più significative
        ADD AH, 1   ; somma al risultato il riporto
        RET
    addition ENDP   ; fine della subroutine
    ;---------------------------------------------------------------------------------------------
    subtraction PROC NEAR   ; subroutine che esegue la sottrazione
        SUB AL, BL  ; sottrazione tra le due cifre meno significative
        CMP AL, 0000h   ; compara il risultato a zero, se al...
        JL back_carry   ; ...è minore di zero salta al blocco back_carry
        SUB AH, BH  ; ...altrimenti esegue la sottrazione tra le due cifre più significative
        RET ; ritorna alla routine main
        
        back_carry: ; blocco eseguito se il AL < 0
        ADD AL, 0Ah  ; somma ad al 10 per avere il valore positivo corretto
        SUB AH, BH  ; sottrazione tra i due numeri più significativi
        SUB AH, 1   ; sottrazione del riporto prestato alle cifre meno significative
        RET
    subtraction ENDP
    ;---------------------------------------------------------------------------------------------
    print_convert_char PROC NEAR
        ADD DL, 30h ; si aggiunge al numero da stampare 48 per ottenere il codice corrispondente
        MOV AH, 02h ; stampa il contenuto di al (codice ASCII)
        int 21h
        RET
    print_convert_char ENDP ; Fine della subroutine
    ;---------------------------------------------------------------------------------------------
    END start
