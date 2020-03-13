	.data
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

affichage_pions: .asciiz  "   ", "[+]", "[*]"
affichage_grille: .asciiz "+---------------+---------------+---------------+---------------+---------------+---------------+", "|"

.align 2

	.text
	.globl main
main: 
	jal init_plateau
	
	li $v0, 10
	syscall


init_plateau:
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
	
	# debug
	li $v0, 1
	ori $a0, $t3, 0
	syscall

	addi $t1, $t1, 1
	blt $t1, $t5, init_plateau_FOR
init_plateau_END_FOR:
	jr $ra













































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
