#!/usr/bin/env bash
# review.sh — отправить файл процесса на рецензию ИИ-редактору
#
# Использование:
#   ./tools/review.sh <файл>                        — DeepSeek (по умолчанию)
#   ./tools/review.sh <файл> gpt-4o                 — OpenAI GPT-4o
#   ./tools/review.sh <файл> gemini-2.5-pro         — Google Gemini 2.5 Pro
#   ./tools/review.sh <файл> deepseek-v3
#
# Примеры:
#   ./tools/review.sh domains/D05-contingent/processes/D05-P03.md
#   ./tools/review.sh domains/D05-contingent/processes/D05-P01.md gpt-4o
#
# Сейчас поддерживается один тип файлов: domains/*/processes/*.md
# Промпт: tools/prompts/reviewer-process.md
#
# Требования:
#   - Python 3 в PATH
#   - .env в корне репозитория с DEEPSEEK_API_KEY и/или OPENAI_API_KEY
#     и/или GEMINI_API_KEY

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CHAPTER_FILE="${1:-}"
MODEL="${2:-deepseek-v3}"

if [[ -z "$CHAPTER_FILE" ]]; then
    echo "Использование: $0 <путь к файлу процесса> [модель]" >&2
    exit 1
fi

if [[ ! -f "$CHAPTER_FILE" ]]; then
    echo "Файл не найден: $CHAPTER_FILE" >&2
    exit 1
fi

CHAPTER_FILE="$CHAPTER_FILE" SCRIPT_DIR="$SCRIPT_DIR" ROOT_DIR="$ROOT_DIR" MODEL="$MODEL" \
python3 - << 'PYTHON_EOF'
import sys, os, json, re, urllib.request, urllib.error
from datetime import date
from pathlib import Path

script_dir   = Path(os.environ["SCRIPT_DIR"])
root_dir     = Path(os.environ["ROOT_DIR"])
chapter_file = Path(os.environ["CHAPTER_FILE"])
model        = os.environ["MODEL"]

if not chapter_file.is_absolute():
    chapter_file = Path.cwd() / chapter_file

rel_to_root = chapter_file.relative_to(root_dir)
parts = rel_to_root.parts  # e.g. ('domains', 'D05-contingent', 'processes', 'D05-P03.md')

# --- Проверить, что файл — это процесс ---
if not (len(parts) >= 4 and parts[0] == "domains" and parts[2] == "processes"):
    print(
        f"Предупреждение: файл не находится в domains/*/processes/.\n"
        f"  Ожидается путь вида: domains/D0X-name/processes/D0X-P0X.md\n"
        f"  Получено: {rel_to_root}\n"
        f"Продолжаю с промптом reviewer-process.md.",
        file=sys.stderr
    )

# --- Определить провайдера по имени модели ---
is_openai = model.startswith(("gpt-", "o1", "o3", "o4", "chatgpt"))
is_gemini = model.startswith("gemini-")
# DeepSeek = всё остальное

# --- Загрузить ключи из .env ---
env_path = root_dir / ".env"
keys = {}
if env_path.exists():
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        keys[k.strip()] = v.strip()

if is_openai:
    api_key = keys.get("OPENAI_API_KEY")
    if not api_key:
        print("Ошибка: OPENAI_API_KEY не найден в .env", file=sys.stderr)
        sys.exit(1)
    api_url = "https://api.openai.com/v1/chat/completions"
    provider_label = "OpenAI"
elif is_gemini:
    api_key = keys.get("GEMINI_API_KEY")
    if not api_key:
        print("Ошибка: GEMINI_API_KEY не найден в .env", file=sys.stderr)
        sys.exit(1)
    api_url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
    provider_label = "Google Gemini"
else:
    api_key = keys.get("DEEPSEEK_API_KEY")
    if not api_key:
        print("Ошибка: DEEPSEEK_API_KEY не найден в .env", file=sys.stderr)
        sys.exit(1)
    api_url = "https://api.deepseek.com/chat/completions"
    provider_label = "DeepSeek"

# --- Загрузить промпт ---
prompt_name  = "reviewer-process.md"
prompt_path  = root_dir / "tools" / "prompts" / prompt_name
if not prompt_path.exists():
    print(f"Ошибка: промпт не найден: {prompt_path}", file=sys.stderr)
    sys.exit(1)

system_prompt = prompt_path.read_text(encoding="utf-8")
chapter_text  = chapter_file.read_text(encoding="utf-8")

# --- Запрос к API ---
tokens_key = "max_completion_tokens" if is_openai else "max_tokens"
payload = {
    "model": model,
    "messages": [
        {"role": "system", "content": system_prompt},
        {"role": "user",   "content": f"Вот файл процесса для рецензии:\n\n{chapter_text}"}
    ],
    tokens_key: 8192
}
if not is_openai:
    payload["temperature"] = 0.3

req = urllib.request.Request(
    api_url,
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json",
             "Authorization": f"Bearer {api_key}"},
    method="POST"
)

print(f"Отправляю {rel_to_root} → {provider_label} ({model}) [промпт: {prompt_name}]...", flush=True)
try:
    with urllib.request.urlopen(req, timeout=180) as resp:
        result = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print(f"Ошибка HTTP {e.code}: {e.read().decode('utf-8', 'replace')}", file=sys.stderr)
    sys.exit(1)
except urllib.error.URLError as e:
    print(f"Ошибка сети: {e.reason}", file=sys.stderr)
    sys.exit(1)

review_text = result["choices"][0]["message"]["content"]
model_used  = result.get("model", model)
tokens      = result.get("usage", {})

# --- Путь для сохранения рецензии ---
today       = date.today().isoformat()
model_short = re.sub(r"[^a-z0-9\-]", "", model_used.lower())[:20]
stem        = chapter_file.stem  # e.g. "D05-P03"

# domains/D05-contingent/processes/D05-P03.md → reviews/D05-contingent/D05-P03.{model}.{date}.md
domain_dir = parts[1] if len(parts) >= 2 else "unknown"
out_dir    = root_dir / "reviews" / domain_dir
out_dir.mkdir(parents=True, exist_ok=True)
out_file   = out_dir / f"{stem}.{model_short}.{today}.md"

chapter_key = str(rel_to_root)

# --- Сохранить с YAML-фронтматтером ---
frontmatter = (
    f"---\n"
    f"file: {rel_to_root}\n"
    f"model: {model_used}\n"
    f"date: {today}\n"
    f"tokens_prompt: {tokens.get('prompt_tokens', '?')}\n"
    f"tokens_completion: {tokens.get('completion_tokens', '?')}\n"
    f"---\n\n"
)
out_file.write_text(frontmatter + review_text, encoding="utf-8")
print(f"Рецензия сохранена: {out_file.relative_to(root_dir)}")

# --- Обновить docs/review-status.json ---
status_path = root_dir / "docs" / "review-status.json"
status_path.parent.mkdir(parents=True, exist_ok=True)
status = json.loads(status_path.read_text()) if status_path.exists() else {}

entry   = status.get(chapter_key, {})
history = entry.get("history", [])
history.append({
    "date":  today,
    "model": model_used,
    "file":  str(out_file.relative_to(root_dir))
})
entry.update({
    "history":       history,
    "last_reviewed": today,
    "last_model":    model_used
})
status[chapter_key] = entry

status_path.write_text(json.dumps(status, ensure_ascii=False, indent=2))
print(f"Статус обновлён: {chapter_key}")
PYTHON_EOF
