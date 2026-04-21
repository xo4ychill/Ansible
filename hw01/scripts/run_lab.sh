#!/usr/bin/env bash
# =============================================================================
# run_lab.sh – Автоматизация тестового окружения для Ansible
# 
# Этот скрипт управляет Docker-контейнерами через docker-compose и запускает
# Ansible playbook для проверки домашнего задания.
#
# Использование:
#   ./run_lab.sh [up|down|test|cycle]
#
# Аргументы:
#   up    - запустить контейнеры (docker-compose up -d)
#   down  - остановить и удалить контейнеры (docker-compose down -v)
#   test  - выполнить только запуск playbook (контейнеры должны быть уже запущены)
#   cycle - полный цикл: up → test → down (используется по умолчанию)
# =============================================================================

set -euo pipefail  # Строгий режим: выход при ошибке, неинициализированных переменных, ошибках в пайпах

# ---------- Определение путей (все относительно расположения скрипта) ----------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # Каталог, где лежит скрипт (hw01/scripts)
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"                       # Корень проекта (hw01)
readonly DOCKER_COMPOSE_FILE="$PROJECT_DIR/docker/docker-compose.yml" # Файл docker-compose
readonly PLAYBOOK_DIR="$PROJECT_DIR/playbook"                         # Каталог с плейбуком и переменными
readonly INVENTORY="$PLAYBOOK_DIR/inventory/prod.yml"                 # Инвентарный файл для prod окружения
readonly PLAYBOOK="$PLAYBOOK_DIR/site.yml"                            # Основной плейбук
readonly VAULT_PASSWORD="netology"                                    # Пароль для расшифровки vault (в учебных целях)
readonly VAULT_PASS_FILE="$PROJECT_DIR/.vault_pass"                   # Временный файл с паролем
readonly CONTAINER_READY_TIMEOUT=30                                   # Максимальное время ожидания готовности контейнеров (сек)

# ---------- Цвета для вывода в терминал ----------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color (сброс цвета)

# Функции для цветного вывода сообщений
info()  { echo -e "${GREEN}[INFO]${NC} $1"; }   # Информационное сообщение (зелёный)
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }  # Предупреждение (жёлтый)
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; } # Сообщение об ошибке (красный) в stderr

# ---------- Проверка наличия необходимых зависимостей ----------
check_dependencies() {
    info "Проверка зависимостей..."
    local missing=0

    # Проверяем, что ansible-playbook доступен
    if ! command -v ansible-playbook &> /dev/null; then
        error "Команда 'ansible-playbook' не найдена. Установите Ansible."
        missing=1
    fi

    # Определяем команду для работы с Docker Compose (старый docker-compose или новый плагин)
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        error "Не найден docker-compose или docker compose plugin. Установите Docker Compose."
        missing=1
    fi

    # Проверяем существование файла docker-compose.yml
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        error "Файл docker-compose не найден по пути: $DOCKER_COMPOSE_FILE"
        missing=1
    fi

    # Проверяем существование каталога с плейбуком
    if [[ ! -d "$PLAYBOOK_DIR" ]]; then
        error "Каталог playbook не найден: $PLAYBOOK_DIR"
        missing=1
    fi

    # Если были ошибки – завершаем скрипт
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
    info "Все зависимости найдены."
    return 0
}

# ---------- Запуск контейнеров через docker-compose ----------
compose_up() {
    info "Запуск контейнеров с помощью '$COMPOSE_CMD up -d'..."
    $COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" up -d
    if [[ $? -ne 0 ]]; then
        error "Не удалось запустить контейнеры."
        exit 1
    fi

    info "Ожидание готовности контейнеров (максимум ${CONTAINER_READY_TIMEOUT} секунд)..."
    if ! wait_for_containers; then
        warn "Не все контейнеры успели запуститься за отведённое время, но продолжаем выполнение."
    else
        info "Все контейнеры готовы к работе."
    fi
}

# ---------- Остановка и удаление контейнеров ----------
compose_down() {
    info "Остановка и удаление контейнеров с помощью '$COMPOSE_CMD down -v'..."
    $COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" down -v
    if [[ $? -ne 0 ]]; then
        warn "Возникли проблемы при остановке контейнеров (возможно, они уже были удалены)."
    else
        info "Контейнеры успешно остановлены и удалены."
    fi
}

# ---------- Ожидание готовности всех необходимых контейнеров ----------
# Проверяет, что контейнеры ubuntu, centos7 и fedora запущены и находятся в состоянии "running"
wait_for_containers() {
    local containers=("ubuntu" "centos7" "fedora")
    local start_time=$(date +%s)
    local ready=0

    while [[ $ready -lt ${#containers[@]} ]]; do
        # Проверка таймаута
        local current_time=$(date +%s)
        if [[ $((current_time - start_time)) -gt $CONTAINER_READY_TIMEOUT ]]; then
            error "Таймаут ожидания контейнеров (${CONTAINER_READY_TIMEOUT} секунд)."
            return 1
        fi

        ready=0
        for container in "${containers[@]}"; do
            # Проверяем, что контейнер существует и работает
            if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
                local status=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
                if [[ "$status" == "running" ]]; then
                    ((ready++))
                fi
            fi
        done
        sleep 1  # Небольшая пауза перед следующей проверкой
    done
    return 0
}

# ---------- Запуск Ansible playbook ----------
run_ansible() {
    info "Запуск Ansible playbook..."

    # Сохраняем пароль vault во временный файл
    echo "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"

    # Переходим в каталог с плейбуком, чтобы Ansible автоматически нашёл group_vars
    (
        cd "$PLAYBOOK_DIR"
        ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --vault-password-file "$VAULT_PASS_FILE"
    )
    local ansible_rc=$?

    # Удаляем временный файл с паролем
    rm -f "$VAULT_PASS_FILE"

    if [[ $ansible_rc -eq 0 ]]; then
        info "Playbook выполнен успешно."
    else
        error "Playbook завершился с ошибкой (код возврата: $ansible_rc)."
    fi
    return $ansible_rc
}

# ---------- Основная функция (точка входа) ----------
main() {
    check_dependencies

    local action="${1:-cycle}"  # Если аргумент не передан, по умолчанию выполняем полный цикл
    case "$action" in
        up)
            info "Выполняется команда: запуск контейнеров"
            compose_up
            ;;
        down)
            info "Выполняется команда: остановка контейнеров"
            compose_down
            ;;
        test)
            info "Выполняется команда: запуск playbook"
            run_ansible
            ;;
        cycle|"")
            info "Запуск полного цикла: поднятие окружения → выполнение playbook → очистка"
            compose_up
            local rc=0
            run_ansible || rc=$?
            compose_down
            if [[ $rc -ne 0 ]]; then
                error "Цикл завершён с ошибкой (код $rc)."
                exit $rc
            else
                info "Цикл успешно завершён."
            fi
            ;;
        *)
            echo "Использование: $0 {up|down|test|cycle}"
            echo "  up    - запустить контейнеры (docker-compose up -d)"
            echo "  down  - остановить и удалить контейнеры (docker-compose down -v)"
            echo "  test  - выполнить только playbook (требуются уже запущенные контейнеры)"
            echo "  cycle - полный цикл: up → test → down (по умолчанию)"
            exit 1
            ;;
    esac
}

# Вызов главной функции с передачей всех аргументов командной строки
main "$@"
