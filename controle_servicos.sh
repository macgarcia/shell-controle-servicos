#/bin/bash

_acao=""
_msg=""
_comando=""

function verificar_usuario() {
    if [ ! $UID -eq 0 ]; then
        echo "====================== # ALERTA # ==========================="
        echo "             Execute o script com o usuário root"
        echo "============================================================="
        exit 0
    fi
}

function selecao_acao() {
    _acao=`zenity --list --radiolist --column "Selecione" \
                                    --column "Ação" FALSE Desligar FALSE Ligar \
                                    --text "Selecione uma opção" \
                                    --title "Controle de serviços do sistema"`
    if [ -z $_acao ]; then
        exit 0
    fi
}

function carregar_servicos() {
    service --status-all | sed 's/[^\]*]  //g' > .servico.txt; \
        sleep 3 | zenity --progress --pulsate \
                    --text "Carregando os serviços..." --no-cancel --auto-close --width=400
    _escolha=`cat .servico.txt | zenity --list --column="Serviços" --text="Selecione um serviço" \
                                --title="Serviços do sistema" --width=400 --height=600`
    if [ ! $? -eq 0 ]; then
        exit 0
    fi

    if [ $_acao == "Desligar" ]; then
        _msg="Serviço desligado com sucesso"
        _comando="service "$_escolha" stop"
    else
        _msg="Serviço iniciado com sucesso"
        _comando="service "$_escolha" start"
    fi

    $_comando

    if [ $? -eq 0 ]; then
        zenity --info --title=Informação --text="${_msg}" --width=200
        rm .servico.txt
        exit 0
    fi
}

function instrucao() {
    case $1 in
        "-e")
            verificar_usuario
            selecao_acao
            carregar_servicos
            ;;
        "-i")
            echo "  Informações do software"
            echo "      Versão: 0.1"
            echo "      Versão do bash: 4.4.20"
            echo "      Descrição: Software para o controle dos serviços que devem ser ativados ou desativados no sistema."
            echo "      Inteface gráfica: Zenity"
            echo ""
            echo "  Informações do desenvolvedor"
            echo "      Desenvolvedor: Marcos Garcia"
            ;;
        *)
            echo "Instruções:"
            echo "  -e      Executar o software"
            echo "  -i      Informações"
            ;;
        esac
}

function iniciar() {
    instrucao $1
}

iniciar $1
