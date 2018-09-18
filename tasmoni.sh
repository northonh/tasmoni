#!/bin/bash
#
# Tablet As Second MONItor (TASMONI)
# Considerações:
# 1. O tablet estará à direita do monitor primário.
# 2. O computador em que está o monitor primário deve ter instalado os programas x11vnc e xrandr.
# 3. O tablet deve ter instalado um cliente VNC qualquer.
# 4. Computador e tablet deve estar na mesma rede.
# 5. O monitor padrão do computador é nomeado como LVDS-1.

# Largura e altura do tablet (usado como segundo monitor) desconsiderando o espaço ocupado pela Task Bar
LARGURA_TABLET=1280
ALTURA_TABLET=752

# Largura e altura do monitor primário
LARGURA_MONITOR=1366
ALTURA_MONITOR=768

# Função que inicia o compartilhamento
inicia() {
	# Calculando dimensões totais
	LARGURA_TOTAL=$(( LARGURA_MONITOR + LARGURA_TABLET ));
	ALTURA_TOTAL=$(( ALTURA_MONITOR > ALTURA_TABLET ? ALTURA_MONITOR : ALTURA_TABLET ))

	# Redimensiona a resolução da tela e área do mouse
	xrandr --fb ${LARGURA_TOTAL}x${ALTURA_TOTAL} --output LVDS-1 --panning ${LARGURA_TOTAL}x${ALTURA_TOTAL}+0+0/${LARGURA_TOTAL}x${ALTURA_TOTAL}+0+0

	# Redimensiona o panning para a área do monitor primário, permitindo que o mouse possa atingir toda resolução
        # Impede que a tela se mova quando o mouse atinge os limites da tela	
	xrandr --fb ${LARGURA_TOTAL}x${ALTURA_TOTAL} --output LVDS-1 --panning ${LARGURA_MONITOR}x${ALTURA_MONITOR}+0+0/${LARGURA_TOTAL}x${ALTURA_TOTAL}+0+0

	# Calculando deslocamento da segunda tela para o servidor VNC
	DESLOCAMENTO_HORIZONTAL=$(( LARGURA_MONITOR + 1 ))
	DESLOCAMENTO_VERTICAL=0

	# Inicia o VNC Server apenas para a área não visível da resolução
	PORTA_X11VNC=`x11vnc -bg -nevershared -forever -clip ${LARGURA_TABLET}x${ALTURA_TABLET}+${DESLOCAMENTO_HORIZONTAL}+${DESLOCAMENTO_VERTICAL} 2> /dev/null | grep -o "[0-9]*"`
	printf "Resolução redimensionada!!!\n"
	printf "Conecte o VNC do Tablet a porta: %d\n" $PORTA_X11VNC
}

# Restaura a resolução anterior
finaliza() {
	xrandr --fb ${LARGURA_MONITOR}x${ALTURA_MONITOR} --output LVDS-1 --panning ${LARGURA_MONITOR}x${ALTURA_MONITOR}+0+0/${LARGURA_MONITOR}x${ALTURA_MONITOR}+0+0
	pkill -9 x11vnc
	printf "Resolução restaurada!!!\n"
}

mensagem() {
		printf "ERRO: Parâmetro incorreto!\n"
		printf "Uso correto: $0 {inicia|finaliza}\n"
}

main() {
	if [ $# -ne 1 ]; then
		mensagem
	else
		case $1 in
			inicia)
				inicia
				;;
			finaliza)
				finaliza
				;;
			*)
				mensagem
				;;
		esac
	fi
}

main $@
