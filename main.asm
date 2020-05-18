# ---------------------------------------------------------------------------
# MAIN SEGMENT
#
# Text segment (main code) for the program.
# ---------------------------------------------------------------------------

	.text

#j test 			# decommenter pour tester des fonctions


	.globl main
main:

	# fonction main qui sera appelé au lancement du programme pour executer le jeu
	
	jal init_plateau
	jal init_reserve
	li $t0, 1			# starting player
	sub $sp, $sp, 4
	sw $t0, 0($sp)

	main_WHILE:
	li $a0, 36
	li $a1, 0
	li $a2, 0
	jal print_game

	jal test_victory
	bnez $v0, main_END_WHILE

	lw $a0, 0($sp)
	jal ask_player_action
	beqz $v0, main_IF

	jal ask_player_cell_drop
	addi $v0, $v0, -1	# coord x = $a0 - 1
	addi $v1, $v1, -1	# coord y = $a1 - 1
	sll $v1, $v1, 1		# *2
	add $v0, $v0, $v1
	sll $v1, $v1, 1		# *2
	add $a2, $v0, $v1	# $a2 = x + 6*y

	sub $sp, $sp, 4
	sw $a2, 0($sp)

	li $a0, 36
	li $a1, 1
	jal print_game
	jal print_new_line

	lw $a0, 4($sp)
	jal ask_player_nb_pieces_drop
	lw $a0, 0($sp)
	ori $a1, $v0, 0
	lw $a2, 4($sp)
	add $sp, $sp, 4
	jal drop_pieces
	j main_END_IF

	main_IF:

	lw $a0, 0($sp)
	jal ask_player_cell_move
	sub $sp, $sp, 12
	sw $v1, 8($sp)
	sw $v0, 4($sp)

	addi $v0, $v0, -1	# coord x = $v0 - 1
	addi $v1, $v1, -1	# coord y = $v1 - 1
	sll $v1, $v1, 1		# *2
	add $v0, $v0, $v1
	sll $v1, $v1, 1		# *2
	add $a0, $v0, $v1	# $a0 = x + 6*y
	li $a1, 0
	li $a2, 0
	jal print_game
	jal print_new_line

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	jal ask_player_nb_pieces_move
	sw $v0, 0($sp)

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 0($sp)
	jal get_all_landing_cells

	lw $t1, 8($sp)
	lw $t0, 4($sp)
	addi $t0, $t0, -1	# coord x = $t0 - 1
	addi $t1, $t1, -1	# coord y = $t1 - 1
	sll $t1, $t1, 1		# *2
	add $t0, $t0, $t1
	sll $t1, $t1, 1		# *2
	add $a0, $t0, $t1	# $a0 = x + 6*y
	ori $a1, $v0, 0
	ori $a2, $v1, 0
	jal print_game
	jal print_new_line

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 0($sp)
	jal ask_player_direction_move

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 0($sp)
	ori $a3, $v0, 0
	jal get_landing_cell

	ori $a0, $v0, 0
	ori $a1, $v1, 0
	lw $a2, 0($sp)
	lw $a3, 12($sp)
	add $sp, $sp, 12
	jal move_pieces

	main_END_IF:

	ori $a0, $v1, 0
	ori $a1, $v0, 0
	jal change_reserve_player

	lw $t0, 0($sp)
	not $t0, $t0
	andi $t0, $t0, 3
	sw $t0, 0($sp)

	j main_WHILE

	main_END_WHILE:
	ori $a0, $v0, 0
	jal print_winner
	jal print_new_line

	li $v0, 10
	syscall		# Instruction de fin de programme


#--------------------#

test:

	# fonction test pour tester les differentes fonctions construites

	jal init_plateau	# test init_plateau

	li $a0, 3			# test print_game
	li $a1, 1
	li $a2, 6
	li $a3, 4
	jal print_game

	li $a0, 3			# test print_plateau2
	li $a1, 4
	li $a2, 0x151782
	jal print_plateau2

	li $a0, 3
	li $a1, 3
	li $a2, 1
	jal get_all_landing_cells 	# test get_all_landing_cells
	ori $a0, $v0, 0
	li $v0, 1
	syscall
	ori $a0, $v1, 0
	syscall

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

	# jal print_new_line
	# li $a0, 0x16		# test get_nb_pieces_in_cell avec 3 pieces
	# li $a0, 0x59		# test get_nb_pieces_in_cell avec 4 pieces
	# jal get_nb_pieces_in_cell
	# ori $a0, $v0, 0
	# li $v0, 1
	# syscall

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

	# li $a0, 3
	# li $a1, 0
	# jal set_reserve

	li $a0, 1
	jal ask_player_nb_pieces_drop 	# test ask_player_nb_pieces_drop
	ori $a0, $v0, 0
	li $v0, 1
	syscall


	j main

