#!/bin/bash

LOG="$HOME/rl-swarm/gensynnode.log"
NODE_DIR="$HOME/rl-swarm"

start_node() {
    cd $NODE_DIR
    source .venv/bin/activate
    screen -S gensynnode -d -m bash -c "trap '' INT; bash run_rl_swarm.sh 2>&1 | tee $LOG"
    echo "✅ Нода запущена!"
}

logs_node() {
    tail -n 100 -f $LOG
}

stop_node() {
    if screen -list | grep -q "gensynnode"; then
        screen -ls | grep gensynnode | cut -d. -f1 | awk '{print $1}' | xargs kill
    fi
    PID=$(netstat -tulnp | grep :3000 | awk '{print $7}' | cut -d'/' -f1)
    sudo kill $PID 2>/dev/null
    echo "⛔ Нода зупинена."
}

update_node() {
    cd $NODE_DIR
    cp swarm.pen $HOME/backup_swarm.pen
    git fetch origin
    git reset --hard origin/main
    git pull origin main
    echo "🔄 Нода оновлена."
}

delete_node() {
    stop_node
    sudo rm -rf $NODE_DIR
    echo "🗑️ Нода видалена."
}

show_userdata() {
    cat $NODE_DIR/modal-login/temp-data/userData.json
}

show_apikey() {
    cat $NODE_DIR/modal-login/temp-data/userApiKey.json
}

while true; do
    echo -e "\n======= Меню керування Gensyn ======="
    echo "1. 🚀 Запуск ноди"
    echo "2. 📜 Перегляд логів"
    echo "3. ⛔ Зупинити ноду"
    echo "4. 🔄 Оновити ноду"
    echo "5. 🗑️ Видалити ноду"
    echo "6. 👤 Показати userData"
    echo "7. 🔑 Показати API ключ"
    echo "8. 👋 Вийти"
    read -p "Вибери опцію: " choice

    case $choice in
        1) start_node ;;
        2) logs_node ;;
        3) stop_node ;;
        4) update_node ;;
        5) delete_node ;;
        6) show_userdata ;;
        7) show_apikey ;;
        8) echo "Пака! 👋"; exit ;;
        *) echo "Невірний вибір!" ;;
    esac
done
