# Сущности API

## Граф зависимостей

```
CampaignList
    ├── CampaignEventList (сроки приёма)
    └── CompetitionList
            └── CompetitiveGroupList
                    ├── EntranceTestList
                    ├── EntranceTestPlaceList
                    ├── CompetitiveGroupBenefitList
                    └── CompetitiveGroupAchievementList

ApplicationList
    ├── EntrantList
    ├── DocumentList
    ├── ConsentToEnrollList
    ├── CompetitiveGroupStatusList
    ├── EntrantPriorityList
    └── EntranceTestAgreedList / EntranceTestResultList

OrgDirectionList → EducationalProgramList → CompetitiveGroupList
DictionaryValueList
```

## Карточки сущностей

| Сущность | Карточка |
|---|---|
| Заявление | [application.md](application.md) |
| Поступающий | [entrant.md](entrant.md) |
| Приёмная кампания | [campaign.md](campaign.md) |
| Конкурс | [competition.md](competition.md) |
| Конкурсная группа | [competitive-group.md](competitive-group.md) |
| Документы | [document.md](document.md) |
| Согласие на зачисление | [consent-to-enroll.md](consent-to-enroll.md) |
