.386
.model flat, stdcall
.stack 4096
INCLUDE irvine32.inc
ExitProcess PROTO, dwExitCode:DWORD


.DATA
    index DWORD 1
    marks DWORD 0
    counter DWORD 5
    isAdmin DWORD FALSE
    isUser DWORD FALSE
    adminUsername DWORD "admin", 0
    adminPassword DWORD "admin", 0
    choice2MSG BYTE "Enter your choice: ",0
    enterSapMSG BYTE "Enter SAP ID: ", 0
    enterPassMSG BYTE "Enter password: ", 0
    enterQuestMSG BYTE "Enter the question: ", 0
    enterOp1MSG BYTE "Enter option 1: ", 0
    enterOp2MSG BYTE "Enter option 2: ", 0
    enterOp3MSG BYTE "Enter option 3: ", 0
    enterOp4MSG BYTE "Enter option 4: ", 0
    enterAnsMSG BYTE "Enter the correct answer: ", 0
    admin_menu_prompt BYTE "Enter admin menu choice: ", 0
    enter_username_prompt BYTE "Enter username: ", 0
    enter_password_prompt BYTE "Enter password: ", 0
    welcome_admin BYTE "Welcome, admin!", 0

    userRecord STRUCT
        sapId DWORD ?
        pass DWORD 20 DUP (?)
    userRecord ENDS

    recordArray userRecord <>

    quests STRUCT
        quest DWORD 100 DUP (?)
        op1 DWORD 50 DUP (?)
        op2 DWORD 50 DUP (?)
        op3 DWORD 50 DUP (?)
        op4 DWORD 50 DUP (?)
        ans DWORD ?
    quests ENDS

    questsArray quests <?>

.CODE
main PROC
    call menu
    invoke ExitProcess, 0
main ENDP

menu PROC
    LOCAL choice1:BYTE
    LOCAL choice2:DWORD
    LOCAL choice3:DWORD

    L1:
        mov edx, OFFSET choice2MSG
        call WriteString
        call ReadInt
        mov choice2, eax

        .IF choice2 == 1
            jmp admin_login
        .ELSEIF choice2 == 2
            jmp user_login
        .ELSEIF choice2 == 3
            jmp user_signup
        .ELSEIF choice2 == 4
            jmp exit_program
        .ENDIF

    admin_login:
        call adminLogin
        .IF isAdmin
            jmp admin_menu
        .ELSE
            jmp L1
        .ENDIF

    admin_menu:
        mov edx, OFFSET admin_menu_prompt
        call WriteString
        call ReadInt
        mov choice3, eax

        .IF choice3 == 1
            jmp view_all_questions
        .ELSEIF choice3 == 2
            jmp add_question
        .ELSEIF choice3 == 3
            jmp modify_question
        .ELSEIF choice3 == 4
            jmp delete_question
        .ELSEIF choice3 == 5
            jmp L1
        .ELSE
            jmp admin_menu
        .ENDIF

    view_all_questions:
        call viewAllQuestions
        jmp admin_menu

    add_question:
        call addQuestion
        jmp admin_menu

    modify_question:
        call modifyQuestion
        jmp admin_menu

    delete_question:
        call deleteQuestion
        jmp admin_menu

    user_login:
        call record_login
        .IF isUser
            jmp user_quiz
        .ELSE
            jmp L1
        .ENDIF

    user_signup:
        call record_signUp
        jmp L1

    user_quiz:
        call Quiz
        jmp L1

    exit_program:
        ret

menu ENDP

adminLogin PROC
    LOCAL username:DWORD
    LOCAL password:DWORD

    mov edx, OFFSET enter_username_prompt
    call WriteString
    call ReadString
    mov username, eax

    mov edx, OFFSET enter_password_prompt
    call WriteString
    call ReadString
    mov password, eax

    mov ebx, OFFSET adminUsername
    mov ecx, OFFSET username
    call StrCompare
    .IF eax == 0
        mov ebx, OFFSET adminPassword
        mov ecx, password
        call StrCompare
        .IF eax == 0
            mov isAdmin, TRUE
            mov edx, OFFSET welcome_admin
            call WriteString
        .ENDIF
    .ENDIF

    ret

adminLogin ENDP

record_signUp PROC
    LOCAL sapId[20]:DWORD
    LOCAL pass[20]:DWORD

    mov edx, OFFSET enterSapMSG
    call WriteString
    call ReadInt
    mov sapId, eax

    mov edx, OFFSET enterPassMSG
    call WriteString
    call ReadString
    mov pass, eax

    mov eax, index
    imul eax, SIZEOF userRecord
    mov edi, OFFSET recordArray
    add edi, eax
    mov [edi].sapId, sapId
    mov ebx, pass
    mov ecx, 20
    call StrCopy

    inc index
    ret

record_signUp ENDP

record_login PROC
    LOCAL username[20]:DWORD
    LOCAL password[20]:DWORD

    mov edx, OFFSET enterSapMSG
    call WriteString
    call ReadInt
    mov username, eax

    mov edx, OFFSET enterPassMSG
    call WriteString
    call ReadString
    mov password, eax

    mov esi, OFFSET recordArray
    mov ecx, index
    mov ebx, 0

    record_login_loop:
        mov eax, [esi + ebx].sapId
        .IF eax == username
            mov eax, [esi + ebx].pass
            mov edi, OFFSET password
            call StrCompare
            .IF eax == 0
                mov isUser, TRUE
            .ENDIF
            jmp record_login_end
        .ENDIF

        add ebx, SIZEOF userRecord
        loop record_login_loop

    record_login_end:
        ret

record_login ENDP

addQuestion PROC
    LOCAL quest:DWORD
    LOCAL op1:DWORD
    LOCAL op2:DWORD
    LOCAL op3:DWORD
    LOCAL op4:DWORD
    LOCAL ans:DWORD

    mov edx, OFFSET enterQuestMSG
    call WriteString
    call ReadString
    mov quest, eax

    mov edx, OFFSET enterOp1MSG
    call WriteString
    call ReadString
    mov op1, eax

    mov edx, OFFSET enterOp2MSG
    call WriteString
    call ReadString
    mov op2, eax

    mov edx, OFFSET enterOp3MSG
    call WriteString
    call ReadString
    mov op3, eax

    mov edx, OFFSET enterOp4MSG
    call WriteString
    call ReadString
    mov op4, eax

    mov edx, OFFSET enterAnsMSG
    call WriteString
    call ReadChar
    mov ans, eax

    mov eax, counter
    imul eax, SIZEOF quests
    mov edi, OFFSET questsArray
    add edi, eax
    mov ecx, 100
    mov ebx, OFFSET quest
    call StrCopy
    mov ecx, 50
    mov ebx, OFFSET op1
    call StrCopy
    mov ebx, OFFSET op2
    call StrCopy
    mov ebx, OFFSET op3
    call StrCopy
    mov ebx, OFFSET op4
    call StrCopy
    mov [edi].ans, ans

    inc counter
    ret

addQuestion ENDP

deleteQuestion PROC
    LOCAL indexToDelete: DWORD
    LOCAL i: DWORD

    mov edx, OFFSET enterSapMSG
    call WriteString
    call ReadInt
    mov indexToDelete, eax

    cmp indexToDelete, counter
    jae deleteQuestion_end

    mov questsArray[indexToDelete].quest, '',0
    mov questsArray[indexToDelete].op1, '',0
    mov questsArray[indexToDelete].op2, '',0
    mov questsArray[indexToDelete].op3, '',0
    mov questsArray[indexToDelete].op4, '',0
    mov questsArray[indexToDelete].ans, '',0

    deleteQuestion_skip_move:
    dec counter

deleteQuestion_end:
    ret
deleteQuestion ENDP



modifyQuestion PROC
    LOCAL choice: DWORD
    LOCAL index: DWORD
    LOCAL newQuest: DWORD
    LOCAL newOp1: DWORD
    LOCAL newOp2: DWORD
    LOCAL newOp3: DWORD
    LOCAL newOp4: DWORD
    LOCAL newAns: BYTE

    mov edx, OFFSET enterSapMSG
    call WriteString
    call ReadInt
    mov index, eax

    mov edx, OFFSET enterQuestMSG
    call WriteString
    call ReadString
    mov newQuest, eax

    mov edx, OFFSET enterOp1MSG
    call WriteString
    call ReadString
    mov newOp1, eax

    mov edx, OFFSET enterOp2MSG
    call WriteString
    call ReadString
    mov newOp2, eax

    mov edx, OFFSET enterOp3MSG
    call WriteString
    call ReadString
    mov newOp3, eax

    mov edx, OFFSET enterOp4MSG
    call WriteString
    call ReadString
    mov newOp4, eax

    mov edx, OFFSET enterAnsMSG
    call WriteString
    call ReadChar
    mov newAns, al

    ; Update the specified question with the new values
    mov eax, index
    imul eax, SIZEOF quests
    mov edi, OFFSET questsArray
    add edi, eax
    mov ebx, OFFSET newQuest
    mov ecx, 100
    call StrCopy

    mov ebx, OFFSET newOp1
    mov ecx, 50
    call StrCopy

    mov ebx, OFFSET newOp2
    call StrCopy

    mov ebx, OFFSET newOp3
    call StrCopy

    mov ebx, OFFSET newOp4
    call StrCopy

    mov [edi].ans, newAns

    ret
modifyQuestion ENDP


Quiz PROC
    LOCAL answer:BYTE
    LOCAL i:DWORD

    mov i, 0

    quiz_loop:
        mov edx, OFFSET questsArray[i].quest
        call WriteString
        mov edx, OFFSET questsArray[i].op1
        call WriteString
        mov edx, OFFSET questsArray[i].op2
        call WriteString
        mov edx, OFFSET questsArray[i].op3
        call WriteString
        mov edx, OFFSET questsArray[i].op4
        call WriteString
        mov edx, OFFSET enterAnsMSG
        call WriteString
        call ReadChar
        mov answer, al
        .IF answer == questsArray[i].ans
            inc marks
            mov edx, OFFSET correct_msg
            call WriteString
        .ELSE
            mov edx, OFFSET incorrect_msg
            call WriteString
        .ENDIF

        inc i
        .IF i < counter
            jmp quiz_loop
        .ENDIF

    ret

Quiz ENDP

END main
