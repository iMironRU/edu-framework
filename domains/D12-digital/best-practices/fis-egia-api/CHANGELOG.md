# Changelog API ФИС ГИА и Приём

Формат: для каждой версии фиксируем изменения схем с указанием **было → стало**.

---

## v3.5.0 — 2025 (текущая)

> Схемы обновлены. Сравнение выполнено автоматически между v3.4.0 и v3.5.0.

---

### 🆕 Новое: поддержка иностранных абитуриентов

Ключевое изменение кампании 2025 — расширенная работа с иностранными гражданами и рекрутерами.

**Новый классификатор `RecruiterCls`** — справочник рекрутёров, через которых поступают иностранные абитуриенты. Поля: `Id`, `Name`, `Actual`, `IdOksm` (страна).

Новое поле `ForeignerEntrantInfo` добавлено в `EpguApplication`, `EpguApplicationChange`, `PersonProfileChange`, `EntrantList/GetDirect.Response`:

| Поле | Тип | Описание |
|---|---|---|
| `IdCitizenShipCountry` | Int4Type | Гражданство → `OksmCls` |
| `IdInviteCountry` | Int4Type | Страна получения визы → `OksmCls` |
| `InviteCity` | String256Type | Город для оформления приглашения |
| `InviteAddress` | String256Type | Адрес для приглашения на обучение |
| `IdRecruter` | BigIntType | → `RecruiterCls.Id` |

---

### ⚠️ Breaking changes — требуют изменений в коде

**1. NeedHostel стал массивом** (заявление, ApplicationList)

```
БЫЛО: <NeedHostel>true</NeedHostel>   — boolean, один вуз
СТАЛО: <NeedHostelList>
         <Organization>
           <Ogrn>...</Ogrn>
           <Kpp>...</Kpp>
         </Organization>
       </NeedHostelList>              — список вузов с потребностью в общежитии
```

Затронуто: `EpguApplication`, `EpguApplicationChange`, `ApplicationList/GetDirect.Response`

**Что делать:** заменить обработку булевого поля на парсинг/формирование списка организаций.

---

**2. CostOfStudy разделён на два поля** (CompetitionList/Add)

```
БЫЛО: CostOfStudy — единая стоимость обучения
СТАЛО:
  CostOfStudyRf         [required] — для граждан РФ
  CostOfStudyForeigner  [required] — для иностранных граждан
```

**Что делать:** передавать оба поля при создании конкурса. Оба обязательные.

---

**3. EntranceTestPlaceList/Add — изменился набор полей**

```
БЫЛО: ReserveDate — признак резервной даты (boolean)
СТАЛО: IsReserveDate — то же, но переименовано
ДОБАВЛЕНО:
  IdEducationLevelGroup [required] — Группа уровня образования → EducationLevelGroupCls
  IdStageAdmission      [required] — Этап приема → StagesAdmissionCls
  IsNewTerritories      [required] — Признак «Для новых территорий»
```

**Что делать:** переименовать поле + добавить три новых обязательных поля.

---

**4. EntranceTestResultList/Add — новые обязательные поля**

```
ДОБАВЛЕНО:
  IdStageAdmission      [required] — Этап приема → StagesAdmissionCls
  IdEducationLevelGroup [required] — Группа уровней образования → EducationLevelGroupCls
```

**Что делать:** добавить оба поля при внесении результатов ВИ.

---

**5. NoticeList/Add — изменилась логика уведомлений**

```
БЫЛО:
  IdDocument [required] — ID документа
  Comment    [required] — Комментарий

СТАЛО:
  RequestDocument  [required] — тип уведомления «запрос документа»
  RequestMessage   [required, String2000Type] — сообщение для поступающего
  Comment          [optional] — Комментарий стал необязательным
```

**Что делать:** перестроить формирование уведомлений — теперь структура зависит от типа.

---

### ✏️ Некритичные изменения типов (расширение длины строк)

| Поле | Было | Стало | Где |
|---|---|---|---|
| `Phone` | String120Type (120 символов) | String256Type (256) | EntrantList, EpguApplication |
| `DocOrganization` | String256Type (256) | String1000Type (1000) | EntrantList, LkDocument |
| `Name` (ОП) | String255Type (255) | String500Type (500) | EducationalProgramList/Add |
| `Surname` | String255Type | String256Type | EntrantList |
| `Name` (абитуриент) | String255Type | String256Type | EntrantList |

Обратно совместимы — старые данные не сломаются, но новые могут быть длиннее.

---

### 🆕 Новые события Despatch: Lk* (из Личного кабинета ФИС)

Полностью новая группа событий — фиксирует действия операторов вуза через веб-интерфейс ЛК Сервиса приёма. Нужна если система вуза должна знать об изменениях, внесённых напрямую через ЛК (а не через API).

| Событие | Описание |
|---|---|
| `LkApplication` | Заявление, внесённое оператором через ЛК |
| `LkCompetitiveGroup` | КГ заявления, изменённая через ЛК (статус, приоритеты) |
| `LkCompetitiveGroupAchievement` | Баллы за ИД, назначенные через ЛК |
| `LkCompetitiveGroupBenefit` | Особые права, учтённые через ЛК |
| `LkCompetitiveGroupStatus` | Статус КГ, выставленный через ЛК |
| `LkConsentToEnroll` | Согласие на зачисление, поданное через ЛК |
| `LkDocument` | Документ, добавленный/изменённый через ЛК |
| `LkEntranceTestResult` | Результат ВИ, внесённый через ЛК |
| `LkEntrantPriority` | Приоритеты абитуриента, изменённые через ЛК |
| `LkLegalGuardianConsent` | Согласие законного представителя через ЛК |
| `LkTestAgreed` | Запись на ВИ, оформленная через ЛК |

Схемы: `schemas/DespatchXsd/Lk*/`

**Что делать:** добавить обработчики этих событий в polling `despatch/get` если нужна синхронизация с изменениями через ЛК.

---

### 🆕 Новая сущность: PlaceDistributionList

Распределение контрольных цифр приёма (КЦП) по направлениям. Только чтение (`GetAll`).

Поля ответа:
- `IdDirection` → `DirectionCls`
- `IdEducationForm` → `EducationFormCls`
- `NumberPlacesMinistry` — КЦП, выделенное министерством
- `PlaceList` — распределение вузом по типам мест (`PlaceTypeCls`)
- `TargetNumberPlacesList` — кадровая целевая потребность по организациям

---

### 🆕 Новые операции: TargetContractList

Добавлены `GetBy` / `GetBy.Response` — теперь можно запрашивать целевые договора по критериям (раньше только `GetDirect`).

Ответ содержит `ContractList` с номерами предложений (`OfferNumber`) по КГ заявления.

---

### 🗑️ Удалено из API (схемы исчезли)

Внимание: схемы удалены — операции недоступны. Уточнить в тех. поддержке причину.

| Удалённая схема | Что делала |
|---|---|
| `OwnXsd/ApplicationList/Add`, `Add.Response`, `Edit` | Создание/редактирование заявлений |
| `OwnXsd/CampaignList/*` (все операции) | Управление приёмными кампаниями |
| `OwnXsd/CampaignEventList/*` | Контрольные мероприятия |
| `OwnXsd/CompetitionList/Edit`, `Remove` | Редактирование и удаление конкурсов |
| `OwnXsd/CompetitiveGroupList/Add`, `Add.Response`, `Edit` | Создание/редактирование КГ |
| `OwnXsd/CompetitiveGroupBenefitList/Add`, `Edit` | Льготы КГ |
| `OwnXsd/CompetitiveGroupStatusList/Edit` | Статусы КГ |
| `OwnXsd/EntrantList/Edit`, `Edit.Response` | Редактирование профиля поступающего |
| `OwnXsd/EntrantPriorityList/Edit` | Приоритеты поступающего |
| `OwnXsd/DocumentList/Add`, `Add.Response`, `Edit` | Документы поступающего |
| `OwnXsd/OrgDirectionList/*` (все операции) | Справочник НП организации |
| `OwnXsd/EducationalProgramList/Edit`, `Remove` | Образовательные программы |
| `OwnXsd/EntranceTestList/Edit`, `Remove` | Вступительные испытания |
| `OwnXsd/EntranceTestMagistraturaAgreedList/*` | Запись на ВИ магистратуры |
| `OwnXsd/EntranceTestMagistraturaResultList/*` | Результаты ВИ магистратуры |
| `OwnXsd/LegalGuardianConsentList/Add` | Согласие законного представителя |
| `OwnXsd/DictionaryValueList/Edit`, `Remove` | Справочники вуза |
| `OwnXsd/CareerEventList/Edit` | Карьерные мероприятия |
| `OwnXsd/PaidContractCancel/Add` | Отмена платного договора |
| `OwnXsd/TargetContractList/GetDirect`, `GetDirect.Response` | Целевые договора (заменены на GetBy) |

> Вероятно, часть операций переведена в режим «только через ЛК» — отсюда и новые Lk* despatch-события.

---

### 🆕 Добавлен API СПО (Среднее профессиональное образование)

Совершенно новый контур — `schemas-spo/`. Формат схем **JSON Schema** вместо XSD.

Сущности СПО:

| Сущность | Операции |
|---|---|
| `spo_campaign_list` | add, edit, get_all, remove |
| `spo_application_list` | add, get_all, get_direct |
| `spo_application_status_list` | edit |
| `spo_application_specialty_list` | add, get_all |
| `spo_application_specialty_status_list` | edit |
| `spo_application_benefit_list` | add, edit, get_by |
| `spo_application_achievement_list` | add, edit |
| `spo_document_list` | add, edit, get_by, get_direct |
| `spo_entrant_list` | get_all, get_by, get_direct |
| `spo_entrant_identification_list` | add, edit |
| `spo_specialty_list` | add, edit, get_all, remove |
| `spo_specialty_event_list` | add, edit, get_all, remove |
| `spo_entrance_test_schedule_list` | add, edit, get_by, get_direct, remove |
| `spo_consent_to_enroll_list` | get_by, get_direct |
| `spo_original_education_document_list` | add, get_direct |
| `spo_addition_info_list` | add, edit |
| `spo_ranked_competition_list_package` | add, get_direct |

Despatch события СПО:
- `spo_epgu_application` — заявление с ЕПГУ
- `spo_epgu_application_cancel` — отмена заявления
- `spo_epgu_consent_to_enroll` — согласие на зачисление
- `spo_epgu_additional_information` — доп. информация
- `spo_sp_application_status` — статус заявления из СП
- `spo_sp_application_specialty_status` — статус специальности
- `spo_sp_document_change` — изменение документа

Документация СПО: `schemas-spo/` · PDF: `source-docs/`

---

## v3.4.0 — май 2025

### Сломало интеграцию ⚠️

**RankedCompetitionListPackage/PackageBodyFile.xsd**

Поля `EntranceTest1`, `EntranceTest2`, `EntranceTest3` стали обязательными.

```xml
<!-- БЫЛО minOccurs="0" → СТАЛО обязательными -->
<xs:element type="String255Type" name="EntranceTest1">
```

### Добавлен статус «Отозвано поступающим» в статусной модели заявления.
