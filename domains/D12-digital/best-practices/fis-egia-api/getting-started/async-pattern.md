# Асинхронный паттерн

Большинство операций в API работают асинхронно. Важно понять этот паттерн один раз — он одинаков для всех операций с данными.

## Схема

```
1. Сформировать XML по XSD-схеме
        ↓
2. POST /api/token/new  →  получить IdJwt + время ожидания
        ↓
3. Подождать (см. рекомендации ниже)
        ↓
4. GET /api/token/own/get  →  результат или статус "ещё не готово"
        ↓
5. Если "не готово" — повторить шаг 4
```

## Шаг 1. Формирование XML

Собери XML-документ согласно XSD-схеме для нужной сущности и операции.  
Схемы: [../schemas/OwnXsd/](../schemas/OwnXsd/)

Пример для создания заявления: `OwnXsd/ApplicationList/Add.xsd`

## Шаг 2. POST /api/token/new

Заголовки:

```
Content-Type: application/json
Token-Header: <Base64(JSON с action, entityType, ОГРН, КПП, cert64)>
Session-Key: <ключ сессии из /api/session/new>
```

Тело (для операций записи):

```json
{
  "payload_base64": "<Base64(XML-документ)>",
  "signature_base64": "<Base64(PKCS#7 подпись)>"
}
```

Тело (для операций чтения — `GetBy`, `GetDirect`, `GetAll`):

```json
{
  "payload_base64": "<Base64(XML-документ)>",
  "signature_base64": ""
}
```

> Операции чтения подписи не требуют — `signature_base64` передаётся пустой строкой.

Ответ `200 OK`:

```json
{
  "IdJwt": 100500,
  "DelaySeconds": 3
}
```

`DelaySeconds` — рекомендованное время ожидания перед первым запросом результата.

## Шаг 3. Ожидание

Рекомендации по polling:

| Ситуация | Стратегия |
|---|---|
| `DelaySeconds` получен | подожди `DelaySeconds` секунд |
| `DelaySeconds` не получен | подожди 2–5 секунд |
| Ответ "ещё не готово" | экспоненциальный backoff: 2с → 5с → 10с → 30с |
| Максимальное ожидание | не более 10 минут, после — считать ошибкой |

## Шаг 4–5. GET /api/token/own/get

```json
{ "IdJwt": 100500 }
```

Возможные ответы:

| Ситуация | Что в ответе |
|---|---|
| Готово, успешно | `payload_base64` с результирующим XML |
| Готово, ошибка | `payload_base64` с `<ErrorList>` |
| Ещё не готово | специальный статус, повтори запрос |

## Получение нескольких результатов за раз

Можно запросить несколько операций одним вызовом:

```json
{ "IdJwtList": [100500, 100501, 100502] }
```

Удобно при массовой загрузке данных.

## Пример на curl

```bash
# Шаг 1: получить сессию
SESSION=$(curl -s -X POST https://api.example.ru/api/session/new \
  -H "Content-Type: application/json" \
  -H "Token-Header: <base64_header>" \
  -d '{"signature_base64":"<подпись>"}' | jq -r '."Session-Key"')

# Шаг 2: отправить операцию
IDJWT=$(curl -s -X POST https://api.example.ru/api/token/new \
  -H "Content-Type: application/json" \
  -H "Token-Header: <base64_header>" \
  -H "Session-Key: $SESSION" \
  -d '{"payload_base64":"<xml_base64>","signature_base64":"<подпись>"}' \
  | jq -r '.IdJwt')

# Шаг 3: подождать
sleep 5

# Шаг 4: получить результат
curl -s -X GET https://api.example.ru/api/token/own/get \
  -H "Content-Type: application/json" \
  -H "Session-Key: $SESSION" \
  -d "{\"IdJwt\": $IDJWT}"
```

## Частые ошибки

**Слишком частый polling** — сервер может расценить как подозрительную активность (ошибка 212).

**Не проверяем Stage в ответе** — поле `Stage` в response-схеме показывает на каком этапе завершилась обработка: `Validate` (ошибка валидации схемы) или `Business` (ошибка бизнес-логики). Это важно для отладки.

**Не обрабатываем `ErrorList`** — при ошибке сервер всё равно возвращает `200 OK`, но payload содержит `<ErrorList>` вместо данных. Нужно явно проверять наличие `ErrorList` в распакованном XML.
