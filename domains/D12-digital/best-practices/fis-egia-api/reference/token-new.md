# POST /api/token/new

> **Версия:** актуально с v3.0+ · **Изменения в v3.4.0:** нет

Отправка операции с сущностью (асинхронный режим). Используется для всех операций записи и чтения данных.

## Заголовки запроса

| Параметр | Значение |
|---|---|
| `Content-Type` | `application/json` |
| `Token-Header` | JSON-объект, закодированный в Base64 (см. ниже) |
| `Session-Key` | Сессионный ключ из `/api/session/new` |

### Token-Header (Base64 от JSON)

```json
{
  "action": "Add",
  "data_type": "ApplicationList",
  "OGRN": "1234567890123",
  "KPP": "123456789",
  "cert64": "<сертификат в Base64>"
}
```

| Поле | Тип | Обязательность | Описание |
|---|---|---|---|
| `action` | string | required | `Add` / `Edit` / `GetBy` / `GetDirect` / `GetAll` / `Remove` |
| `data_type` | string | required | Тип сущности, например `ApplicationList` |
| `OGRN` | string | required | ОГРН организации, 13 символов |
| `KPP` | string | required | КПП организации, 9 символов |
| `cert64` | string | required | Сертификат ЭП в Base64 |

## Тело запроса

```json
{
  "payload_base64": "<XML-документ в Base64>",
  "signature_base64": "<PKCS#7 подпись в Base64>"
}
```

> Для операций чтения (`GetBy`, `GetDirect`, `GetAll`) подпись не нужна — передавай `signature_base64: ""`.

**Подписываемая последовательность:**

```
Token-Header + "." + payload_base64
```

Точка входит в подписываемую строку.

## Ответы

### 200 OK — операция принята

```json
{
  "IdJwt": 100500,
  "DelaySeconds": 3
}
```

| Поле | Описание |
|---|---|
| `IdJwt` | Идентификатор операции. Используй для получения результата через `/api/token/own/get` |
| `DelaySeconds` | Рекомендованное время ожидания в секундах перед первым запросом результата |

### 4xx — ошибки

| Код | Причина | Действие |
|---|---|---|
| 400 | Невалидный JSON или тело больше допустимого размера | Проверить формирование тела запроса |
| 401 | Организация не найдена или нет сертификата | Загрузить сертификат в ЛК ФИС |
| 405 | Неправильный HTTP-метод | Использовать POST |
| 411 | Отсутствует Content-Length | Приложить заголовок |
| 413 | Тело запроса слишком большое | Уменьшить размер payload |

## Получение результата

После получения `IdJwt` → [token-own-get.md](token-own-get.md)

## Связанные сущности

Полный список сущностей и их XSD-схем: [../schemas/OwnXsd/](../schemas/OwnXsd/)

| EntityType | Доступные Action | Описание |
|---|---|---|
| `ApplicationList` | Add, Edit, GetBy, GetDirect, GetAll | Заявления |
| `CampaignList` | Add, Edit, GetBy, GetDirect, GetAll, Remove | Приёмные кампании |
| `CompetitionList` | Add, Edit, GetBy, GetDirect, GetAll, Remove | Конкурсы |
| `CompetitiveGroupList` | Add, Edit, GetBy, GetDirect, GetAll | Конкурсные группы |
| `EntrantList` | Edit, GetBy, GetDirect, GetAll | Поступающие |
| `DocumentList` | Add, Edit, GetBy, GetDirect | Документы поступающего |
| `ConsentToEnrollList` | GetBy, GetDirect | Согласия на зачисление |
| `EntranceTestList` | Add, Edit, GetBy, GetDirect, Remove | Вступительные испытания |
| `EntranceTestPlaceList` | Add, Edit, GetBy, GetDirect, Remove | Расписание ВИ |
| `RankedCompetitionListPackage` | Add, GetDirect | Конкурсные списки |
| `NoticeList` | Add, GetBy, GetDirect | Уведомления |

_Полный список — в [../schemas/OwnXsd/](../schemas/OwnXsd/)_
