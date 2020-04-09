# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

affichage_case: .asciiz  "   ", "[+]", "[*]", "-->", "<--"	# 4 char ascii par string : 4 octets pour décallage
affichage_grille: .asciiz "+------------------+------------------+------------------+------------------+------------------+------------------+"

affichage_stock: .asciiz " - le ", " possede ", " pieces en reserve." # 7 char, 10 char

phrase_victoire_1: .asciiz "Felicitation au "
phrase_victoire_2: .asciiz " qui a gagné !"


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

	.globl print_game
print_game:			# $a0 = coord x debut, $a1 = coord y debut, $a2 = coord x fin, $a3 = coord y fin

	# Affiche l'etat complet du jeu

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	jal print_plateau
	jal print_stock

	lw $ra, 0($sp)
	add $sp, $sp, 4		# move stack pointer
	jr $ra


#--------------------#

	.globl print_winner
print_winner: 				# $a0 = joueur gagnant

	# Affiche le joueur gagnant

	jr $ra


#--------------------#

	.globl print_new_line
print_new_line:				# NULL

	# Affiche un saut de ligne (\n) dans la console

	li $a0, '\n'
	li $v0, 11
	syscall
	jr $ra


#--------------------#

	.globl print_pipe
print_pipe:				# NULL

	# Affiche une pipe (|) dans la console

	li $a0, '|'
	li $v0, 11
	syscall
	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

print_plateau:				# $a0 = coord x debut, $a1 = coord y debut, $a2 = coord x fin, $a3 = coord y fin

	# Affiche le plateau de jeu avec les pieces qu'il contient ainsi que la reserve

	sub $sp, $sp, 20	# move stack pointer
	sw $ra, 16($sp)		# save $ra in stack
	sw $a0, 12($sp)		# save $a0 in stack
	sw $a1, 8($sp)		# save $a1 in stack
	sw $a2, 4($sp)		# save $a2 in stack
	sw $a3, 0($sp)		# save $a3 in stack

	la $a1, plateau
	la $a2, affichage_grille
	la $a3, affichage_case
	li $t0, 0		# Indice pour parcourir les lignes
	li $t1, 36		# Indice final
	li $t2, 6		# nb modulo
	li $t3, 5		# modulo du dernier element d'une ligne

	print_plateau_FOR:
	li $t2, 6
	div $t0, $t2
	mfhi $t4
	bne $t4, $zero, print_plateau_NEXT
				# si au debut d'une ligne on print la ligne et un \n
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
	syscall			# premier pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall			# second pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall			# 3eme pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall			# 4eme pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	li $t2, 4
	div $t5, $t2
	mfhi $t6		# mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall			# dernier pion de la case

	lw $t6, 12($sp)		# recupere la coord x du depart
	sub $t6, $t6, 1
	lw $t5, 8($sp)		# recupere la coord y du depart
	sub $t5, $t5, 1
	sll $t5, $t5, 1		# *2
	add $t6, $t6, $t5	# $t6 + 6*$t5 = $t6 + 2*$t5 + 2*2*$t5
	sll $t5, $t5, 1		# *2
	add $t6, $t6, $t5	# $t6 = case de depart

	beq $t6, $t0, print_plateau_SWITCH_1

	lw $t6, 4($sp)		# recupere la coord x de l'arrive
	sub $t6, $t6, 1
	lw $t5, 0($sp)		# recupere la coord y de l'arrive
	sub $t5, $t5, 1
	sll $t5, $t5, 1		# *2
	add $t6, $t6, $t5	# $t6 + 6*$t5 = $t6 + 2*$t5 + 2*2*$t5
	sll $t5, $t5, 1		# *2
	add $t6, $t6, $t5	# $t6 = case d'arrive

	beq $t6, $t0, print_plateau_SWITCH_2

	j print_plateau_SWITCH_default

	print_plateau_SWITCH_1:
	addi $a0, $a3, 12	# print "-->"
	j print_plateau_SWITCH_END

	print_plateau_SWITCH_2:
	addi $a0, $a3, 16	# print "<--"
	j print_plateau_SWITCH_END

	print_plateau_SWITCH_default:
	addi $a0, $a3, 0	# print "   "
	j print_plateau_SWITCH_END

	print_plateau_SWITCH_END:
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

	lw $ra, 16($sp)		# take $ra from stack
	addi $sp, $sp, 20	# move stack pointer
	jr $ra


#--------------------#

print_stock:		# NULL
		
	# Affiche le stock de chaque joueur

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	la $t0, reserve
	la $t1, affichage_stock
	la $t2, noms_joueurs

	addi $a0, $t1, 0
	li $v0, 4
	syscall

	addi $a0, $t2, 0
	syscall

	addi $a0, $t1, 7
	syscall

	addi $a0, $t0, 0
	lb $a0, 0($a0)
	li $v0, 1
	syscall

	addi $a0, $t1, 17
	li $v0, 4
	syscall

	jal print_new_line

	addi $a0, $t1, 0
	li $v0, 4
	syscall

	addi $a0, $t2, 13
	syscall

	addi $a0, $t1, 7
	syscall

	addi $a0, $t0, 1
	lb $a0, 0($a0)
	li $v0, 1
	syscall

	addi $a0, $t1, 17
	li $v0, 4
	syscall

	jal print_new_line

	lw $ra, 0($sp)			# save $ra in stack
	addi $sp, $sp, 4		# move stack pointer
	jr $ra


#--------------------#
