;程序描述--实现图示 HANOI 移动过程
;CREATED TIME:2018-06-03
;程序说明：可修改子程序GRAPHPRINT中的移动时间，便于测试。

DATAS SEGMENT
	;-------- HANOI 格式输入输出文字描述 --------------
    INPUTMSG  DB 'Please input the number of disk:',0DH,0AH,24H;输入圆盘个数
	INPUTMSG1 DB 'The first pillar:',0DH,0AH,24H;第一根柱子
	INPUTMSG2 DB 'The second pillar:',0DH,0AH,24H
	INPUTMSG3 DB 'The third pillar:',0DH,0AH,24H
	PROGRAM_TITLE     DB '         SHOW HANOI MOVEMENT         ',24H
	CRLF      DB 0DH,0AH,24H;回车换行
	MOVE_DISK_NUMBER DB ' Disk:',24H;格式显示
	
	
	MOVE_START DB ' MD:From ',24H;格式显示
	MOVE_END DB ' to ',24H
	PSTEPS DB '  Steps:',24H
	STEPS DW 0;统计移动次数
	NUMBER DW 0;变量保存磁盘个数
	MOVED_NUMBER DB 0;每次移动的磁盘编号 
	X DW '0';存储柱子名称
	Y DW '0'
	Z DW '0'
	
	
	;------- HANOI 图示移动显示设计 --------
	TEMP DW 0;临时变量
	X_AXIS1 DW 0 ;处理横坐标
	X_AXIS2 DW 0 
	Y_AXIS1 DW 100 ;处理纵坐标 
	Y_AXIS2 DW 100 
	Y_AXIS3 DW 100 
	
	
DATAS ENDS

STACKS SEGMENT
    DB 255H DUP(?) 
STACKS ENDS
;***********************************************
CODES SEGMENT
;主程序
;-----------------------------------------------
MAIN PROC FAR
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	PUSH DS ;初始化数据段
	SUB AX,AX
	PUSH AX 
    MOV AX,DATAS
    MOV DS,AX
       
    LEA DX,INPUTMSG
    MOV AH,09H
    INT 21H 
       
    CALL DECTOBIN;十进制圆盘个数以二进制形式存入 BX
    MOV NUMBER,BX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    CMP BX,0;输入个数为0个则退出程序
    JE EXIT
    
    LEA DX,INPUTMSG1;柱子A
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH;赋值
    MOV X,AX;
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    
    LEA DX,INPUTMSG2;柱子B
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH
    MOV Y,AX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    LEA DX,INPUTMSG3;柱子C
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH
    MOV Z,AX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    ;执行时间延迟
    ;====================  
    CALL INIT;打印初始状态
    MOV BL,80;延迟4S开始移动 TIME/20S
MOVE_TIME: 
    MOV CX,33144;0.05S 
    CALL WAITP 
	DEC BL 
	JNZ MOVE_TIME
    ;=============
    
    MOV CX,X 
	MOV SI,Y
	MOV DI,Z ;柱子 Z,Y,Z
	MOV BX,NUMBER 
    CALL HANOI;调用子程序 HANOI 递归算法    
   
 EXIT:  RET
 MAIN ENDP
    
;十进制输入转二进制 --> BX
;----------------------------------------------
DECTOBIN PROC NEAR	
    XOR BX,BX	
INPUTD:
	MOV AH,01H
	INT 21H;输入圆盘个数
    SUB AL,30H
    JL EXIT_DECTOBIN 
    CMP AL,9
    JG EXIT_DECTOBIN 
    CBW ;AL --> AX
    
    ;转AX中的十进制数转为二进制
  
    XCHG AX,BX
    MOV CX,10
    MUL CX
    XCHG AX,BX
    ADD BX,AX
    JMP INPUTD
EXIT_DECTOBIN :RET
DECTOBIN ENDP


;HANOI 递归算法
;根据经典递归算法:
;(1)N==1,MOVE(N,X,Z)
;(2)HANOI(N-1,X,Z,Y)
;(3)MOVE(N,X,Z)
;(4)HANOI(N-1,Y,X,Z)
;--------------------------------------
HANOI PROC NEAR
;(BX)=N,(CX)=X,(SI)=Y,(DI)=Z
	CMP BX,1;IF N==1 A-->C
	JE BASIS
	CALL SAVE;SAVE(N,X,Y,Z) 保存数据顺序 X,Y,Z
	DEC BX;执行递归
	XCHG SI,DI;Y,Z位置互换
	CALL HANOI;执行 HANOI(N-1,X,Z,Y) 递归 
	CALL RESTOR;恢复数据 N,X,Y,Z
	CALL DETAILMSG;打印每一步的移动信息
	CALL GRAPHPRINT;打印圆盘
	DEC BX ;继续递归
	XCHG CX,SI;X,Y位置互换
	CALL HANOI;HANONI(N-1,Y,X,Z)
	JMP RETURN
BASIS:
	CALL DETAILMSG;打印每一步的移动信息
	CALL GRAPHPRINT;打印圆盘
RETURN:
	RET
HANOI ENDP	

;打印每一步圆盘移动情况
;-------------------------------------------------	
DETAILMSG PROC NEAR
	CALL STEPSP ;调用步骤统计
	;输出移动路径 A-->C
	LEA DX,MOVE_DISK_NUMBER
	MOV AH,09H
	INT 21H
	
	;MOV AX,BX;AX=N
	CALL BINTODEC;PRINT N 
	
	LEA DX,MOVE_START;格式输出
	MOV AH,09H
	INT 21H
	
	MOV DX,CX;输出起始移动点
	MOV AH,02H
	INT 21H
	
	LEA DX,MOVE_END;格式输出
	MOV AH,09H
	INT 21H
	
	MOV DX,DI;Z
	MOV AH,02H;目标移动点
	INT 21H
	
	;LEA DX,CRLF
	;MOV AH,09H
	;INT 21H
	
	MOV DX,20H
	MOV AH,02H
	INT 21H
	
	RET
DETAILMSG ENDP

;保护数据
;-----------------------------------------------
SAVE PROC NEAR ;保存	
	POP BP
	PUSH BX;保存 N
	PUSH CX;保存 X
	PUSH SI;保存 Y
	PUSH DI;保存 Z
	PUSH BP
	RET
SAVE ENDP

;恢复数据
;-----------------------------------------------
RESTOR PROC NEAR
	;从栈输出 N,Z,Y,X
	POP BP
	POP DI;恢复 Z
	POP SI;恢复 Y
	POP CX;恢复 X
	POP BX;恢复 N
	PUSH BP
	RET
RESTOR ENDP

; 二进制转十进制输出
; 将需要转换的的二进制数存入 BX
;-----------------------------------------------
BINTODEC PROC NEAR
	CALL SAVE
	MOV AX,BX
	MOV SI,10
	MOV CX,0
PUSHDATA:	
    XOR DX,DX
	DIV SI
	PUSH DX
	INC CX
	CMP AX,0
	JZ POPDATA
	JMP PUSHDATA 
POPDATA:
	POP DX
	ADD DL,30H
	MOV AH,02H
	INT 21H
	LOOP POPDATA
	
	CALL RESTOR
	RET
BINTODEC ENDP

;步数统计子程序
STEPSP PROC NEAR
	CALL SAVE
	INC STEPS
	
	;设置文字输出在屏幕中位置
	;=====================
	MOV AH,2 ;置光标
	MOV BH,0 ;第0页
	MOV DH,17;DH中放行号
	MOV DL,2 ;DL中放列号
	INT 10H
	;=====================

	LEA DX,PSTEPS
	MOV AH,09H
	INT 21H	
		
	MOV BX,STEPS
	CALL BINTODEC;以十进制输出步数
	CALL RESTOR 
	RET
STEPSP ENDP

;初始化屏幕
;-----------------------------------------------------------------       
INIT PROC NEAR 	
	PUSH BX 
	MOV AH,00H 
	MOV AL,04H ;屏幕设为为 320*200 像素,四色
	INT 10H ;10H中断
	MOV CX,60 ;初始化三根柱子，CX=80，X柱子横坐标 
INIT1: 
	MOV DX,30 ;坐标 30 开始画 
INIT2: 
	MOV AL,2 ;颜色
	MOV AH,0CH ;写点素
	INT 10H 
	INC DX;往纵向写点素
	CMP DX,100 ;柱子高度
	JL INIT2 ;没有110 则继续写，有110则继续画下一根杆子
	ADD CX,100 ;每两根柱子间隔80 
	CMP CX,261;写完第三根柱子 
	JL INIT1 ;没写完三根柱子则继续画
	MOV DX,100 ;柱子高度
	MOV CX,60 ;圆盘画图起点
INIT3: ;确定第一根柱子圆盘横坐标 
	MOV AX,0 
	MOV AL,2 
	
	MUL BL ;乘积16位数-->(AX)
	MOV X_AXIS1,AX ;X_AXIS1=2*BL
	ADD X_AXIS1,76 ;X_AXIS1=2*BL+76
	MOV X_AXIS2,44 ;X_AXIS2=44
	SUB X_AXIS2,AX ;X_AXIS2=44-2*BL
INIT4: 
	MOV AL,1 ;颜色
	MOV AH,0CH ;写点素
	INT 10H ;CX 为开始横坐标，DX为纵坐标
	INC CX ;往右画点素
	CMP CX,X_AXIS1 ;限制圆盘大小
	JL INIT4 ;小于此长度继续横向画点素
	MOV CX,60 ;
INIT5: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX;往左画点素
	CMP CX,X_AXIS2 
	JNL INIT5 
	DEC BL;画下个圆盘 
	JE EXITINIT 
	SUB DX,3;圆盘上下间隔3 
	MOV CX,60 
	JMP INIT3 
EXITINIT: 
	SUB DX,3                                  
	MOV Y_AXIS1,DX;Y_AXIS1 为第一根柱子最上面的圆盘中心纵坐标
	POP BX
	
    PUSH BX
	PUSH CX
	;设置文字输出在屏幕中位置
	;=====================
	MOV AH,2 ;置光标
	MOV BH,0 ;第0页
	MOV DH,1;DH中放行号
	MOV DL,2 ;DL中放列号
	INT 10H
	;=====================

	LEA DX,PROGRAM_TITLE
	MOV AH,09H
	INT 21H	
	
	;设置文字输出在屏幕中位置
	;=====================
	MOV AH,2 ;置光标
	MOV BH,0 ;第0页
	MOV DH,14;DH中放行号
	MOV DL,7 ;DL中放列号
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[X]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
    
    
    ;设置文字输出在屏幕中位置
	;=====================
	MOV AH,2 ;置光标
	MOV BH,0 ;第0页
	MOV DH,14;DH中放行号
	MOV DL,20 ;DL中放列号
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[Y]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
    
    ;设置文字输出在屏幕中位置
	;=====================
	MOV AH,2 ;置光标
	MOV BH,0 ;第0页
	MOV DH,14;DH中放行号
	MOV DL,32 ;DL中放列号
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[Z]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
	
	POP CX
	POP BX
	
	RET 
INIT ENDP 

;图示移动圆盘处理
;------------------------------------------------------------
GRAPHPRINT PROC NEAR 
	CALL SAVE
	
	;处理 X 柱子
	CMP CX,X;CX=A，CLEAR X上的A  
	JE CLEARA 
	CMP CX,Y ;CX=B，CLEAR X上的B 
	JE CLEARB 
	CMP CX,Z ;CX=C，CLEAR X上的C  
	JE CLEARC 
	
GRAPHPRINT1:;处理 X 柱子
	MOV MOVED_NUMBER,BL;移动的盘 
	PUSH BX 
	CMP DI,X;CX=A，ADDA 
	JE ADDA 
	CMP DI,Y;CX=B，ADDB 
	JE ADDB 
	CMP DI,Z;CX=C，ADDC  
	JE ADDC 
CLEARA:  ; 纵坐标为 Y_AXIS 的圆盘用黑点覆盖 
	MOV TEMP,CX ;TEMP=X
	ADD Y_AXIS1,3 ;纵坐标下移
	MOV DX,Y_AXIS1	
	MOV CX,10 
CDOTA: 
	MOV AL,4 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,110 
	JL CDOTA 
	;补点
	;-----
	MOV CX,60
	MOV AL,2 
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 
CLEARB:  ; 移去 B 上的圆盘
	MOV TEMP,CX 
	ADD Y_AXIS2,3 
	MOV DX,Y_AXIS2 
	MOV CX,110 
CDOTB: 
	MOV AL,4 ;黑色
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,210 
	JL CDOTB 
	;补点
	;-----
	MOV CX,160
	MOV AL,2 ;紫色
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 
	
CLEARC:   
	MOV TEMP,CX 
	ADD Y_AXIS3,3 
	MOV DX,Y_AXIS3 
	MOV CX,210 
CDOTC: 
	MOV AL,4 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,310 
	JL CDOTC 
	;补点
	;-----
	MOV CX,260
	MOV AL,2 
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 

ADDA:  ;计算圆盘大小 
	MOV DX,Y_AXIS1 
	SUB Y_AXIS1,3
	MOV CL,MOVED_NUMBER 
	MOV AX,0 
	MOV AL,2 
	MUL CL 

	MOV CX,60 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,76 
	MOV X_AXIS2,44 
	SUB X_AXIS2,AX 
TRA: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,X_AXIS1 
	JL TRA 
	MOV CX,60 
TLA: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLA 
	JMP EXIT5 

ADDB:  
	MOV DX,Y_AXIS2 
	SUB Y_AXIS2,3 
	MOV CL,MOVED_NUMBER
	MOV AX,0 
	MOV AL,2 
	MUL CL 
	MOV CX,160 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,176 
	MOV X_AXIS2,144 
	SUB X_AXIS2,AX 
TRB: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 	
	CMP CX,X_AXIS1 
	JL TRB 
	MOV CX,160 
TLB: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLB 
	JMP EXIT5 

ADDC: 
	MOV DX,Y_AXIS3 
	SUB Y_AXIS3,3 
	MOV CL,MOVED_NUMBER
	MOV AX,0 
	MOV AL,2 
	MUL CL 
	MOV CX,260 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,276 
	MOV X_AXIS2,244 
	SUB X_AXIS2,AX 
TRC: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,X_AXIS1 
	JL TRC 
	MOV CX,260 
TLC: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLC 
	JMP EXIT5 

EXIT5: 
	MOV BL,1 ;10控制移动圆盘的时间间隔(0.5移动一个圆盘)
MOVE1: 
	MOV CX,33144 
	CALL WAITP 
	DEC BL 
	JNZ MOVE1 
	MOV CX,TEMP 
	
	POP BX 
	CALL RESTOR
	RET 
GRAPHPRINT ENDP 
     
;CX必须是15.08US的倍数，延迟0.05S CX=33144
;与 CPU 无关的时间延迟子程序
;-------------------------------------------
WAITP PROC NEAR
	PUSH AX 
	XOR AX,AX
DELAY1: 
	IN AL,61H 
	AND AL,10H 
	CMP AL,AH 
	JE DELAY1 
	MOV AH,AL 
	LOOP DELAY1 
	POP AX 
	RET 
WAITP ENDP 

CODES ENDS

	END START










