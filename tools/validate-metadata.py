#!/usr/bin/env python3
"""
validate-metadata.py — валидатор metadata.yml для доменов фреймворка ОО.
Использование: python tools/validate-metadata.py domains/D05-contingent/metadata.yml
"""

import sys
import yaml
from pathlib import Path

REQUIRED_FIELDS = [
    "id", "title", "slug", "cluster", "version", "status",
    "applicability", "typical_owner", "last_reviewed", "review_cycle_months"
]
VALID_CLUSTERS = {"regulatory","core","staff-science","support","external","crosscutting"}
VALID_STATUSES = {"draft","review","stable","deprecated"}
VALID_APPLICABILITY = {"required","partial","not-applicable"}
VALID_ORG_TYPES = {"vuz","spo","do","dpo","aspirantura"}
VALID_DOMAIN_IDS = {f"D{i:02d}" for i in range(1,14)}

def validate(path):
    p = Path(path)
    if not p.exists():
        print(f"Файл не найден: {path}"); return False
    with open(p, encoding="utf-8") as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"  ❌ Невалидный YAML: {e}"); return False

    errors = 0
    print(f"\nВалидация: {path}\n" + "─"*50)

    for field in REQUIRED_FIELDS:
        if field not in data or data[field] is None:
            print(f"  ❌ Отсутствует: {field}"); errors += 1
        else:
            print(f"  ✓  {field}: {str(data[field])[:60]}")

    if errors:
        print(f"\n{errors} критических ошибок."); return False

    print("\nПроверка значений:")
    if data.get("id") not in VALID_DOMAIN_IDS:
        print(f"  ❌ id должен быть D01–D13"); errors += 1
    if data.get("cluster") not in VALID_CLUSTERS:
        print(f"  ❌ cluster: '{data.get('cluster')}' не из допустимых"); errors += 1
    if data.get("status") not in VALID_STATUSES:
        print(f"  ❌ status: '{data.get('status')}' не из допустимых"); errors += 1

    app = data.get("applicability", {})
    if isinstance(app, dict):
        for ot in VALID_ORG_TYPES:
            v = app.get(ot)
            if v not in VALID_APPLICABILITY:
                print(f"  ❌ applicability.{ot}='{v}' не из допустимых"); errors += 1
    else:
        print(f"  ❌ applicability должен быть объектом"); errors += 1

    print("\nЖелательные поля:")
    for f in ["short_title","regulatory_refs","authors","tags"]:
        if not data.get(f):
            print(f"  ⚠️  {f} не заполнен")
        else:
            print(f"  ✓  {f} заполнен")

    print("\n" + "─"*50)
    if errors == 0:
        print(f"✅ Валидация прошла успешно"); return True
    else:
        print(f"❌ Ошибок: {errors}"); return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Использование: python tools/validate-metadata.py <путь к metadata.yml>")
        sys.exit(1)
    sys.exit(0 if validate(sys.argv[1]) else 1)
