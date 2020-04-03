# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

phrase_choix_case_1: .asciiz "Indiquer la coordonnée "
phrase_choix_case_2: .asciiz " de la case de depart pour le "
phrase_choix_case_3: .asciiz " : "
# coord_x_y: .asciiz "x", "y"

phrase_choix_direction_1: .asciiz "Indiquer la direction souhaité ("
phrase_choix_direction_2: .asciiz ") : "
directions: .asciiz "^ (8)", "> (4)", "< (6)", "v (2)"

phrase_nb_piece_deplacement: .asciiz "Combien de pieces voulez vous déplacer ? "

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
# ---------------------------------------------------------------------------

	.text

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------


	.globl ask_player_cell
ask_player_cell:			# $a0 = num du joueur 

	# $v0 = Renvoie la coordonnée x de la case valide selectionnée
	# $v1 = Renvoie la coordonnée y de la case valide selectionnée

	jr $ra


#--------------------#


	.globl ask_player_nb_pieces
ask_player_nb_pieces:			# $a0 = coord case x, $a1 = coord case y

	# $v0 = Renvoie 0 si le joueur pose des pieces ou 1 si il en deplace
	# $v1 = Renvoie le nombre de pieces que le joueur actuel veut deplacer ou alors poser

	jr $ra


#--------------------#


	.globl ask_player_direction
ask_player_direction:			# $a0 = coord case x, $a1 = coord case y, $a2 = nb pieces

	# $v0 = Renvoie la direction voulu pour deplacer la pile de pieces du joueur actuel

	jr $ra


#--------------------#

	


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

	

#--------------------#



