# Шаг 6. Входящие события от ФИС (Despatch)

> **Когда делать:** постоянно в течение всей приёмной кампании  
> **Важность:** высокая — пропущенное событие может привести к рассинхрону данных

## Что такое despatch-события

Despatch — это сообщения, инициированные не вузом, а внешними системами:
- **ЕПГУ (Госуслуги)** — поступающий подал заявление, изменил данные, подал согласие
- **Личный кабинет ФИС** — поступающий или законный представитель совершил действие
- **Платформа «Работа в России»** — целевое предложение или договор

## Как получать события

```
GET /api/token/despatch/get
```

Возвращает список необработанных событий. После обработки — подтверди получение.

**Рекомендуемая частота опроса:** каждые 1–5 минут в активный период кампании.

## Типы событий и соответствующие XSD-схемы

| Событие | XSD | Описание |
|---|---|---|
| `EpguApplication` | `DespatchXsd/EpguApplication/EpguApplication.xsd` | Новое заявление с ЕПГУ |
| `EpguApplicationChange` | `DespatchXsd/EpguApplicationChange/EpguApplicationChange.xsd` | Изменение параметров заявления с ЕПГУ |
| `EpguApplicationCancel` | `DespatchXsd/EpguApplicationCancel/EpguApplicationCancel.xsd` | Отмена заявления поступающим на ЕПГУ |
| `DocumentChange` | `DespatchXsd/DocumentChange/DocumentChange.xsd` | Изменение документа |
| `EpguDocumentCancel` | `DespatchXsd/EpguDocumentCancel/EpguDocumentCancel.xsd` | Отмена документа с ЕПГУ |
| `PersonProfileChange` | `DespatchXsd/PersonProfileChange/PersonProfileChange.xsd` | Изменение профиля поступающего |
| `EpguConsentToEnroll` | `DespatchXsd/EpguConsentToEnroll/EpguConsentToEnroll.xsd` | Согласие на зачисление с ЕПГУ |
| `LkConsentToEnroll` | `DespatchXsd/LkConsentToEnroll/LkConsentToEnroll.xsd` | Согласие на зачисление из ЛК |
| `EpguLegalGuardianConsent` | `DespatchXsd/EpguLegalGuardianConsent/EpguLegalGuardianConsent.xsd` | Согласие законного представителя с ЕПГУ |
| `EpguNoticeDone` | `DespatchXsd/EpguNoticeDone/EpguNoticeDone.xsd` | Уведомление обработано на ЕПГУ |
| `EpguPaidContractClaim` | `DespatchXsd/EpguPaidContractClaim/EpguPaidContractClaim.xsd` | Заявка на платный договор с ЕПГУ |
| `EpguPaidContractData` | `DespatchXsd/EpguPaidContractData/EpguPaidContractData.xsd` | Данные платного договора с ЕПГУ |
| `EpguPaidContractResult` | `DespatchXsd/EpguPaidContractResult/EpguPaidContractResult.xsd` | Результат платного договора |
| `EpguTestAgreed` | `DespatchXsd/EpguTestAgreed/EpguTestAgreed.xsd` | Запись/отказ от ВИ на ЕПГУ |
| `EpguDisplayApplication` | `DespatchXsd/EpguDisplayApplication/EpguDisplayApplication.xsd` | Статус отображения заявления на ЕПГУ |
| `RtTargetOffer` | `DespatchXsd/RtTargetOffer/RtTargetOffer.xsd` | Целевое предложение с «Работа в России» |
| `RtTargetContract` | `DespatchXsd/RtTargetContract/RtTargetContract.xsd` | Целевой договор с «Работа в России» |

## Приоритет обработки

Критичные события (обрабатывать немедленно):

1. `EpguApplication` — новое заявление, нужно принять или отклонить
2. `EpguApplicationCancel` — заявление отозвано поступающим
3. `EpguConsentToEnroll` / `LkConsentToEnroll` — согласие на зачисление
4. `DocumentChange` — изменился документ, проверить актуальность данных

Менее срочные:

5. `PersonProfileChange` — изменились ФИО или другие данные профиля
6. `EpguPaidContractData` — данные по платному договору

## Типичная ошибка

**Не читать despatch регулярно** — события накапливаются в очереди. Если пропустить `EpguConsentToEnroll`, поступающий будет считать что согласие подано, а в системе вуза его не будет. Это приводит к конфликтам при зачислении.

> ⚠️ Событие `EpguApplication` — самое объёмное (94 элемента в XSD). Парсер должен обрабатывать все варианты полей корректно.

---

## 🆕 v3.5.0 — Новые события Lk* (из Личного кабинета ФИС)

Новая группа событий фиксирует действия, совершённые оператором вуза **напрямую через веб-интерфейс** ЛК Сервиса приёма (а не через API). Это означает: если кто-то из сотрудников вуза что-то изменил в ЛК руками — система получит об этом despatch-событие.

**Важно:** если вы ведёте все изменения только через API — эти события у вас не возникнут. Если часть операций делается через ЛК — нужно обрабатывать.

| Событие | Что означает |
|---|---|
| `LkApplication` | Оператор создал заявление в ЛК |
| `LkCompetitiveGroup` | Изменён статус или приоритеты КГ в ЛК |
| `LkCompetitiveGroupAchievement` | Назначены баллы за ИД в ЛК |
| `LkCompetitiveGroupBenefit` | Учтены особые права в ЛК |
| `LkCompetitiveGroupStatus` | Выставлен статус КГ в ЛК |
| `LkConsentToEnroll` | Подано/отозвано согласие через ЛК |
| `LkDocument` | Добавлен/изменён документ в ЛК |
| `LkEntranceTestResult` | Внесён результат ВИ в ЛК |
| `LkEntrantPriority` | Изменены приоритеты абитуриента в ЛК |
| `LkLegalGuardianConsent` | Согласие законного представителя через ЛК |
| `LkTestAgreed` | Запись на ВИ оформлена в ЛК |

Схемы: `schemas/DespatchXsd/Lk*/`
