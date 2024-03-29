# ---------------------------------------------------------------------------
# DATA SEGMENT
#
# Data (Strings) used by functions in this file is declared in this data segment.
# ---------------------------------------------------------------------------

	.data
	.align 0

affichage_case: .asciiz  "   ", "[+]", "[*]", "-->", "<--"	# 3 char ascii par string : 4 octets pour décallage
affichage_grille: .asciiz "+------------------+------------------+------------------+------------------+------------------+------------------+"

affichage_stock_1: .asciiz " - le "
affichage_stock_2: .asciiz " possède "
affichage_stock_3: .asciiz " pièces en reserve."

phrase_victoire_1: .asciiz "Felicitation au "
phrase_victoire_2: .asciiz " qui a gagné !"

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
# Core of every functions :
#
# 		sub $sp, $sp, 4		# move stack pointer
#		sw $ra, 0($sp)		# save $ra in stack
#
#		lw $ra, 0($sp)		# get $ra from stack
#		add $sp, $sp, 4		# move stack pointer
#		jr $ra 				# go back to caller
#
# ---------------------------------------------------------------------------

	.text

# ---------------------------------------------------------------------------
# 		Public	 	(.globl)
# ---------------------------------------------------------------------------

	.globl print_game
print_game:					# $a0 = case depart, $a1 = nb directions possible, $a2 = cases d'arrives encodé sur 6 bit car case

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

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack

	sub $t0, $a0, 1		# save player num in $t0
	li $t1, 13			

	jal print_new_line
	la $a0, phrase_victoire_1
	li $v0, 4
	syscall

	mult $t0, $t1		# $t0 * 13
	mflo $t0
	la $t1, noms_joueurs
	add $a0, $t0, $t1	# $a0 = adress of player name cell
	syscall

	la $a0, phrase_victoire_2
	syscall

	lw $ra, 0($sp)
	add $sp, $sp, 4		# move stack pointer
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
print_pipe:					# NULL

	# Affiche une pipe (|) dans la console

	li $a0, '|'
	li $v0, 11
	syscall
	jr $ra


#--------------------#

	.globl print_space
print_space:				# NULL

	# Affiche un espace ( ) dans la console

	li $a0, ' '
	li $v0, 11
	syscall
	jr $ra


# ---------------------------------------------------------------------------
# 		Private
# ---------------------------------------------------------------------------

	.globl print_plateau
print_plateau:				# $a0 = case depart, $a1 = nb directions possible, $a2 = cases d'arrives encodé sur 6 bit car case

	# Affiche le plateau de jeu avec les pieces qu'il contient

	sub $sp, $sp, 16	# move stack pointer
	sw $ra, 12($sp)		# save $ra in stack
	sw $a0, 8($sp)		# save $a0 in stack
	sw $a1, 4($sp)		# save $a1 in stack
	sw $a2, 0($sp)		# save $a2 in stack

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

	andi $t6, $t5, 3	# 2 bit de poids faible = mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3
	syscall				# premier pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	andi $t6, $t5, 3	# 2 bit de poids faible = mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall				# second pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	andi $t6, $t5, 3	# 2 bit de poids faible = mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall				# 3eme pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	andi $t6, $t5, 3	# 2 bit de poids faible = mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall				# 4eme pion de la case

	srl $t5, $t5, 2		# retirer les 2 bits de poids faible
	andi $t6, $t5, 3	# 2 bit de poids faible = mod 4
	sll $t6, $t6, 2 	# *4
	add $a0, $t6, $a3	# print affichage_case[$t6]
	syscall				# dernier pion de la case

	lw $t6, 8($sp)		# recupere la case de depart
	beq $t6, $t0, print_plateau_SWITCH_1

	lw $t6, 0($sp)		# recupere les cases d'arrives
	lw $t7, 4($sp)		# $t7 = nb cases arrives
	print_plateau_FOR_2:

	blez $t7, print_plateau_END_FOR_2
	andi $t8, $t6, 0x3F 	# recuperer les 6 dernier bit
	beq $t8, $t0, print_plateau_SWITCH_2

	srl $t6, $t6, 6
	addi $t7, $t7, -1
	j print_plateau_FOR_2
	print_plateau_END_FOR_2:

	j print_plateau_SWITCH_default

	print_plateau_SWITCH_1:
	addi $a0, $a3, 12	# print "-->"
	j print_plateau_END_SWITCH

	print_plateau_SWITCH_2:
	addi $a0, $a3, 16	# print "<--"
	j print_plateau_END_SWITCH

	print_plateau_SWITCH_default:
	addi $a0, $a3, 0	# print "   "
	j print_plateau_END_SWITCH

	print_plateau_END_SWITCH:
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

	lw $ra, 12($sp)		# take $ra from stack
	addi $sp, $sp, 16	# move stack pointer
	jr $ra


#--------------------#

print_stock:				# NULL
		
	# Affiche la reserve de chaque joueur

	sub $sp, $sp, 4		# move stack pointer
	sw $ra, 0($sp)		# save $ra in stack
	
	li $t0, 0
	la $t1, reserve
	la $t2, noms_joueurs
	li $t3, 13 				# 13 char pour changer de player name

	print_stock_FOR:
	la $a0, affichage_stock_1
	li $v0, 4
	syscall

	mult $t0, $t3
	mflo $a0
	add $a0, $t2, $a0
	syscall

	la $a0, affichage_stock_2
	syscall

	la $a0, reserve
	add $a0, $a0, $t0
	lb $a0, 0($a0)
	li $v0, 1
	syscall

	la $a0, affichage_stock_3
	li $v0, 4
	syscall

	jal print_new_line

	addi $t0, $t0, 1
	slti $t4, $t0, 2
	bnez $t4, print_stock_FOR

	print_stock_END_FOR:
	lw $ra, 0($sp)		# get $ra from stack
	addi $sp, $sp, 4	# move stack pointer
	jr $ra

