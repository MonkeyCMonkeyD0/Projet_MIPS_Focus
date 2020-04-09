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

	.globl move_pieces
move_pieces:				# $a0 = coord x-y depart, $a1 = coord x-y arrivé, $a2 = nb pieces
							# $a0 = coord x depart, $ a1 = coord y depart, $a2 = coord x arrivé, $a3 = coord y arrivé, nb pieces

	# Met a jour la memoire pour representer le deplacement des pieces

	jr $ra


#--------------------#

	.globl test_victory
test_victory: 				# NULL

	# Test si un des joueur à gagné

	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

	

#--------------------#





























































































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
