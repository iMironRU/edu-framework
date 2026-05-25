# ApplicationList — Заявление

> **XSD:** `OwnXsd/ApplicationList/` · **Изменения в v3.4.0:** обновлена структура `EntrantChoice`

Центральная сущность приёмной кампании. Заявление связывает поступающего с конкурсными группами вуза.

## Связи

```
CampaignList (кампания)
    └── CompetitionList (конкурс)
            └── CompetitiveGroupList (конкурсная группа)
                    ↑
              ApplicationList (заявление)
                    ├── EntrantList (поступающий) ← создаётся вместе с заявлением или ссылка на существующего
                    ├── DocumentList (документы)
                    ├── ConsentToEnrollList (согласие на зачисление)
                    └── CompetitiveGroupStatusList (статусы КГ)
```

## Доступные операции

| Action | XSD | Описание |
|---|---|---|
| `Add` | `Add.xsd` | Создать заявление (и опционально поступающего) |
| `Edit` | `Edit.xsd` | Изменить общие параметры заявления |
| `GetAll` | `GetAll.xsd` / `GetAll.Response.xsd` | Получить список заявлений |
| `GetDirect` | `GetDirect.xsd` / `GetDirect.Response.xsd` | Получить заявление по ID (прямой доступ) |

## Поля — Add

### Идентификация поступающего (EntrantChoice)

При создании заявления нужно либо указать существующего поступающего, либо создать нового:

```xml
<!-- Вариант 1: ссылка на существующего поступающего -->
<EntrantChoice>
  <IdEntrant>12345</IdEntrant>
</EntrantChoice>

<!-- Вариант 2: создать нового поступающего -->
<EntrantChoice>
  <AddEntrant>
    <Identification>...</Identification>
    <Snils>12345678901</Snils>
    <IdGender>1</IdGender>
    <Birthday>2000-01-15</Birthday>
    ...
  </AddEntrant>
</EntrantChoice>
```

### Поля документа (Identification)

| Поле | Тип | Обязательность | Маппинг | Описание |
|---|---|---|---|---|
| `IdDocumentType` | Int4Type | required | → `DocumentTypeCls.Id` | Тип документа (паспорт = 1) |
| `DocName` | String256Type | required | | Наименование документа |
| `DocSeries` | String256Type | optional | | Серия |
| `DocNumber` | String256Type | optional | | Номер |
| `DocOrganization` | String256Type | optional | | Кем выдан |
| `IssueDate` | xs:date | required | | Дата выдачи. Формат `2006-01-02` |

### Поля поступающего (AddEntrant)

| Поле | Тип | Обязательность | Маппинг | Описание |
|---|---|---|---|---|
| `Snils` | SnilsType | optional* | | СНИЛС, 11 цифр. *Обязателен для граждан РФ |
| `IdGender` | Int2Type | required | → `GenderCls.Id` | Пол |
| `Birthday` | xs:date | required | | Дата рождения. Формат `2006-01-02` |
| `Birthplace` | String500Type | required | | Место рождения |
| `Phone` | String120Type | optional | | Телефон |
| `Email` | String150Type | optional | | Email |
| `IdOksm` | Int4Type | required | → `OksmCls.Id` | Гражданство |
| `FirstHigherEducation` | xs:boolean | required | | Нет высшего образования (`true` = первое ВО) |
| `NeedHostel` | xs:boolean | required | | Нужно общежитие |
| `AllowedForEpgu` | xs:boolean | required | | Разрешение передавать данные на ЕПГУ |

### Адрес (AddressList)

| Поле | Тип | Обязательность | Маппинг | Описание |
|---|---|---|---|---|
| `IsRegistration` | xs:boolean | required | | `true` = адрес регистрации |
| `FullAddr` | String1024Type | required | | Полный адрес строкой |
| `IdRegion` | Int4Type | required | → `RegionCls.Id` | Регион |
| `City` | String255Type | required | | Населённый пункт |
| `RegistrationDate` | xs:dateTime | required | | Дата регистрации. Формат RFC3339 |

### Параметры заявления

| Поле | Тип | Обязательность | Маппинг | Описание |
|---|---|---|---|---|
| `IdObject` | BigIntType | required | | Ваш внутренний ID объекта в рамках токена |
| `IdStageAdmission` | Int4Type | required | → `StagesAdmissionCls.Id` | Этап приёма |
| `Source` | SourceType | required | | Источник: `Oovo` (вуз) / `Epgu` / `SSPVO` |

## Маппинг из типичных систем вуза

| Поле в системе вуза | Поле в API | Примечание |
|---|---|---|
| ID абитуриента | `EntrantChoice/IdEntrant` или `AddEntrant` | Если в ФИС уже есть — используй IdEntrant |
| Паспортные данные | `Identification.*` | Тип документа из классификатора |
| СНИЛС | `Snils` | Только цифры, 11 символов без пробелов |
| Дата рождения | `Birthday` | Формат: YYYY-MM-DD |
| Гражданство | `IdOksm` | ID из классификатора OksmCls |
| Email | `Email` | max 150 символов |
| Нуждается в общежитии | `NeedHostel` | boolean |

## Источники данных заявления

Заявления могут поступать из разных источников — это важно для обработки:

- `Oovo` — вуз создал сам через API
- `Epgu` — поступило с Госуслуг
- `SSPVO` — поступило из ССПВО

Despatch-события при поступлении заявления с ЕПГУ: [EpguApplication](../schemas/DespatchXsd/EpguApplication/EpguApplication.xsd)

## Статусная модель

Статусы конкурсных групп заявления: → [competitive-group.md](competitive-group.md#статусная-модель)

> В v3.4.0 добавлен статус «Отозвано поступающим». Убедись что твоя система обрабатывает его корректно.
