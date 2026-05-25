# ФИС ГИА и Приём — Документация API

> Часть [edu-framework](https://github.com/iMironRU/edu-framework) · Домен D12-digital

| | ВУЗ (Высшее образование) | СПО (Среднее профессиональное) |
|---|---|---|
| Версия API | **3.5.0** (2025) | **1.0** (2025, новый) |
| Формат схем | XSD | JSON Schema |
| Схемы | `schemas/` | `schemas-spo/` |
| Документация | ниже | [spo/README.md](spo/README.md) |

---

## С чего начать

| Ситуация | Куда идти |
|---|---|
| Первый раз подключаемся | [getting-started/overview.md](getting-started/overview.md) |
| Обновились с прошлого года | [CHANGELOG.md](CHANGELOG.md) — раздел v3.5.0 |
| Забыл как работает авторизация | [getting-started/auth.md](getting-started/auth.md) |
| Забыл паттерн асинхронных запросов | [getting-started/async-pattern.md](getting-started/async-pattern.md) |
| Готовимся к кампании — с чего начать | [scenarios/01-setup.md](scenarios/01-setup.md) |
| Ищу конкретный endpoint | [reference/](reference/) |
| Как маппить свои данные | [entities/mapping-guide.md](entities/mapping-guide.md) |
| Разбираю ошибку | [reference/error-codes.md](reference/error-codes.md) |
| API СПО | [spo/README.md](spo/README.md) |

---

## Структура репозитория

```
fis-egia-api/
│
├── README.md
├── CHANGELOG.md                     ← история версий с диффом полей
│
├── getting-started/                 ← обязательно перед началом работы
│   ├── overview.md                  архитектура, термины, список запросов
│   ├── auth.md                      сессионный ключ, сертификат, ОГРН/КПП
│   ├── async-pattern.md             паттерн token/new → polling
│   ├── environments.md              тест/прод, как получить доступ
│   └── first-request.md             пошаговый запуск первого запроса
│
├── scenarios/                       ← сценарии приёмной кампании ВУЗ
│   ├── 01-setup.md                  справочники, НП, ОП
│   ├── 02-campaign.md               кампания, конкурсы, КГ
│   ├── 03-application.md            заявления, поступающие, документы
│   ├── 04-review.md                 ВИ, результаты, статусы
│   ├── 05-enroll.md                 зачисление, конкурсные списки
│   └── 06-incoming-events.md        despatch: ЕПГУ + ЛК события
│
├── reference/                       ← справочник по каждому endpoint
│   ├── error-codes.md               коды ошибок с решениями
│   ├── session-new.md
│   ├── cls-get.md
│   ├── token-new.md
│   ├── token-delay-get.md
│   ├── token-own-get.md
│   ├── token-despatch-get.md
│   ├── file-get.md
│   └── token-certificate-check.md
│
├── entities/                        ← объекты API и маппинг
│   ├── README.md                    граф связей сущностей
│   ├── mapping-guide.md             маппинг типов + ловушки
│   ├── application.md
│   ├── entrant.md
│   ├── campaign.md
│   ├── competition.md
│   ├── competitive-group.md
│   ├── document.md
│   └── consent-to-enroll.md
│
├── classifiers/
│   ├── README.md                    все 41 классификатор (+ RecruiterCls)
│   └── index.md
│
├── spo/                             ← API среднего профессионального образования
│   └── README.md                    обзор, отличия от ВУЗ, сущности
│
├── schemas/                         ← XSD-схемы ВУЗ (v3.5.0, 167 файлов)
│   ├── KNOWN-ISSUES.md
│   ├── ClsXsd/                      41 классификатор
│   ├── OwnXsd/                      28 сущностей
│   └── DespatchXsd/                 27 типов событий (+ 11 новых Lk*)
│
├── schemas-spo/                     ← JSON Schema СПО (2025, 98 файлов)
│   ├── OwnSchemas/
│   ├── DespatchSchemas/
│   └── ClsSchemas/
│
└── source-docs/
    ├── Инструкция_API_ВО_v3.5.0.pdf
    ├── Спецификация_API_ВО_v3.5.0.pdf
    ├── Инструкция_API_СПО_v1.0.pdf
    └── Спецификация_API_СПО_v1.0.pdf
```

---

## Версии API

| Версия | Дата | Ключевые изменения |
|---|---|---|
| **3.5.0** | 2025 | Иностранные абитуриенты, Lk* despatch, PlaceDistributionList, API СПО |
| 3.4.0 | май 2025 | EntranceTest1-3 стали обязательными в конкурсных списках |

Подробно: [CHANGELOG.md](CHANGELOG.md)

---

## Известные проблемы схем

> [schemas/KNOWN-ISSUES.md](schemas/KNOWN-ISSUES.md)

- `String256Type` — разный `maxLength` в двух despatch-схемах (KI-001)
- `String500Type` — `maxLength=50` в `RtTargetOffer.xsd` (KI-002, вероятно опечатка)
