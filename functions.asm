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
# 	$t0-$t9		$a0-$a3		$v0-$v1
#
# The callee is responsible for saving and restoring any of the following
# callee-saved registers that it uses. (Remember that $ra is “used” by jal.)
#	$s0-$s7		$ra
#
# Registers $a0–$a3 (4–7) are used to pass the first four arguments to routines
# (remaining arguments are passed on the stack). Registers $v0 and $v1
# (2,3) are used to return values from functions.
#
# ---------------------------------------------------------------------------

	.text
	.align 2

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------


	.globl init_plateau
init_plateau: 			# NULL	

	# Remplir le plateau de pieces pour le début de partie

	la $t0, plateau
	li $t1, 0 	# indice deplacement dans plateau
	li $t4, 4
	li $t5, 36 	# nb cases plateau
init_plateau_FOR:
	sll $t2, $t1, 1 	# *2 pour half
	add $t2, $t2, $t0 	# adresse de la nouvelle case
	div $t1, $t4 	# indice mod 4
	mfhi $t3
	srl $t3, $t3, 1		# /2
	addi $t3, $t3, 1	# +1
	sh $t3, 0($t2)
	addi $t1, $t1, 1 	# +1 indice
	blt $t1, $t5, init_plateau_FOR		# si num case < 36 => reboucle
init_plateau_END_FOR:
	jr $ra

#--------------------#


	.globl print_game_state
print_game_state:		# NULL

	# Affiche l'etat complet du jeu

	jr $ra

#--------------------#


	.globl ask_player_cell
ask_player_cell:		# num du joueur 

	# Renvoie la coordonnée x de la case valide selectionnée
	# Renvoie la coordonnée y de la case valide selectionnée

	jr $ra

#--------------------#


	.globl ask_player_nb_pieces
ask_player_nb_pieces:	# coord case x, coord case y

	# Renvoie 0 si le joueur pose des pieces ou 1 si il en deplace
	# Renvoie le nombre de pieces que le joueur actuel veut deplacer ou alors poser

	jr $ra

#--------------------#


	.globl ask_player_direction
ask_player_direction:	# coord case x, coord case y, nb pieces

	# Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	jr $ra

#--------------------#


	.globl move_pieces
move_piece:				# coord x-y depart, coord x-y arrivé, nb pieces

	# Deplace la piece dans le plateau memoire

	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------


print_new_line:			# NULL

	# Affiche un saut de ligne dans la console

	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra

#--------------------#


print_plateau:			# NULL

	# Affiche le plateau de jeu avec les pieces qu'il contient ainsi que la reserve

	jr $ra







































































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
