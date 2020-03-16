# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data used by the program is declared in the data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

plateau: .space 72	# stockage : un half pour une case soit 16 bits pour 5 pions => pion sur 2 bit [01] 1 (+) / [10] 2 (*) / [00] vide
reserve: .byte 0, 0

phrase_choix_case_depart_0_x: .asciiz "Indiquer la coordonnée x de départ pour le joueur 1 (+) : "
phrase_choix_case_depart_0_y: .asciiz "Indiquer la coordonnée y de départ pour le joueur 1 (+) : "
phrase_choix_case_depart_1_x: .asciiz "Indiquer la coordonnée x de départ pour le joueur 2 (*) : "
phrase_choix_case_depart_1_y: .asciiz "Indiquer la coordonnée y de départ pour le joueur 2 (*) : "
phrase_choix_case_arrive_0_x: .asciiz "Indiquer la coordonnée x d'arrivé pour le joueur 1 (+) : "
phrase_choix_case_arrive_0_y: .asciiz "Indiquer la coordonnée y d'arrivé pour le joueur 1 (+) : "
phrase_choix_case_arrive_1_x: .asciiz "Indiquer la coordonnée x d'arrivé pour le joueur 2 (*) : "
phrase_choix_case_arrive_1_y: .asciiz "Indiquer la coordonnée y d'arrivé pour le joueur 2 (*) : "
phrase_nb_piece_deplacement: .asciiz "Combien de pieces voulez vous déplacer ? "
phrase_victoire_1: .asciiz "Felicitation qu joueur 1 (+) qui a gagné !"
phrase_victoire_2: .asciiz "Felicitation qu joueur 2 (*) qui a gagné !"

affichage_pions: .asciiz  "   ", "[+]", "[*]"		# 4 char ascii par string : 4 octets pour décallage
affichage_grille: .asciiz "|", "+---------------+---------------+---------------+---------------+---------------+---------------+"	# 2 ascii : 2 octets décallage

affichage_saut_ligne: .asciiz "\n"


# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (code) for the program.
# ---------------------------------------------------------------------------

	.text
	.align 2
	.globl main

main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu

	jal init_plateau
	
	li $v0, 10
	syscall		# Instruction de fin de programme


# ---------------------------------------------------------------------------
# FUNCTIONS SEGMENT
#
# Text segment (code) for the program.
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

init_plateau:

	# Remplir le plateau de pieces pour le début de partie

	la $t0, plateau
	li $t1, 0 	# indice deplacement dans plateau
	li $t4, 4
	li $t5, 36 	# nb cases plateau
init_plateau_FOR:
	sll $t2, $t1, 1 	# *2 pour half
	add $t2, $t2, $t0 	# adresse de la nouvelle case
	div $t3, $t1, $t4 	# indice mod 4
	mfhi $t3
	srl $t3, $t3, 1		# /2
	addi $t3, $t3, 1	# +1
	sh $t3, 0($t2)
	addi $t1, $t1, 1
	blt $t1, $t5, init_plateau_FOR
init_plateau_END_FOR:
	jr $ra

#--------------------#

print_new_line:

	# Faire un saut de ligne dans la console

	la $a0, affichage_saut_ligne
	li $v0, 4
	syscall
	jr $ra

#--------------------#
















































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
