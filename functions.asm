# ---------------------------------------------------------------------------
# GLOBAL DATA SEGMENT
#
# Globally used data by functions is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

	.globl plateau
plateau: .space 72		# stockage : un half pour une case soit 16 bits pour 5 pions => pion sur 2 bit [01] 1 (+) / [10] 2 (*) / [00] vide
	.globl reserve
reserve: .byte 0, 0

	.globl noms_joueurs
noms_joueurs: .asciiz "joueur 1 (+)", "joueur 2 (*)" 	# 13 char

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

	.globl init_plateau
init_plateau: 				# NULL	

	# Remplir le plateau de pieces pour le début de partie

	la $t0, plateau
	li $t1, 0 	# indice deplacement dans plateau
	li $t4, 36 	# nb cases plateau

	init_plateau_FOR:
	sll $t2, $t1, 1 	# *2 pour half
	add $t2, $t2, $t0 	# adresse de la nouvelle case

	andi $t3, $t1, 3	# indice mod 4
	srl $t3, $t3, 1		# /2
	addi $t3, $t3, 1	# +1
	sh $t3, 0($t2)

	addi $t1, $t1, 1 	# +1 indice
	blt $t1, $t4, init_plateau_FOR		# si num case < 36 => reboucle
	init_plateau_END_FOR:
	jr $ra


#--------------------#

	# TODO
	.globl move_pieces
move_pieces:				# $a0 = num case depart, $a1 = num case arrivé, $a2 = nb pieces
							# $a0 = coord x depart, $ a1 = coord y depart, $a2 = coord x arrivé, $a3 = coord y arrivé, nb pieces

	# Met a jour la memoire pour representer le deplacement des pieces

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	# TODO
	.globl test_victory
test_victory: 				# NULL

	# $v0 = 0 si personne n'a gagne, 1 si victoire du j1, 2 si victoire du j2

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	# TODO
	.globl test_can_move
test_can_move: 				# a0 = num joueur

	# $v0 = 0 le joueur ne peut plus deplacer de pieces, 1 sinon

	sub $sp, $sp, 16	# move stack pointer
	sw $ra, 12($sp)		# save $ra in stack
	sw $s0, 8($sp)		# save $s0 in stack
	sw $s1, 4($sp)		# save $s1 in stack
	sw $s2, 0($sp)		# save $s2 in stack

	li $s0, 0	# test value
	li $s1, 0	# counter
	li $s2, 36	# max value for counter

	test_can_move_FOR:
	li $t0, 6
	div $s1, $t0
	mflo $a1
	mfhi $a2
	jal player_posses_cell
	or $s0, $s0, $v0 		# test si possede la case sans ecraser les resultats precedants

	bnez $s0, test_can_move_IF		# quitter la boucle si on trouver une case qui correspond
	addi $s1, $s1, 1
	blt $s1, $s2, test_can_move_FOR		# si num case < 36 => reboucle

	test_can_move_IF:
	ori $v0, $s0, 0

	lw $ra, 12($sp)		# get $ra from stack
	lw $s0, 8($sp)		# get $s0 from stack
	lw $s1, 4($sp)		# get $s1 from stack
	lw $s2, 0($sp)		# get $s2 from stack
	add $sp, $sp, 16	# move stack pointer
	jr $ra 				# go back to caller


#--------------------#
	
	.globl player_posses_cell
player_posses_cell:		# $a0 = num du joueur, $a1 = coord x de la case, $a2 = coord y de la case

	# $v0 = Renvoie 0 le joueur ne peut pas deplacer les pieces de cette case ou 1 si il le peut

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

	player_posses_cell_WHILE:
	andi $t1, $t0, 3	# recupere les 2 bits de poids faible

	beqz $t1, player_posses_cell_END_WHILE

	ori $t2, $t1, 0
	srl $t0, $t0, 2
	j player_posses_cell_WHILE

	player_posses_cell_END_WHILE:
	li $v0, 1			# if equal : 1 else 0
	beq $a0, $t2, player_posses_cell_END_IF
	li $v0, 0

	player_posses_cell_END_IF:	
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------



#--------------------#





























































































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
