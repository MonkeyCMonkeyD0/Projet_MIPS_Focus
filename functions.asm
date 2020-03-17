# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions is declared in this data segment.
# ---------------------------------------------------------------------------
	.data
	.align 0

noms_joueurs: .asciiz "joueur 1 (+)", "joueur 2 (*)"

phrase_choix_case_1: .asciiz "Indiquer la coordonnée "
phrase_choix_case_2: .asciiz " de la case de depart pour le "
phrase_choix_case_3: .asciiz " : "
coord_x_y: .asciiz "x", "y"

phrase_choix_direction_1: .asciiz "Indiquer la direction souhaité ("
phrase_choix_direction_2: .asciiz ") : "
directions: .asciiz "^ (8)", "> (4)", "< (6)", "v (2)"

phrase_nb_piece_deplacement: .asciiz "Combien de pieces voulez vous déplacer ? "

phrase_victoire_1: .asciiz "Felicitation au "
phrase_victoire_2: .asciiz " qui a gagné !"

affichage_case: .asciiz  "   ", "[+]", "[*]", "-->", "<--"	# 4 char ascii par string : 4 octets pour décallage
affichage_grille: .asciiz "+------------------+------------------+------------------+------------------+------------------+------------------+"	# 2 ascii : 2 octets décallage

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

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------


	.globl init_plateau
init_plateau: 				# NULL	

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
print_game_state:			# NULL

	# Affiche l'etat complet du jeu

	jr $ra

#--------------------#


	.globl ask_player_cell
ask_player_cell:			# num du joueur 

	# Renvoie la coordonnée x de la case valide selectionnée
	# Renvoie la coordonnée y de la case valide selectionnée

	jr $ra

#--------------------#


	.globl ask_player_nb_pieces
ask_player_nb_pieces:			# coord case x, coord case y

	# Renvoie 0 si le joueur pose des pieces ou 1 si il en deplace
	# Renvoie le nombre de pieces que le joueur actuel veut deplacer ou alors poser

	jr $ra

#--------------------#


	.globl ask_player_direction
ask_player_direction:			# coord case x, coord case y, nb pieces

	# Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	jr $ra

#--------------------#


	.globl move_pieces
move_pieces:				# coord x-y depart, coord x-y arrivé, nb pieces

	# Met a jour la memoire pour representer le deplacement des pieces

	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------


print_new_line:				# NULL

	# Affiche un saut de ligne dans la console

	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra

#--------------------#


print_pipe:				# NULL

	# Affiche une pipe (|) dans la console

	li $a0, '|'
	li $v0, 11
	syscall
	jr $ra

#--------------------#

	.globl print_plateau
print_plateau:				# NULL

	# Affiche le plateau de jeu avec les pieces qu'il contient ainsi que la reserve

	la $a1, plateau
	la $a2, affichage_grille
	la $a3, affichage_case
	li $t0, 0	# Indice pour parcourir les lignes
	li $t1, 36	# Indice final
	li $t2, 6	# nb modulo
	li $t3, 5	# modulo du dernier element d'une ligne
	move $t9, $ra

print_plateau_FOR:
	li $t2, 6
	div $t0, $t2
	mfhi $t4
	bne $t4, $zero, print_plateau_NEXT

	move $a0, $a2
	li $v0, 4
	syscall
	jal print_new_line
	jal print_pipe

print_plateau_NEXT:
	li $v0, 4
	sll $t5, $t0, 1
	add $t5, $t5, $a1
	lh $t5, 0($t5)		
	li $t2, 4
	div $t5, $t2
	mfhi $t6	
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3
	syscall

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall

	addi $a0, $a3, 16	# print "-->"
	syscall

	addi $t0, $t0, 1

	jal print_pipe
	bne $t4, $t3, print_plateau_FOR
	jal print_new_line
	blt $t0, $t1, print_plateau_FOR

print_plateau_END_FOR:
	move $a0, $a2
	li $v0, 4
	syscall
	jal print_new_line

	jr $t9







































































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
