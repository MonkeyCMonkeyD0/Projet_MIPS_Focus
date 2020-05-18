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
phrase_choix_case_2: .asciiz " de la case voulu (entre 1 et 6 compris) : "

phrase_choix_case_erreur: .asciiz "La case voulu ne peut être sélectionnée, veuillez en sélectionner une autre."

phrase_choix_direction: .asciiz ") : ", "Indiquer la direction souhaité (" 	# 5 ascii pour la 1er string.
directions: .asciiz "^: 8", "<: 6", ">: 4", "v: 2" 	# 5 ascii par string.

phrase_nb_piece_deplacement: .asciiz ") ? ", "Combien de pièces voulez vous déplacer (entre 1 et " # 5 ascii pour la 1er string.

phrase_nb_piece_depot: .asciiz ") ? ", "Combien de pièces voulez vous déposer (entre 1 et " # 5 ascii pour la 1er string.

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

	# $v0 = Choix du player : 0 pour move et 1 pour drop(de la reserve)

	sub $sp, $sp, 8		# move stack pointer
	sw $ra, 4($sp)		# save $ra in stack
	sw $a0, 0($sp)

	jal print_new_turn

	lw $a0, 0($sp)
	jal get_nb_piece_to_drop 		# Pour voir s'il a des pièces en réserve
	beqz $v0, ask_player_action_IF 	# Si pas de pièces, pas de choix

	jal can_move_piece				# Pour voir s'il a des pièces à déplacer
	addi $v0, $v0, 1				# switch 0 and 1
	andi $v0, $v0, 1
	bnez $v0, ask_player_action_IF 	# Si pas de move, pas de choix

	ask_player_action_WHILE:
	jal print_new_line
	la $a0, phrase_choix_action
	li $v0, 4
	syscall
	li $v0, 5
	syscall

	li $t1, 1
	ble $v0, $t1, ask_player_action_IF

	jal print_new_line
	la $a0, phrase_error
	li $v0, 4
	syscall
	j ask_player_action_WHILE

	ask_player_action_IF:

	lw $ra, 4($sp)		# get $ra from stack
	add $sp, $sp, 8		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl ask_player_cell_move
ask_player_cell_move:			# $a0 = num du joueur 

	# $v0 = Renvoie la coordonnée x de la case valide selectionnée
	# $v1 = Renvoie la coordonnée y de la case valide selectionnée

	sub $sp, $sp, 8		# move stack pointer
	sw $ra, 4($sp)		# save $ra in stack
	sw $a0, 0($sp)		# save $a0 in stack
	
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

	slti $t2, $a1, 7
	slt $t1, $zero, $a1
	and $t2, $t2, $t1

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

	slti $t1, $a2, 7
	and $t2, $t2, $t1
	slt $t1, $zero, $a2
	and $t2, $t2, $t1
	beqz $t2, ask_player_cell_move_IF 	# if cell does not exist skip to ask_player_cell_move_IF

	lw $a0, 0($sp)
	jal player_posses_cell

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

	lw $ra, 4($sp)		# get $ra from stack
	add $sp, $sp, 8		# move stack pointer
	jr $ra


#--------------------#

	.globl ask_player_nb_pieces_move
ask_player_nb_pieces_move:		# $a0 = coord case x, $a1 = coord case y

	# $v0 = Renvoie le nombre de pieces que le joueur actuel veut deplacer

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	jal get_nb_piece_to_move
	ori $a2, $v0, 0		# nb max de pion
	ori $t0, $a0, 0

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
	ori $a0, $t0, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl ask_player_direction_move
ask_player_direction_move:		# $a0 = coord case x, $a1 = coord case y, $a2 = nb pieces

	# $v0 = Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	add $t4, $zero, $a0

	ask_player_direction_move_WHILE:
	jal print_new_line
	la $a0, phrase_choix_direction
	addi $a0, $a0, 5
	li $v0, 4
	syscall					# Afficher le debut de la phrase de choix

	li $t0, 1
	ask_player_direction_move_FOR:

	srl $t2, $t0, 1
	andi $t2, $t2, 1
	beqz $t2, ask_player_direction_move_IF_1
	add $t1, $zero, $t4
	j ask_player_direction_move_END_IF_1
	ask_player_direction_move_IF_1:
	add $t1, $zero, $a1
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

	sub $t1, $t1, $a2
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

	li $v0, 5		# Choix de l'utilisateur
	syscall

	andi $t0, $v0, 1		# test pour valeurs impair
	bnez $t0, ask_player_direction_move_IF_4

	srl $a3, $v0, 1 			# /2
	li $t0, 5
	sub $a3, $t0, $a3 			# $a3 = 5-x/2 : fonction qui attribut la bonne direction a l'entre de l'utilisateur
	add $a0, $zero, $t4
	jal can_player_choose_move

	bne $v0, $zero, ask_player_direction_move_END_WHILE

	ask_player_direction_move_IF_4:
	jal print_new_line
	la $a0, phrase_error
	li $v0, 4
	syscall
	jal print_new_line
	j ask_player_direction_move_WHILE

	ask_player_direction_move_END_WHILE:

	ori $v0, $a3, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl ask_player_cell_drop
ask_player_cell_drop:			# NULL

	# $v0 = coord x case depot
	# $v1 = coord y case depot

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	ask_player_cell_drop_WHILE:
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
	ori $t2, $v0, 0		# save x coord in $t2
	
	slti $t0, $t2, 7
	slt $t1, $zero, $t2
	and $t0, $t0, $t1
	
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
	ori $v1, $v0, 0		# save y coord in $v1

	slti $t1, $v1, 7
	and $t0, $t0, $t1
	slt $t1, $zero, $v1
	and $t0, $t0, $t1

	beqz $t0, ask_player_cell_drop_IF 	# if good cell then skip to ask_player_cell_drop_END_IF
	j ask_player_cell_drop_END_IF

	ask_player_cell_drop_IF:
	jal print_new_line
	la $a0, phrase_choix_case_erreur	# raise error
	li $v0, 4
	syscall
	jal print_new_line
	j ask_player_cell_drop_WHILE		# try again

	ask_player_cell_drop_END_IF:
	ori $v0, $t2, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl ask_player_nb_pieces_drop
ask_player_nb_pieces_drop:		# $a0 = num joueur

	# $v0 = nb pieces

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack	

	jal get_nb_piece_to_drop
	ori $s0, $v0, 0		# nb de pion en reserve
	li $t0, 5
	ble $s0, $t0, ask_player_nb_pieces_drop_IF_1
	ori $s0, $t0, 0		# min(reserver,5)
	ask_player_nb_pieces_drop_IF_1:
	ori $s1, $a0, 0

	ask_player_nb_pieces_drop_WHILE:
	jal print_new_line

	la $a0, phrase_nb_piece_depot
	addi $a0, $a0, 5	# $a0 = adresse de la seconde ch. de chara	
	li $v0, 4
	syscall

	ori $a0, $s0, 0		# print nb max de pieces
	li $v0, 1
	syscall

	la $a0, phrase_nb_piece_deplacement
	li $v0, 4
	syscall

	li $v0, 5
	syscall

	blez $v0, ask_player_nb_pieces_drop_IF_2

	ble $v0, $s0, ask_player_nb_pieces_drop_END_WHILE	# if valeur fourni ok on saute à la fin

	ask_player_nb_pieces_drop_IF_2:
	jal print_new_line									# sinon on affiche une erreur et on recommence
	la $a0, phrase_error
	li $v0, 4
	syscall
	jal print_new_line

	j ask_player_nb_pieces_drop_WHILE

	ask_player_nb_pieces_drop_END_WHILE:
	ori $a0, $s1, 0

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

print_new_turn: 				# $a0 = num du joueur 

	# Affiche le debut d'un nouveau tour pour le joueur en parametre

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
	syscall				# print ":"

	jal print_new_line

	addi $a0, $t0, 1
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra


#--------------------#

get_nb_piece_to_move:			# $a0 = coord case x, $a1 = coord case y

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
	li $t2, 0

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

can_player_choose_move:			# $a0 = coord x, $a1 = coord y, $a2 = nb pieces, $a3 = direction

	# $v0 = 1 si deplacement possible, 0 sinon

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	srl $t1, $a3, 1
	andi $t1, $t1, 1
	beqz $t1, can_player_choose_move_IF_1
	add $t0, $zero, $a0
	j can_player_choose_move_END_IF_1
	can_player_choose_move_IF_1:
	add $t0, $zero, $a1
	can_player_choose_move_END_IF_1:

	xor $t1, $a3, $t1
	andi $t1, $t1, 1
	beqz $t1, can_player_choose_move_IF_2
	addi $t0, $t0, -1
	j can_player_choose_move_END_IF_2
	can_player_choose_move_IF_2:
	li $t3, 6
	sub $t0, $t3, $t0
	can_player_choose_move_END_IF_2:

	sub $t0, $t0, $a2
	li $v0, 0
	bltz $t0, can_player_choose_move_IF_3

	li $v0, 1
	can_player_choose_move_IF_3:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller

