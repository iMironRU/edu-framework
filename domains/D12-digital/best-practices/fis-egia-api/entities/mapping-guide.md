# Руководство по маппингу

Практический гайд: как данные из типичной системы вуза соотносятся с сущностями API.

## Общий порядок заполнения данных

Сущности зависят друг от друга — важно соблюдать порядок создания:

```
1. Справочники вуза (OrgDirectionList, DictionaryValueList)
2. Образовательные программы (EducationalProgramList)
3. Приёмная кампания (CampaignList)
4. Конкурсы (CompetitionList)
5. Конкурсные группы (CompetitiveGroupList)
   ├── Вступительные испытания (EntranceTestList)
   ├── Расписание ВИ (EntranceTestPlaceList)
   ├── Льготы (CompetitiveGroupBenefitList)
   └── Индивидуальные достижения (CompetitiveGroupAchievementList)
6. Заявления (ApplicationList)
   ├── Профиль поступающего (EntrantList)
   └── Документы (DocumentList)
```

## Типы данных API → язык программирования

| Тип XSD | Ограничение | Java | C# | Python | Примечание |
|---|---|---|---|---|---|
| `BigIntType` | 1 .. 9223372036854775807 | `long` | `long` | `int` | ID объекта в токене, ID из ФИС |
| `Int4Type` | 1 .. 2147483647 | `int` | `int` | `int` | Ссылки на классификаторы |
| `Int2Type` | 1 .. 32767 | `short` | `short` | `int` | Маленькие классификаторы (пол) |
| `NonNegativeInt4Type` | 0 .. 2147483647 | `int` | `int` | `int` | Баллы, количества |
| `UidType` | string, 1–36 | `String` | `string` | `str` | UUID v4, 36 символов |
| `SnilsType` | `\d{11}` | `String` | `string` | `str` | Только 11 цифр, без пробелов и дефисов |
| `xs:date` | YYYY-MM-DD | `LocalDate` | `DateOnly` | `date` | Формат: `2006-01-02` |
| `xs:dateTime` | RFC3339 | `OffsetDateTime` | `DateTimeOffset` | `datetime` | Формат: `2006-01-02T15:04:05+03:00` |
| `String256Type` | 1–256 chars | `String` | `string` | `str` | ⚠️ в разных схемах maxLength разный (см. KNOWN-ISSUES) |
| `FuiType` | 60–62 chars | `String` | `string` | `str` | Формат уникального идентификатора |
| `SourceType` | enum | `enum` | `enum` | `str` | `Oovo` / `Epgu` / `SSPVO` |
| `Value10000Type` | float 0–10000 | `float` | `float` | `float` | Баллы ЕГЭ и ВИ |

## Классификаторы — кэширование

Классификаторы редко меняются, их стоит загружать один раз в начале сессии и кэшировать:

```
/api/cls/get?ClsType=GenderCls         — пол (2 значения)
/api/cls/get?ClsType=DocumentTypeCls   — типы документов (~50 значений)
/api/cls/get?ClsType=OksmCls           — гражданство (страны мира)
/api/cls/get?ClsType=RegionCls         — регионы РФ
/api/cls/get?ClsType=SubjectCls        — предметы ЕГЭ
/api/cls/get?ClsType=BenefitCls        — льготы
/api/cls/get?ClsType=EducationLevelCls — уровни образования
/api/cls/get?ClsType=BudgetLevelCls    — уровни бюджета
```

Используй поле `Actual: true` — неактуальные значения оставлять в UI не стоит, но при чтении они могут встречаться в старых данных.

## Частые ловушки при маппинге

**СНИЛС.** Хранишь с пробелами `123-456-789 00`? Очищай до 11 цифр перед отправкой.

**Даты.** Проверяй timezone в `xs:dateTime` — сервер работает в UTC+3, передавай со смещением (`+03:00`), иначе ошибка 207.

**IdObject.** Это не ID из ФИС, это твой временный ID объекта в рамках одного токена. Используй порядковый номер внутри токена (1, 2, 3...). Настоящий ID из ФИС придёт в Response.

**Адреса.** Нужно передавать минимум один адрес — регистрационный (`IsRegistration: true`). Если адрес проживания отличается — добавляй второй объект.

**Гражданство vs. страна рождения.** `IdOksm` — это гражданство (классификатор OksmCls), не страна рождения. Место рождения — текстовое поле `Birthplace`.

**Первое высшее образование.** `FirstHigherEducation: true` означает «у поступающего НЕТ высшего образования» (признак первого ВО). Логика инвертированная относительно интуитивного понимания.
