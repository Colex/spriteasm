##################################
##         SpriteAsm        ##
##  Developed by Alex Santos    ##
##      (Colex)       ##
##################################

  .data
READ_FLAG:
  .asciz "rb"
WRITE_FLAG:
  .asciz "wb"
SPRITES_DIR:
  .asciz "Sprites"
SPRITES_FILE:
  .asciz "Tibia.spr"
EMPTY_FILE:
  .asciz "%d.bmp"
PREVIOUS_DIR:
  .asciz "cd .."
BITMAP_HEADER_INFO:
  .long 0x4D42, 150, 0, 54, 40, 32, 32, 1, 24, 0, 96, 2835, 2835, 0
BITMAP_HEADER_SIZE:
  .long 2, 4, 4, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 8, 0
START_STRING:
  .asciz "SpriteAsm (Developed by Alex Santos)\n\n-- Started Extracting... "
END_STRING:
  .asciz "[Done]\n\nEnded Extraction\n"

.globl _main


##################################
##         WRITE_BYTES        ##
##################################
_write_bytes: #paramaters: file pointer, value, size
  #Epilogue
  pushl %ebp
  movl  %esp, %ebp
  #########

  pushl 8(%ebp)
  pushl   $1
  pushl 16(%ebp)
  leal  12(%ebp), %eax
  pushl %eax
  call  _fwrite
  addl  $16, %esp

  #Prologue
  leave
  ret
##################################





##################################
##    CREATE_EMPTY_SPRITE   ##
##################################
_create_empty_sprite: #parameter: sprite number
  #Epilogue
  pushl %ebp
  movl  %esp, %ebp
  pushl %ebx
  pushl %esi
  pushl %edi
  subl  $255, %esp
  ########


  leal  -255(%ebp), %eax

  #Generate the sprite name
  pushl 8(%ebp)
  pushl $EMPTY_FILE
  pushl %eax
  call  _sprintf
  addl  $12, %esp


  #Open the file in write mode
  pushl $WRITE_FLAG
  leal  -255(%ebp), %eax
  pushl %eax
  call  _fopen
  addl  $8, %esp
  movl  %eax, %ebx

  #Write the BMP header
  leal  BITMAP_HEADER_SIZE, %esi
  leal  BITMAP_HEADER_INFO, %edi
  write_header:
  movl  (%esi), %eax
  cmp   %eax, 0
  je    write_header_end
  pushl %eax
  pushl (%edi)
  pushl %ebx
  call  _write_bytes
  addl  $12, %esp
  addl  $4, %edi
  addl  $4, %esi
  jmp   write_header
  write_header_end:

  #Fill the sprite with transparent color
  movl  $0, %esi
  pushl $3
  pushl $0xFF00FF
  pushl %ebx
  write_pixels:
  call  _write_bytes
  addl  $1, %esi
  cmp   $1024, %esi
  jne   write_pixels
  addl  $12, %esp

  pushl $2
  pushl $-96
  pushl %ebx
  call  _fseek
  #addl $12, %esp

  #Return the file pointer (through %eax)
  movl  %ebx, %eax


  #Prologue
  movl  %ebp, %esp
  subl  $12, %esp
  popl  %edi
  popl  %esi
  popl  %ebx
  leave
  ret
##################################




##################################
##       READ_SPRITES       ##
##################################
_read_sprites:  #parameter: file pointer
  #Epilogue
  pushl %ebp
  movl  %esp, %ebp
  subl  $32, %esp
  pushl %edi
  pushl %esi
  pushl %ebx
  #########

  #Ignore header informations (except the sprites count)
  pushl $0
  pushl $4
  pushl 8(%ebp)
  call  _fseek
  addl  $12, %esp


  #Read how many sprites are in the file
  pushl 8(%ebp)
  pushl $1
  pushl   $2
  leal  -4(%ebp), %eax
  pushl %eax
  call  _fread
  addl  $16, %esp
  movl  -4(%ebp), %edi


  #Read all the sprites to a file
  movl  $1, -32(%ebp)
  read_sprite:
    pushl -32(%ebp)
    call  _create_empty_sprite
    addl  $4, %esp
    movl  %eax, %ebx

    #pushl  %esi
    #pushl  $TEST_STRING1
    #call _printf

    #Read the next sprite's pointer
    movl  -32(%ebp), %eax
    imull $4, %eax
    addl  $6, %eax

    pushl $0
    pushl %eax
    pushl 8(%ebp)
    call  _fseek
    addl  $12, %esp

    pushl 8(%ebp)
    pushl $1
    pushl   $4
    leal  -4(%ebp), %eax
    pushl %eax
    call  _fread
    addl  $16, %esp

    movl  -4(%ebp), %eax
    addl  $3, %eax
    pushl $0
    pushl %eax
    pushl 8(%ebp)
    call  _fseek
    addl  $12, %esp


    #Read the sprites size (number of bytes)
    pushl 8(%ebp)
    pushl $1
    pushl   $2
    leal  -8(%ebp), %eax
    pushl %eax
    call  _fread
    addl  $16, %esp

    #Read the pixels
    subl  %esi, %esi
    read_pixels:

      movl  -8(%ebp), %eax
      cmp   %eax, 0
      je    close_sprite



      #Read the number of transparent pixels
      pushl 8(%ebp)
      pushl $1
      pushl   $2
      leal  -12(%ebp), %eax
      pushl %eax
      call  _fread
      addl  $16, %esp

      #Ignore the transparent pixels
      movl  -12(%ebp), %eax
      addl  %eax, %esi
      imull $3, %eax
      pushl $1
      pushl %eax
      pushl %ebx
      call  _fseek
      addl  $12, %esp

      #Read the number of colored pixels
      pushl 8(%ebp)
      pushl $1
      pushl   $2
      leal  -16(%ebp), %eax
      pushl %eax
      call  _fread
      addl  $16, %esp


      movl  -8(%ebp), %eax
      subl  $4, %eax
      movl  %eax, -8(%ebp)

      ######################################################
      #Bitmap "mirror's" the image, so we need to calculate#
      #the original position of the pixel          #
      #######  y = (32 - (P / 32)) * 96  ###################
      calculate_pos:
      movl  %esi, %eax
      subl  %edx, %edx
      movl  $32, %ecx
      idiv  %ecx
      addl  $1, %eax
      subl  %eax, %ecx
      imull $96, %ecx
      movl  %ecx, -4(%ebp)

      #######  x = (P % 32) * 3  #######
      movl  %esi, %eax
      subl  %edx, %edx
      movl  $32, %ecx
      idiv  %ecx
      imull $3, %edx

      #######  pos = x + y + 54  #######
      addl  %edx, -4(%ebp)
      addl  $54, -4(%ebp)

      pushl $0
      pushl -4(%ebp)
      pushl %ebx
      call  _fseek
      addl  $12, %esp
      ################################### ###################


      #Write the colored pixels to the file
      write_colored_pixels:
        movl  -16(%ebp), %eax
        cmp   %eax, 0
        je    read_pixels


        #Read RGB bytes
        read_rgb:
        pushl 8(%ebp)
        pushl $1
        pushl   $1
        leal  -20(%ebp), %eax
        pushl %eax
        call  _fread
        addl  $4, %esp
        leal  -24(%ebp), %eax
        pushl %eax
        call  _fread
        addl  $4, %esp
        leal  -28(%ebp), %eax
        pushl %eax
        call  _fread
        addl  $16, %esp
        #Write RGB bytes to the file
        pushl $1
        pushl -28(%ebp)
        pushl %ebx
        call  _write_bytes
        addl  $8, %esp
        pushl -24(%ebp)
        pushl %ebx
        call  _write_bytes
        addl  $8, %esp
        pushl -20(%ebp)
        pushl %ebx
        call  _write_bytes
        addl  $12, %esp

        addl  $1, %esi

        movl  -8(%ebp), %eax
        subl  $3, %eax
        movl  %eax, -8(%ebp)

        movl  -16(%ebp), %eax
        subl  $1, %eax
        movl  %eax, -16(%ebp)

        #Verify if needs to recalculate the position
        movl  %esi, %eax
        subl  %edx, %edx
        movl  $32, %ecx
        idiv  %ecx
        cmp   %edx, 0
        je    calculate_pos

        jmp   write_colored_pixels


    #Close the sprite's file
    close_sprite:
    pushl %ebx
    call  _fclose
    addl  $4, %esp

    addl  $1, -32(%ebp)
    cmp   -32(%ebp), %edi
    jne   read_sprite


  #Prologue
  movl  %ebp, %esp
  subl  $12, %esp
  popl  %ebx
  popl  %esi
  popl  %edi
  leave
  ret
##################################



##############################
##      MAIN      ##
##############################
_main:
  #Epilogue
  pushl   %ebp
  movl  %esp, %ebp
  #########

  pushl $START_STRING
  call  _printf

  #Open the Tibia.Spr
  pushl   $READ_FLAG
  pushl $SPRITES_FILE
  call  _fopen
  #Exit if couldn't open the Tibia.spr
  cmp   %eax, 0
  je    prologue
  mov   %eax, %ebx


  #Create the Sprites directory
  pushl   $SPRITES_DIR
  call  _chdir
  #If it already exists, don't create
  cmp   %eax, 0
  je    do_no_create
  call  _mkdir
  call  _chdir
  do_no_create:

  pushl %ebx
  call  _read_sprites

  #Close the Tibia.spr
  pushl %ebx
  call  _fclose

  pushl $END_STRING
  call  _printf

  pushl $PREVIOUS_DIR
  call  _system

  #Prologue
  prologue:
  leave
  ret
##################################
