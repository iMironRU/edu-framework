# Классификаторы

Справочные значения, используемые в запросах API. Загружаются через `/api/cls/get`.

## Как получить значения

```bash
GET /api/cls/get?ClsType=GenderCls
```

Требует только `Session-Key` в заголовке. Подпись не нужна.

## Кэширование

Классификаторы меняются редко. Рекомендуемая стратегия:
- Загружать при старте сессии (или раз в сутки)
- Хранить локально как `Map<Id, Name>`
- Использовать поле `Actual: true/false` — неактуальные значения встречаются в старых данных, но для новых записей использовать только актуальные

## Все классификаторы (v3.4.0)

| Классификатор | Описание | Используется в |
|---|---|---|
| `AchievementCategoryCls` | Категории индивидуальных достижений | CompetitiveGroupAchievementList |
| `AdmissionEventCls` | Контрольные мероприятия приёма | CampaignEventList |
| `BaseEducationCls` | Уровень базового образования | CompetitionList |
| `BenefitCls` | Льготы | CompetitiveGroupBenefitList |
| `BenefitStateCls` | Состояния льгот | CompetitiveGroupBenefitList |
| `BudgetLevelCls` | Уровни бюджета | CompetitiveGroupList |
| `CompetitiveGroupStatusCls` | Статусы конкурсной группы | CompetitiveGroupStatusList |
| `DictionaryTypeCls` | Типы справочников вуза | DictionaryValueList |
| `DirectionCls` | Направления подготовки (УГСН) | OrgDirectionList |
| `DocumentCategoryCls` | Категории документов | DocumentList |
| `DocumentCheckStatusCls` | Статусы проверки документов | DocumentList |
| `DocumentTypeCls` | Типы документов | ApplicationList, DocumentList |
| `EducationFormCls` | Формы обучения | CompetitiveGroupList |
| `EducationLevelCls` | Уровни образования | CompetitiveGroupList |
| `EducationLevelGroupCls` | Группы уровней образования | CampaignList |
| `EntranceTestLanguageCls` | Языки вступительных испытаний | EntranceTestList |
| `EntranceTestTypeCls` | Типы вступительных испытаний | EntranceTestList |
| `FreeEducationReasonCls` | Основания бесплатного обучения | CompetitiveGroupList |
| `GenderCls` | Пол | ApplicationList (AddEntrant) |
| `NoticesTypeCls` | Типы уведомлений | NoticeList |
| `OksmCls` | Гражданство (страны) | ApplicationList (AddEntrant) |
| `OlympicCls` | Олимпиады | CompetitiveGroupBenefitList |
| `OlympicDiplomaTypeCls` | Типы дипломов олимпиад | CompetitiveGroupBenefitList |
| `OlympicLevelCls` | Уровни олимпиад | OlympicCls |
| `OlympicProfileCls` | Профили олимпиад | OlympicCls |
| `OlympicProfileSubjectCls` | Предметы профилей олимпиад | OlympicCls |
| `OlympicRelationProfileCls` | Связь профилей олимпиад | OlympicCls |
| `PackagesStatusCls` | Статусы пакетов | RankedCompetitionListPackage |
| `PaidContractStatusCls` | Статусы платных договоров | PaidContract |
| `PlaceTypeCls` | Типы мест проведения ВИ | EntranceTestPlaceList |
| `ReasonsRejectionCls` | Причины отказа | ApplicationList |
| `RegionCls` | Регионы РФ | ApplicationList (AddEntrant) |
| `SpecialConditionsCls` | Особые условия | CompetitiveGroupBenefitList |
| `StagesAdmissionCls` | Этапы приёма | ApplicationList |
| `StatusOfferCls` | Статусы оферты | TargetContractList |
| `SubjectCls` | Предметы ЕГЭ | EntranceTestList |
| `TargetContractStatusCls` | Статусы целевых договоров | TargetContractList |
| `TargetOfferParamsCls` | Параметры целевой оферты | RtTargetOffer |
| `TargetOrganizationCls` | Организации целевого обучения | TargetContractList |
| `VkGroupChatTypeCls` | Типы чатов VK | CampaignList |

## XSD-схемы классификаторов

Схемы описывают структуру ответа `/api/cls/get`.  
Расположение: [../schemas/ClsXsd/](../schemas/ClsXsd/)

Все схемы содержат поля `Id`, `Name`, `Actual` как минимум. Некоторые дополнены специфичными полями (например, `DirectionCls` содержит коды ФГОС).
