# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data used by the program is declared in the data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

plateau: .space 72	# stockage : un half pour une case soit 16 bits pour 5 pions => pion sur 2 bit [01] 1 (+) / [10] 2 (*) / [00] vide
reserve: .byte 0, 0

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


# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (main code) for the program.
# ---------------------------------------------------------------------------

	.text
	.align 2
	.globl main

main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu

	jal init_plateau
	
	li $v0, 10
	syscall		# Instruction de fin de programme
