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

	.globl init_reserve
init_reserve: 				# NULL

	# Met a 0 la reserve de chaque joueur

	sub $sp, $sp, 12	# move stack pointer
	sw $ra, 8($sp)		# save $ra in stack
	sw $a0, 4($sp)		# save $a0 in stack
	sw $a1, 0($sp)		# save $a1 in stack

	li $a0, 0
	li $a1, 0
	jal set_reserve

	lw $ra, 8($sp)		# get $ra from stack
	lw $a0, 4($sp)		# get $a0 from stack
	lw $a1, 0($sp)		# get $a1 from stack
	add $sp, $sp, 12	# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl move_pieces
move_pieces:				# $a0 = num case depart, $a1 = num case arrivé, $a2 = nb pieces, $a3 = num joueur

	# $v0 = le nb de pieces a ajouter à la reserve
	# $v1 = le num du joueur qui gagne les pieces en reserve

	sub $sp, $sp, 8		# move stack pointer
	sw $ra, 4($sp)		# save $ra in stack
	sw $a0, 0($sp)		# save $a0 in stack

	la $t0, plateau
	sll $s0, $a0, 1 	# *2 pour des half
	add $s0, $t0, $s0
	lh $s0, 0($s0)		# case de depart
	ori $a0, $s0, 0
	jal get_nb_pieces_in_cell
	ori $t0, $v0, 0
	sub $t0, $t0, $a2
	sll $t0, $t0, 1 	# *2 pour des pieces de 2 bit
	srlv $s0, $s0, $t0 	# recuperer les pieces a deplacer

	la $t0, plateau
	sll $s1, $a1, 1 	# *2 pour des half
	add $s1, $t0, $s1
	lh $s1, 0($s1)		# case d'arrivé
	ori $a0, $s1, 0
	jal get_nb_pieces_in_cell
	ori $t0, $v0, 0
	sll $t0, $t0, 1		# *2 pour des pieces de 2 bit
	sllv $s0, $s0, $t0 	# deplacer les pieces de la case d'origine
	or $s0, $s0, $s1	# la pile complete

	li $s2, 0
	move_pieces_WHILE:
	ori $a0, $s0, 0
	jal get_nb_pieces_in_cell
	addi $v0, $v0, -5
	blez $v0, move_pieces_END_WHILE

	andi $t0, $s0, 3	# recuperer les 2 derniers bit : la dernière piece
	srl $s0, $s0, 2
	bne $t0, $a3, move_pieces_WHILE

	addi $s2, $s2, 1
	j move_pieces_WHILE
	move_pieces_END_WHILE:

	la $t0, plateau
	sll $s1, $a1, 1 	# *2 pour des half
	add $s1, $t0, $s1
	sh $s0, 0($s1)		# stocker la nouvelle pile dans la case d'arrivé

	lw $a0, 0($sp)
	add $t0, $t0, $a0
	add $t0, $t0, $a0 	# *2 car les cases sont des halfs
	lh $s0, 0($t0)
	ori $a0, $s0, 0
	jal get_nb_pieces_in_cell
	ori $t0, $v0, 0
	sub $t0, $t0, $a2
	sll $t0, $t0, 1 	# *2
	li $t1, 1
	sllv $t0, $t1, $t0
	addi $t0, $t0, -1
	and $s0, $s0, $t0 	# recuperer que les n dernières pieces de la case

	la $t0, plateau
	lw $a0, 0($sp)
	add $t0, $t0, $a0
	add $t0, $t0, $a0 	# *2 car les cases sont des halfs
	sh $s0, 0($t0)		# stocker la nouvelle pile dans la case de depart

	ori $v0, $s2, 0
	ori $v1, $a3, 0

	lw $ra, 4($sp)		# get $ra from stack
	lw $a0, 0($sp)		# get $a0 from stack
	add $sp, $sp, 8		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	# TODO
	.globl drop_pieces
drop_pieces:				# $a0 = coord x case depot, $a1 = coord y case depot, $a2 = nb pieces, $a3 = num joueur

	# $v0 = le nb de pieces a retirer de la reserve
	# $v1 = le num du joueur


#--------------------#

	.globl test_victory
test_victory: 				# NULL

	# $v0 = 0 si personne n'a gagné, 1 si victoire du j1, 2 si victoire du j2

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	li $a0, 1
	jal can_move_piece
	ori $s0, $v0, 0
	jal get_nb_piece_to_drop
	or $s0, $s0, $v0
	beqz $s0, test_victory_IF_1		# test si j1 a perdu

	li $a0, 2
	jal can_move_piece
	ori $s0, $v0, 0
	jal get_nb_piece_to_drop
	or $s0, $s0, $v0
	beqz $s0, test_victory_IF_2		# test si j2 a perdu

	li $v0, 0						# si personne n'a perdu alors $v0 = 0
	j test_victory_IF_END

	test_victory_IF_1:				# si j1 a perdu alors victoire de j2
	li $v0, 2
	j test_victory_IF_END

	test_victory_IF_2:				# # si j2 a perdu alors victoire de j1
	li $v0, 1
	j test_victory_IF_END

	test_victory_IF_END:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

	.globl can_move_piece
can_move_piece: 			# a0 = num joueur

	# $v0 = 0 le joueur ne peut plus deplacer de pieces, 1 sinon

	sub $sp, $sp, 16	# move stack pointer
	sw $ra, 12($sp)		# save $ra in stack
	sw $s0, 8($sp)		# save $s0 in stack
	sw $s1, 4($sp)		# save $s1 in stack
	sw $s2, 0($sp)		# save $s2 in stack

	li $s0, 0	# test value
	li $s1, 0	# counter
	li $s2, 36	# max value for counter

	can_move_piece_FOR:
	li $t0, 6
	div $s1, $t0
	mflo $a1
	mfhi $a2
	jal player_posses_cell
	or $s0, $s0, $v0 		# test si possede la case sans ecraser les resultats precedants

	bnez $s0, can_move_piece_IF		# quitter la boucle si on trouver une case qui correspond
	addi $s1, $s1, 1
	blt $s1, $s2, can_move_piece_FOR		# si num case < 36 => reboucle

	can_move_piece_IF:
	ori $v0, $s0, 0

	lw $ra, 12($sp)		# get $ra from stack
	lw $s0, 8($sp)		# get $s0 from stack
	lw $s1, 4($sp)		# get $s1 from stack
	lw $s2, 0($sp)		# get $s2 from stack
	add $sp, $sp, 16	# move stack pointer
	jr $ra 				# go back to caller


#--------------------#
	
	.globl player_posses_cell
player_posses_cell:			# $a0 = num du joueur, $a1 = coord x de la case, $a2 = coord y de la case

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


#--------------------#

	.globl get_nb_piece_to_drop
get_nb_piece_to_drop:		# $a0 = num du joueur

	# $v0 = nb pieces dans la reserve du joueur

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
	# TODO
	.globl change_reserve_player
change_reserve_player: 				# a0 = num player, a1 = nb pieces difference

	# Met a jour la reserve du joueur

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack	



	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

set_reserve: 				# a0 = reserve de j1, a1 = reserve de j2

	# Met a jour la reserve de chaque joueur

	la $t0, reserve
	sb $a0, 0($t0)
	sb $a1, 1($t0)

	jr $ra 				# go back to caller


#--------------------#

get_reserve: 				# NULL

	# $v0 = reserve de j1
	# $v1 = reserve de j2

	la $t0, reserve
	lb $v0, 0($t0)
	lb $v1, 1($t0)

	jr $ra 				# go back to caller


#--------------------#

get_deposit_cell:			# $a0 = coord x depart, $ a1 = coord y depart, $a2 = nb pieces, $a3 = direction

	# $v0 = coord x de depot
	# $v1 = coord y de depot

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	srl $t1, $a3, 1
	beqz $t1, get_deposit_cell_IF_1
	ori $t0, $a0, 0
	j get_deposit_cell_END_IF_1
	get_deposit_cell_IF_1:
	ori $t0, $a1, 0
	get_deposit_cell_END_IF_1:

	xor $t1, $a3, $t1
	and $t1, $t1, 1
	beqz $t1, get_deposit_cell_IF_2
	sub $t0, $t0, $a2
	j get_deposit_cell_END_IF_2
	get_deposit_cell_IF_2:
	add $t0, $t0, $a2
	get_deposit_cell_END_IF_2:

	srl $t1, $a3, 1
	beqz $t1, get_deposit_cell_IF_3
	ori $v0, $t0, 0
	ori $v1, $a1, 0
	j get_deposit_cell_END_IF_3
	get_deposit_cell_IF_3:
	ori $v0, $a0, 0
	ori $v1, $t0, 0
	get_deposit_cell_END_IF_3:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller


#--------------------#

get_nb_pieces_in_cell:		# $a0 = case

	# $v0 = nb pieces

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	ori $t0, $a0, 0
	li $v0, 0

	get_nb_pieces_in_cell_WHILE:
	beqz $t0, get_nb_pieces_in_cell_END_WHILE

	addi $v0, $v0, 1
	srl $t0, $t0, 2
	j get_nb_pieces_in_cell_WHILE

	get_nb_pieces_in_cell_END_WHILE:

	lw $ra, 0($sp)		# get $ra from stack
	add $sp, $sp, 4		# move stack pointer
	jr $ra 				# go back to caller




























































































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure,
# je suis trop centent de la connaitre, c'est trop cool, Kenza est cool,
# MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure,
# elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore !
# Je suis Tristqn et je suis nul, aller hop c'est cadeau
