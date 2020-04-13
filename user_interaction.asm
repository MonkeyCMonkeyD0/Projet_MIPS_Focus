# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions in this file is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

phrase_nouveau_tour: .asciiz "Au tour du "

phrase_error: .asciiz "La valeur indiquée n'est pas valide, veuillez recommencer."

phrase_choix_action: .asciiz "Que voulez-vous faire (0: bouger une pile / 1: déposer des pièces) ? "

phrase_choix_case_1: .asciiz "Indiquer la coordonnée "
phrase_choix_case_2: .asciiz " de la case de depart (entre 1 et 6 compris) : "

phrase_choix_case_erreur: .asciiz "La case voulu ne vous appartient pas, veuillez en séléctionner une autre."

phrase_choix_direction: .asciiz ") : ", "Indiquer la direction souhaité (" 	# 5 ascii pour la 1er string.
directions: .asciiz "^: 8", "<: 6", ">: 4", "v: 2" 	# 5 ascii par string.

phrase_nb_piece_deplacement: .asciiz ") ? ", "Combien de pièces voulez vous déplacer (entre 1 et " # 5 ascii pour la 1er string.

	.align 2

# ---------------------------------------------------------------------------
# FUNCTIONS SEGMENT
#
# Text segment (function code) for the program.
#
#
#	Rules :
#
# The caller is responsible for saving and restoring any of the following
# caller-saved registers that it cares about.
# 		$t0-$t9			$a0-$a3			$v0-$v1
#
# The callee is responsible for saving and restoring any of the following
# callee-saved registers that it uses. (Remember that $ra is “used” by jal.)
#				$s0-$s7				$ra
#
# Registers $a0–$a3 (4–7) are used to pass the first four arguments to routines
# (remaining arguments are passed on the stack). Registers $v0 and $v1
# (2,3) are used to return values from functions.
# 
# Core of every functions :
#
# 		sub $sp, $sp, 4		# move stack pointer
#		sw $ra, 0($sp)		# save $ra in stack
#
#		lw $ra, 0($sp)		# get $ra from stack
#		add $sp, $sp, 4		# move stack pointer
#		jr $ra 				# go back to caller
#
# ---------------------------------------------------------------------------

	.text

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------

	.globl ask_player_action
ask_player_action: 				# $a0 = num du joueur

	# $v0 = Choix du player : 0 pour move et 1 drop

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	jal print_new_turn

	jal get_nb_piece_to_drop
	beqz $v0, ask_player_action_END_IF
	
	ori $t0, $a0, 0

	ask_player_action_WHILE:
	la $a0, phrase_choix_action
	li $v0, 4
	syscall
	li $v0, 5
	syscall

	li $t1, 1
	ble $v0, $t1, ask_player_action_END_IF

	jal print_new_line
	la $a0, phrase_error
	li $v0, 4
	syscall
	jal print_new_line
	j ask_player_action_WHILE

	ask_player_action_END_IF:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl ask_player_cell_move
ask_player_cell_move:			# $a0 = num du joueur 

	# $v0 = Renvoie la coordonnée x de la case valide selectionnée
	# $v1 = Renvoie la coordonnée y de la case valide selectionnée

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack
	sub $t0, $a0, 1
	
	ask_player_cell_move_WHILE:
	jal print_new_line
	la $a0, phrase_choix_case_1
	li $v0, 4
	syscall
	li $a0, 0x78		# $a0 = "x"
	li $v0, 11
	syscall				# print x
	la $a0, phrase_choix_case_2
	li $v0, 4
	syscall
	li $v0, 5
	syscall				# get x coordinate
	ori $a1, $v0, 0		# save x coord in $a1

	la $a0, phrase_choix_case_1
	li $v0, 4
	syscall
	li $a0, 0x79		# $a0 = "y"
	li $v0, 11
	syscall				# print y
	la $a0, phrase_choix_case_2
	li $v0, 4
	syscall
	li $v0, 5
	syscall				# get y coordinate
	ori $a2, $v0, 0		# save y coord in $a2

	addi $a0, $t0, 1
	jal can_player_move_cell

	beqz $v0, ask_player_cell_move_IF 	# if good cell then skip to ask_player_cell_move_END_IF
	j ask_player_cell_move_END_IF

	ask_player_cell_move_IF:
	jal print_new_line
	la $a0, phrase_choix_case_erreur	# raise error
	li $v0, 4
	syscall
	jal print_new_line
	j ask_player_cell_move_WHILE		# try again

	ask_player_cell_move_END_IF:
	ori $v0, $a1, 0
	ori $v1, $a2, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra


#--------------------#

	.globl ask_player_nb_pieces_move
ask_player_nb_pieces_move:			# $a0 = coord case x, $a1 = coord case y

	# $v0 = Renvoie le nombre de pieces que le joueur actuel veut deplacer

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	jal get_nb_piece_to_move
	ori $a2, $v0, 0		# nb max de pion
	ori $s0, $a0, 0

	ask_player_nb_pieces_move_WHILE:
	jal print_new_line

	la $a0, phrase_nb_piece_deplacement
	addi $a0, $a0, 5	# $a0 = adresse de la seconde ch. de chara	
	li $v0, 4
	syscall

	ori $a0, $a2, 0		# print nb max de pieces
	li $v0, 1
	syscall

	la $a0, phrase_nb_piece_deplacement
	li $v0, 4
	syscall

	li $v0, 5
	syscall

	blez $v0, ask_player_nb_pieces_move_IF

	ble $v0, $a2, ask_player_nb_pieces_move_END_WHILE	# if valeur fourni ok on saute à la fin

	ask_player_nb_pieces_move_IF:
	jal print_new_line									# sinon on affiche une erreur et on recommence
	la $a0, phrase_error
	li $v0, 4
	syscall
	jal print_new_line

	j ask_player_nb_pieces_move_WHILE

	ask_player_nb_pieces_move_END_WHILE:
	ori $a2, $v0, 0
	ori $a0, $s0, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	# TODO
	.globl ask_player_direction_move
ask_player_direction_move:			# $a0 = coord case x, $a1 = coord case y, $a2 = nb pieces

	# $v0 = Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	add $s0, $zero, $a0
	add $s1, $zero, $a1
	add $s2, $zero, $a2
	la $s3, plateau

	ask_player_direction_move_WHILE:
	jal print_new_line
	la $a0, phrase_choix_direction
	addi $a0, $a0, 5
	li $v0, 4
	syscall					# Afficher le debut de la phrase de choix

	li $t0, 1
	ask_player_direction_move_FOR:

	srl $t2, $t0, 1
	beqz $t2, ask_player_direction_move_IF_1
	add $t1, $zero, $s0
	j ask_player_direction_move_END_IF_1
	ask_player_direction_move_IF_1:
	add $t1, $zero, $s1
	ask_player_direction_move_END_IF_1:

	xor $t2, $t0, $t2
	and $t2, $t2, 1
	beqz $t2, ask_player_direction_move_IF_2
	addi $t1, $t1, -1
	j ask_player_direction_move_END_IF_2
	ask_player_direction_move_IF_2:
	li $t3, 6
	sub $t1, $t3, $t1
	ask_player_direction_move_END_IF_2:

	sub $t1, $t1, $s2
	bltz $t1, ask_player_direction_move_IF_3

	jal print_space
	la $a0, directions
	li $t3, 5
	addi $t1, $t0, -1
	mul $t3, $t1, $t3
	add $a0, $a0, $t3
	li $v0, 4
	syscall
	jal print_space

	ask_player_direction_move_IF_3:
	addi $t0, $t0, 1
	li $t3, 4
	ble $t0, $t3, ask_player_direction_move_FOR

	ask_player_direction_move_END_FOR:
	la $a0, phrase_choix_direction
	li $v0, 4
	syscall

	li $v0, 5
	syscall


	#TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	li $v0, 1#---------------------------------------–––– add function test move possible


	bne $v0, $zero, ask_player_direction_move_END_WHILE

	jal print_new_line
	la $a0, phrase_error
	li $v0, 4
	syscall
	jal print_new_line
	j ask_player_direction_move_WHILE

	ask_player_direction_move_END_WHILE:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	# TODO
	.globl ask_player_cell_drop
ask_player_cell_drop:			# $a0 = player num

	# $v0 = coord x case depot
	# $v1 = coord y case depot

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

can_player_move_cell:		# $a0 = num du joueur, $a1 = coord x de la case, $a2 = coord y de la case

	# $v0 = Renvoie 0 le joueur ne peut pas de placer les pieces de cette case ou 1 si il le peut

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	sub $t0, $a1, 1		# recupere la coord x de la case
	sub $t1, $a2, 1		# recupere la coord y de la case
	sll $t1, $t1, 1		# *2
	add $t0, $t0, $t1	# $t0 + 6*$t1 = $t0 + 2*$t1 + 2*2*$t1
	sll $t1, $t1, 1		# *2
	add $t0, $t0, $t1	# $t0 = position de la case
	sll $t0, $t0, 1 	# *2 car on manipule des half

	la $t1, plateau
	add $t1, $t1, $t0 	# recupere l'adresse de la case
	lh $t0, 0($t1)		# recupere le contenu de la case

	can_player_move_cell_WHILE:
	andi $t1, $t0, 3	# recupere les 2 bits de poids faible

	beqz $t1, can_player_move_cell_END_WHILE

	addi $t2, $t1, 0
	srl $t0, $t0, 2
	j can_player_move_cell_WHILE

	can_player_move_cell_END_WHILE:
	li $v0, 1			# if equal : 1 else 0
	beq $a0, $t2, can_player_move_cell_END_IF
	li $v0, 0

	can_player_move_cell_END_IF:	
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra


#--------------------#

print_new_turn: 			# $a0 = num du joueur 

	# Affiche le debut d'un nouveau tout pour le joueur en parametre

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	sub $t0, $a0, 1		# save player num in $t0
	li $t1, 13			# $t1 = nb char to switch noms_joueurs

	jal print_new_line
	la $a0, phrase_nouveau_tour
	li $v0, 4
	syscall

	mult $t0, $t1		# $t0 * 13
	mflo $t0
	la $t1, noms_joueurs
	add $a0, $t0, $t1	# $a0 = adresse player name cell
	syscall

	li $a0, 0x20		# $a0 = " "
	li $v0, 11
	syscall				# print " "

	li $a0, 0x3A		# $a0 = ":"
	li $v0, 11
	syscall				# print ":"

	jal print_new_line

	addi $a0, $t0, 1
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra


#--------------------#

get_nb_piece_to_move:		# $a0 = coord case x, $a1 = coord case y

	# $v0 = nb pieces présent sur la case

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	sub $t0, $a0, 1		# recupere la coord x de la case
	sub $t1, $a1, 1		# recupere la coord y de la case
	sll $t1, $t1, 1		# *2
	add $t0, $t0, $t1	# $t0 + 6*$t1 = $t0 + 2*$t1 + 2*2*$t1
	sll $t1, $t1, 1		# *2
	add $t0, $t0, $t1	# $t0 = position de la case
	sll $t0, $t0, 1 	# *2 car on manipule des half

	la $t1, plateau
	add $t1, $t1, $t0 	# recupere l'adresse de la case
	lh $t0, 0($t1)		# recupere le contenu de la case
	li $t0, 0

	get_nb_piece_to_move_WHILE:
	andi $t1, $t0, 3

	beqz $t1, get_nb_piece_to_move_END_WHILE

	addi $t2, $t2, 1
	srl $t0, $t0, 2
	j get_nb_piece_to_move_WHILE

	get_nb_piece_to_move_END_WHILE:
	addi $v0, $t2, 0
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra


#--------------------#

get_nb_piece_to_drop:		# $a0 = num du joueur

	# $v0 = nb dans la reserve du joueur

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	la $t0, reserve
	add $t0, $t0, $a0
	subi $t0, $t0, 1
	lb $v0, 0($t0)

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

can_player_choose_move:		# $a0 = coord x, $a1 = coord y, $a2 = nb pieces, $a3 = direction

	# $v0 = 1 si deplacement possible, 0 sinon