# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (main code) for the program.
# ---------------------------------------------------------------------------
	
	.align 2
	.text

test:

	# fonction test pour tester les differentes fonctions construites

	jal init_plateau	# test init_plateau

	li $a0, 3			# test print_game
	li $a1, 1
	li $a2, 6
	li $a3, 4
	jal print_game

	li $a0, 1			# test can_player_move_cell (private)
	li $a1, 3
	li $a2, 1
	jal can_player_move_cell
	addi $a0, $v0, 0
	li $v0, 1
	syscall
	li $a0, 2
	li $a1, 3
	li $a2, 1
	jal can_player_move_cell
	addi $a0, $v0, 0
	li $v0, 1
	syscall

	j main


#--------------------#

	.globl main
main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu
	
	li $v0, 10
	syscall		# Instruction de fin de programme
