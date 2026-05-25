# API СПО — Среднее профессиональное образование

> Часть [edu-framework](https://github.com/iMironRU/edu-framework) · Домен D12-digital  
> Версия API: **1.0** (2025) · Формат схем: **JSON Schema** (в отличие от ВУЗ — XSD)

---

## Ключевые отличия от API ВУЗ

| | ВУЗ | СПО |
|---|---|---|
| Формат схем | XSD | JSON Schema |
| Именование сущностей | `ApplicationList` | `spo_application_list` |
| Именование полей | `CamelCase` | `snake_case` |
| Операции | Add/Edit/GetBy/GetDirect/GetAll/Remove | add/edit/get_by/get_direct/get_all/remove |
| Вступительные испытания | `EntranceTestList` + `EntranceTestPlaceList` | `spo_entrance_test_schedule_list` (объединено) |
| Конкурсные группы | `CompetitiveGroupList` | нет — вместо них `spo_specialty_list` |

## Структура

```
spo/
├── README.md                  ← вы здесь
├── getting-started/           ← старт и авторизация (общая с ВУЗ)
├── scenarios/                 ← сценарии приёмной кампании СПО
├── reference/                 ← endpoint карточки
├── entities/                  ← описание объектов
└── classifiers/               ← классификаторы СПО
```

## Схемы

`../schemas-spo/` — все JSON Schema файлы  
Структура: `OwnSchemas/`, `DespatchSchemas/`, `ClsSchemas/`

## Сущности СПО

| Сущность | Аналог в ВУЗ | Операции |
|---|---|---|
| `spo_campaign_list` | `CampaignList` | add, edit, get_all, remove |
| `spo_specialty_list` | `OrgDirectionList` + `CompetitiveGroupList` | add, edit, get_all, remove |
| `spo_specialty_event_list` | `CampaignEventList` | add, edit, get_all, remove |
| `spo_application_list` | `ApplicationList` | add, get_all, get_direct |
| `spo_application_status_list` | `CompetitiveGroupStatusList` | edit |
| `spo_application_specialty_list` | часть `ApplicationList` | add, get_all |
| `spo_application_specialty_status_list` | `CompetitiveGroupStatusList` | edit |
| `spo_application_benefit_list` | `CompetitiveGroupBenefitList` | add, edit, get_by |
| `spo_application_achievement_list` | `CompetitiveGroupAchievementList` | add, edit |
| `spo_document_list` | `DocumentList` | add, edit, get_by, get_direct |
| `spo_entrant_list` | `EntrantList` | get_all, get_by, get_direct |
| `spo_entrant_identification_list` | часть `EntrantList` | add, edit |
| `spo_entrance_test_schedule_list` | `EntranceTestList` + `EntranceTestPlaceList` | add, edit, get_by, get_direct, remove |
| `spo_consent_to_enroll_list` | `ConsentToEnrollList` | get_by, get_direct |
| `spo_original_education_document_list` | — | add, get_direct |
| `spo_addition_info_list` | — | add, edit |
| `spo_ranked_competition_list_package` | `RankedCompetitionListPackage` | add, get_direct |

## Despatch события СПО

| Событие | Аналог в ВУЗ |
|---|---|
| `spo_epgu_application` | `EpguApplication` |
| `spo_epgu_application_cancel` | `EpguApplicationCancel` |
| `spo_epgu_consent_to_enroll` | `EpguConsentToEnroll` |
| `spo_epgu_additional_information` | — (новое) |
| `spo_sp_application_status` | — (новое, из СП) |
| `spo_sp_application_specialty_status` | — (новое, из СП) |
| `spo_sp_document_change` | `DocumentChange` |
