# Модель данных — D12: Цифровая инфраструктура и интеграции

## Обзор

Домен D12 не хранит бизнес-данные — он описывает **каналы и протоколы** обмена.
Ключевые сущности здесь — это объекты, которыми оперирует API ФИС ГИА при передаче
данных из ОО в государственные ГИС и обратно.

## Сущности ФИС ГИА (ВО, API v3.5.0)

| Сущность | Описание | Операции |
|---|---|---|
| `CampaignList` | Приёмные кампании ОО | Add, Edit, GetAll, Remove |
| `OrgDirectionList` | Направления подготовки (ОПОП) | Add, Edit, GetAll, Remove |
| `CompetitiveGroupList` | Конкурсные группы | GetAll, GetBy, GetDirect |
| `ApplicationList` | Заявления поступающих | Add, GetAll, GetDirect |
| `EntrantList` | Поступающие (физлица) | GetAll, GetBy, GetDirect |
| `DocumentList` | Документы поступающих | GetBy, GetDirect |
| `EntranceTestList` | Вступительные испытания | Add, GetBy, GetDirect |
| `EntranceTestPlaceList` | Места проведения испытаний | Add, Edit, GetBy, GetDirect, Remove |
| `EntranceTestResultList` | Результаты испытаний | Add, Edit, GetBy |
| `ConsentToEnrollList` | Согласия на зачисление | GetBy, GetDirect |
| `RankedCompetitionListPackage` | Ранжированные списки (пакет) | Add, GetDirect |
| `CompetitionList` | Конкурсные списки | Add, GetAll, GetDirect |
| `OrderList` | Приказы о зачислении | Edit |
| `NoticeList` | Уведомления | Add, GetBy, GetDirect |
| `EgeResultList` | Результаты ЕГЭ | GetDirect |
| `TargetContractList` | Целевые договоры | GetBy |

## Сущности ФИС ГИА (СПО, API v1.0)

| Сущность | Аналог ВО | Операции |
|---|---|---|
| `spo_campaign_list` | `CampaignList` | add, edit, get_all, remove |
| `spo_specialty_list` | `OrgDirectionList` + `CompetitiveGroupList` | add, edit, get_all, remove |
| `spo_specialty_event_list` | `CampaignEventList` | add, edit, get_all, remove |
| `spo_application_list` | `ApplicationList` | add, get_all, get_direct |
| `spo_entrant_list` | `EntrantList` | get_all, get_by, get_direct |
| `spo_document_list` | `DocumentList` | add, edit, get_by, get_direct |
| `spo_entrance_test_schedule_list` | `EntranceTestList` + `EntranceTestPlaceList` | add, edit, get_by, get_direct, remove |
| `spo_consent_to_enroll_list` | `ConsentToEnrollList` | get_by, get_direct |
| `spo_ranked_competition_list_package` | `RankedCompetitionListPackage` | add, get_direct |
| `spo_application_status_list` | `CompetitiveGroupStatusList` | edit |

## Объекты авторизации и сессий

| Объект | Описание |
|---|---|
| `Token-Header` | JSON с ОГРН, КПП, Month — кодируется в Base64 |
| `Session-Key` | Сессионный ключ, действует 12 часов |
| `IdJwt` | Идентификатор асинхронной операции |
| `payload_base64` | XML (ВО) или JSON (СПО), закодированный в Base64 |
| `signature_base64` | Подпись по ГОСТ 34.10-2012 в формате detached PKCS#7 |

## Despatch-события (входящие от ФИС)

| Событие (ВО) | Событие (СПО) | Источник |
|---|---|---|
| `EpguApplication` | `spo_epgu_application` | Заявление с ЕПГУ |
| `EpguApplicationCancel` | `spo_epgu_application_cancel` | Отзыв заявления с ЕПГУ |
| `EpguConsentToEnroll` | `spo_epgu_consent_to_enroll` | Согласие на зачисление с ЕПГУ |
| `DocumentChange` | `spo_sp_document_change` | Изменение документа в СП |
| — | `spo_epgu_additional_information` | Доп. сведения (только СПО) |
| — | `spo_sp_application_status` | Статус заявления из СП (только СПО) |

## Схемы

Все схемы размещены внутри домена D12:

| Тип | Путь | Описание |
|---|---|---|
| XSD (ВО) | `best-practices/fis-egia-api/schemas/` | 168 файлов: OwnXsd, DespatchXsd, ClsXsd |
| JSON Schema (СПО) | `best-practices/fis-egia-api/schemas-spo/` | 98 файлов: OwnSchemas, DespatchSchemas, ClsSchemas |
