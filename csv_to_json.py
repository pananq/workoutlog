#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
将 Apple 健身/运动导出的 CSV 转换为 Cal-Heatmap 所需的 JSON：
- 将每天的记录按“运动类型”汇总，选择当日总时长最长的类型作为该天的值
- 类型到等级（legend）的映射：
  1: HIIT (highIntensityIntervalTraining)
  2: Swimming (swimming)
  3: Soccer (soccer)
  4: Surfskate (skatingSports)
  5: Others（不在 1..4 映射内的其它类型，如 walking/hiking/cycling/paddleSports 等）
- 输出形如：{"1735689600": 3, ...}，key 为当天 00:00 的时间戳（秒）

使用示例：
python3 csv_to_json.py \
  --csv "/Users/pananq/微云同步助手(15313697)/workoutlog/workout_export_1760013031.98248.csv" \
  --year 2025 \
  --out "/Users/pananq/微云同步助手(15313697)/workoutlog/2025.json"
"""

import argparse
import csv
import json
import os
from collections import defaultdict
from datetime import datetime, date, time as dtime
import time

# 中文表头（与示例CSV一致）
COL_START = "开始时间"
COL_END = "结束时间"
COL_DURATION_MIN = "持续时间(分钟)"
COL_TYPE = "健身类型"
# 其余字段可忽略

# 归一化别名映射（小写比较）
TYPE_ALIAS = {
    # 核心四类
    "highintensityintervaltraining": "hiit",
    "hiit": "hiit",
    "swimming": "swimming",
    "soccer": "soccer",
    "skatingsports": "surfskate",  # Apple 的“轮滑/滑板类”归为 Surfskate
    "surfskate": "surfskate",

    # 常见其它类型（都归为 others）
    "walking": "others",
    "hiking": "others",
    "cycling": "others",
    "paddlesports": "others",
}

# 类型到 legend 等级映射（与 workout.html 中 legendDesc 顺序一致）
LEGEND_MAP = {
    "hiit": 1,
    "swimming": 2,
    "soccer": 3,
    "surfskate": 4,
    # 其它类型一律 5，用于落在 legend 的第 5 档（>4）
    "others": 5,
}

# 当天出现多条记录时的合并策略：
# - 将同日同类型的“持续时间(分钟)”累加
# - 取总时长最大的类型作为该天类别
# - 并列时按优先级：HIIT > Swimming > Soccer > Surfskate > Others
PRIORITY = ["hiit", "swimming", "soccer", "surfskate", "others"]
PRIORITY_INDEX = {t: i for i, t in enumerate(PRIORITY)}


def parse_args():
    parser = argparse.ArgumentParser(description="Convert workout CSV to Cal-Heatmap JSON by type legend (1..4, others=5)")
    parser.add_argument("--csv", required=True, help="输入CSV文件路径（含中文表头）")
    parser.add_argument("--year", type=int, default=datetime.now().year, help="目标年份，仅保留该年份的数据，默认当年")
    parser.add_argument("--out", default=None, help="输出JSON路径，默认与CSV同目录下的 <year>.json")
    return parser.parse_args()


def normalize_type(raw: str) -> str:
    if not raw:
        return "others"
    key = str(raw).strip().lower()
    return TYPE_ALIAS.get(key, "others")


def date_epoch_seconds(dt: date) -> int:
    # 使用本地时区的 00:00:00 对应的时间戳（秒）
    local_midnight = datetime.combine(dt, dtime.min)
    return int(time.mktime(local_midnight.timetuple()))


def choose_type_by_duration(type_minutes: dict) -> str:
    # 选择总时长最大的类型；并列按 PRIORITY 顺序
    if not type_minutes:
        return "others"
    # 排序：先按分钟降序，再按优先级
    return sorted(
        type_minutes.items(),
        key=lambda kv: (-kv[1], PRIORITY_INDEX.get(kv[0], len(PRIORITY)))
    )[0][0]


def convert(csv_path: str, year: int) -> dict:
    per_day_type_minutes = defaultdict(lambda: defaultdict(float))

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        # 校验列
        for col in [COL_START, COL_DURATION_MIN, COL_TYPE]:
            if col not in reader.fieldnames:
                raise ValueError(f"CSV缺少必要列: {col}，当前列: {reader.fieldnames}")

        for row in reader:
            start_str = (row.get(COL_START) or "").strip()
            type_str = (row.get(COL_TYPE) or "").strip()
            dur_str = (row.get(COL_DURATION_MIN) or "0").strip()

            if not start_str:
                continue
            try:
                # 解析开始时间（形如 2025-10-08 19:58:11）
                dt = datetime.strptime(start_str, "%Y-%m-%d %H:%M:%S")
            except ValueError:
                # 容错：尝试少数格式
                try:
                    dt = datetime.fromisoformat(start_str)
                except Exception:
                    continue

            if dt.year != year:
                continue

            day_key = dt.date()
            tnorm = normalize_type(type_str)

            try:
                minutes = float(dur_str)
            except ValueError:
                minutes = 0.0

            per_day_type_minutes[day_key][tnorm] += minutes

    # 生成结果：当日取最佳类型，并映射为 legend 等级
    result = {}
    for day, type_minutes in per_day_type_minutes.items():
        chosen = choose_type_by_duration(type_minutes)
        result[str(date_epoch_seconds(day))] = LEGEND_MAP.get(chosen, 5)

    return result


def main():
    args = parse_args()
    out_path = args.out
    if not out_path:
        out_path = os.path.join(os.path.dirname(os.path.abspath(args.csv)), f"{args.year}.json")

    data = convert(args.csv, args.year)

    # 按时间排序输出（可读性更好）
    ordered = dict(sorted(((int(k), v) for k, v in data.items()), key=lambda kv: kv[0]))
    # key 需要是字符串
    ordered_str_key = {str(k): v for k, v in ordered.items()}

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(ordered_str_key, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")

    print(f"已生成: {out_path}，条目数: {len(ordered_str_key)}")


if __name__ == "__main__":
    main()
