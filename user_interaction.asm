# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

phrase_choix_case_1: .asciiz "Indiquer la coordonnée "
phrase_choix_case_2: .asciiz " de la case de depart pour le "
phrase_choix_case_3: .asciiz " : "
# coord_x_y: .asciiz "x", "y"

phrase_choix_direction_1: .asciiz "Indiquer la direction souhaité ("
phrase_choix_direction_2: .asciiz ") : "
directions: .asciiz "^ (8)", "> (4)", "< (6)", "v (2)"

phrase_nb_piece_deplacement: .asciiz "Combien de pieces voulez vous déplacer ? "


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
# ---------------------------------------------------------------------------

	.align 2
	.text

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------

	.globl ask_player_cell
ask_player_cell:			# $a0 = num du joueur 

	# $v0 = Renvoie la coordonnée x de la case valide selectionnée
	# $v1 = Renvoie la coordonnée y de la case valide selectionnée

	jr $ra


#--------------------#

	.globl ask_player_nb_pieces
ask_player_nb_pieces:			# $a0 = coord case x, $a1 = coord case y

	# $v0 = Renvoie 0 si le joueur pose des pieces ou 1 si il en deplace
	# $v1 = Renvoie le nombre de pieces que le joueur actuel veut deplacer ou alors poser

	jr $ra


#--------------------#

	.globl ask_player_direction
ask_player_direction:			# $a0 = coord case x, $a1 = coord case y, $a2 = nb pieces

	# $v0 = Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	jr $ra


#--------------------#




# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

	.globl can_player_move_cell
can_player_move_cell:		# $a0 = num du joueur, $a1 = coord x de la case, $a2 = coord y de la case

	# $v0 = Renvoie 0 le joueur ne peut pas de placer les pieces de cette case ou 1 si il le peut

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack
	li $t3, 3

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
	div $t0, $t3
	mfhi $t1

	beqz $t1,can_player_move_cell_END_WHILE

	addi $t2, $t1, 0
	srl $t0, $t0, 2
	j can_player_move_cell_WHILE

	can_player_move_cell_END_WHILE:
	li $v0, 1			# if non eq 0 else 1
	beq $a0, $t2, can_player_move_cell_END_IF
	li $v0, 0

	can_player_move_cell_END_IF:	
	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra


#--------------------#


