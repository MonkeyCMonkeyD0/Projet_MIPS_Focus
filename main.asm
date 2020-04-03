# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data used by the program is declared in the data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

	.globl plateau
plateau: .space 72	# stockage : un half pour une case soit 16 bits pour 5 pions => pion sur 2 bit [01] 1 (+) / [10] 2 (*) / [00] vide
	.globl reserve
reserve: .byte 0, 0

	.align 2

# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (main code) for the program.
# ---------------------------------------------------------------------------

	.text
	.globl main

main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu

	jal init_plateau

	li $a0, 3
	li $a1, 1
	li $a2, 6
	li $a3, 4

	jal print_game_state
	
	li $v0, 10
	syscall		# Instruction de fin de programme
