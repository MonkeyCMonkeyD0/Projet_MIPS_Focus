	.data
plateau: .space 180
reserve: .byte 0, 0
joueur_actuel: .byte 0
	
phrase_choix_case_depart_1_x: .asciiz "Indiquer la coordonnée x de départ pour le joueur 1 : "
phrase_choix_case_depart_1_y: .asciiz "Indiquer la coordonnée y de départ pour le joueur 1 : "
phrase_choix_case_depart_2_x: .asciiz "Indiquer la coordonnée x de départ pour le joueur 2 : "
phrase_choix_case_depart_2_y: .asciiz "Indiquer la coordonnée y de départ pour le joueur 2 : "
phrase_choix_case_arrive_1_x: .asciiz "Indiquer la coordonnée x d'arrivé pour le joueur 1 : "
phrase_choix_case_arrive_1_y: .asciiz "Indiquer la coordonnée y d'arrivé pour le joueur 1 : "
phrase_choix_case_arrive_2_x: .asciiz "Indiquer la coordonnée x d'arrivé pour le joueur 2 : "
phrase_choix_case_arrive_2_y: .asciiz "Indiquer la coordonnée y d'arrivé pour le joueur 2 : "
phrase_victoire_1: .asciiz "Felicitation qu joueur 1 qui a gagné !"
phrase_victoire_2: .asciiz "Felicitation qu joueur 2 qui a gagné !"
phrase_nb_piece_deplacement: .asciiz "Combien de pieces voulez vous déplacer ? "
pion_1: .asciiz "[+]"
pion_2: .asciiz "[*]"

.align 2

	.text
	.globl main
main: 

init_plateau: 
	la $t0, plateau
	li $t9, 0x20
	li $t8, 0x2A
	li $t7, 0x2B
	li $t1, 0

FOR_init_plateau: 











































	

#PRINT: j'aime trop kenza, kenza ma vie, love you kenza, kenza c'est la meilleure, je suis trop centent de la connaitre, c'est trop cool, Kenza est cool, MIPS c'est pas cool haha haha haha vive kenza, kenza est vrmt la meilleure, elle ecoute pas les rageux du genre 'AMINATA' LOL, waw kenza est trop belle je l'adore ! Je suis Tristqn et je suis nul, aller hop c'est cadeau
