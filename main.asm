# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (main code) for the program.
# ---------------------------------------------------------------------------

	.text

test:

	# fonction test pour tester les differentes fonctions construites

	jal init_plateau	# test init_plateau

	li $a0, 3			# test print_game
	li $a1, 1
	li $a2, 6
	li $a3, 4
	jal print_game

	li $a0, 1			# test ask_player_cell
	jal ask_player_cell_move
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

	li $a0, 3			# test ask_player_nb_pieces_move
	li $a1, 1
	jal ask_player_nb_pieces_move
	ori $a0, $v0, 0
	li $v0, 1
	syscall

	li $a0, 1			# test ask_player_action
	jal ask_player_action
	ori $a0, $v0, 0
	li $v0, 1
	syscall

	# li $a0, 6			# test can_player_choose_move
	# li $a1, 6
	# li $a2, 2
	# li $a3, 1
	# jal can_player_choose_move
	# ori $a0, $v0, 0
	# li $v0, 1
	# syscall

	li $a0, 1			# test ask_player_direction_move
	li $a1, 1
	li $a2, 2

	jal ask_player_direction_move
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	li $a0, 3
	li $a1, 3
	li $a2, 1
	jal ask_player_direction_move
	ori $a0, $v0, 0
	li $v0, 1
	syscall

	jal ask_player_cell_drop 	# test ask_player_cell_drop
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

	li $a0, 1
	jal print_winner

	jal print_new_line

	li $a0, 1
	jal can_move_piece 	# test can_move_piece
	ori $a0, $v0, 0
	li $v0, 1
	syscall

	jal print_new_line
	jal test_victory 	# test test_victory
	ori $a0, $v0, 0
	li $v0, 1
	syscall

#	jal print_new_line
#	li $a0, 0x16		# test get_nb_pieces_in_cell avec 3 pieces
#	li $a0, 0x59		# test get_nb_pieces_in_cell avec 4 pieces
#	jal get_nb_pieces_in_cell
#	ori $a0, $v0, 0
#	li $v0, 1
#	syscall

	jal print_new_line
	li $a0, 1
	li $a1, 2
	li $a2, 1
	li $a3, 1
	jal move_pieces		# test move_pieces
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

	jal print_new_line
	jal print_game		# test print_game

	jal print_new_line
	li $a0, 2
	li $a1, 3
	li $a2, 2
	li $a3, 1
	jal move_pieces		# test move_pieces
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

	jal print_new_line
	jal print_game

	jal print_new_line
	li $a0, 0
	li $a1, 0
	li $a2, 5
	li $a3, 2
	jal drop_pieces	# test drop_pieces
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

	jal print_new_line
	jal print_game

#	li $a0, 3
#	li $a1, 0
#	jal set_reserve

	li $a0, 1
	jal ask_player_nb_pieces_drop 	# test ask_player_nb_pieces_drop
	ori $a0, $v0, 0
	li $v0, 1
	syscall


	j main


#--------------------#

	# TODO
	.globl main
main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu
	
	li $v0, 10
	syscall		# Instruction de fin de programme
