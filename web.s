.intel_syntax noprefix

.global _start

.section .data
toWrite:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"
    lenw = . - toWrite

NO:        
    .ascii "HTTP/1.0 404  FUCK YOU\r\n\r\n"
    leno = . - NO
splitter: 
     .ascii "\r\n\r\n"
     lens =4

get: .ascii "GET"
post: 
    .ascii "POST"
.section .bss
fread:
	.skip 10240
len: 
 	.skip 8
looper:
 	.skip 3
buffer:
    .skip 10240
fd3:
    .skip 8
data: .skip 10240
gp: .skip 10240
.section .text
_start:







###
mov rdi,2
mov rsi,1       #socket(AF_INET,SOCK_STREAM,0)
mov rdx,0
mov rax,41
syscall
###


###
mov rdi,rax
mov r9,rax#just to save the fd 
push 0
mov rax,0x901F0002
push rax

mov rsi,rsp
mov rdx,16   #bind(r9, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("0.0.0.0")}, 16)
mov rax,49
syscall
###
mov rdi,r9
mov rsi,0     # listen(r9, 0)
mov rax,50
syscall
###

accept:
mov rsi,0
mov rdi,r9
mov rdx,0
mov rax,43 #accept(r9, NULL, NULL) 
syscall

mov r8,rax    #<- to save the new fd
###
mov rax,57     #fork()
syscall

cmp rax,0
je child
mov rdi, r8           
mov rax, 3                   #checks if child prosses is on and jumps to it or waits for a new accept        
syscall


###
jmp accept 

child:
###
mov rax ,3
mov rdi,r9            #close(r9)
syscall

###                       #         |
mov rdi,r8                #         v this is the buffer idk why it says that from the output :) 
lea rsi,[rip + buffer]    #read(r8, <read_request>, <read_request_count>) = <read_request_result> 
mov rdx,10240             #                           ^ and this is the buffer size ,same thing idk why they called it that 
mov rax,0                 #                           |
syscall
mov r13,rax
###

parse_GP:
lea rsi, [rip + buffer]     
lea rdi, [rip + gp]          #makes a copy of the buffer (i should remove this cuz i only used it for testing)
mov rcx, 10240               
rep movsb  

lea rsi, [rip + post]
lea rdi, [rip + gp]          #compares the first 4 bytes to POST
mov rcx, 4
repe cmpsb
je POST

lea rsi, [rip + get]
lea rdi, [rip + gp]         #compares the first 3 bytes to GET
mov rcx, 3
repe cmpsb     
je GET

mov rdi, r8
lea rsi, [rip + NO]         #fuck you 
mov rdx, leno
mov rax, 1
syscall
jmp exit


###
GET:
lea rdi,[rip + buffer]         #open("file location (with the junk in the http header removed)",READ_ONLY)
add rdi, 5              

# now find the space after the path and null terminate it
mov rcx, rdi
find_space:
cmp byte ptr [rcx], 0x20    # 0x20 = space
je found
inc rcx
jmp find_space

found:
mov byte ptr [rcx], 0 #replace with \0

mov rsi,0
mov rax,2
syscall
###
mov rdi,rax
mov [rip + fd3],rax
lea rsi,[rip + fread]     #read whats in the file the user asked for 
mov rdx,10240
mov rax,0
syscall
mov [rip + len],rax
###
###
mov rdi,[rip + fd3]
mov rax,3      
syscall
###

mov rdi,r8
lea rsi, [rip + toWrite]   #write(r8,"HTTP/1.0 200 OK\r\n\r\n",19)
mov rdx,lenw                  #^ (this is the new fd saved in r8 created by the accept syscall)
mov rax,1
syscall
###
mov rdi,r8
lea rsi, [rip + fread]   #writes what has been read (with the size in mind )
mov rdx,[rip+len]          
mov rax,1
syscall
jmp exit
POST:

lea rdi,[rip + buffer]        
add rdi, 6              

# now find the space after the path and null terminate it
mov rcx, rdi
find_space2:
cmp byte ptr [rcx], 0x20    # 0x20 = space
je found2
inc rcx
jmp find_space2

found2:
mov byte ptr [rcx], 0 #replace with \0

xor r14,r14
xor r12,r12
lea r14,[rip+gp]
extract:
xor ebx,ebx
mov ebx,dword ptr[r14]
cmp ebx,0x0a0d0a0d                # looks for \r\n\r\n in the http request (this pattern is always before the data so after it its just raw data)
je POST_data
add r14,1
add r12,1
jmp extract 


POST_data:
add r14,4
add r12,4

mov rsi,0x41  #O_WONLY | O_CREATE | 
mov rax,2
mov rdx, 0x1ff    #open
syscall

mov rdi,rax
mov rax,1      #write
mov rsi,r14
sub r13,r12
mov rdx,r13
syscall

mov rax,3
syscall

mov rdi,r8
lea rsi, [rip + toWrite]   #write(4,"HTTP/1.0 200 OK\r\n\r\n",19)
mov rdx,lenw                  #^ (this is the new fd saved in r8 created by the accept syscall)
mov rax,1
syscall




######################################### the great wall(GET VS POST HEHE ;)    )
###
exit:
mov rdi,0
mov rax,60    #exit(0)
syscall
###

