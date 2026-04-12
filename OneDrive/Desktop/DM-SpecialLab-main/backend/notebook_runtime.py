from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_NOTEBOOK_PATH = REPO_ROOT.parent / "C:\\Users\\Silas Carzon\\OneDrive\\Desktop\\Survey-Based Compatibility Matcher2.ipynb"


def _clean_code_cell(source: list[str]) -> str:
    lines = []
    for line in source:
        stripped = line.lstrip()
        if stripped.startswith("!"):
            continue
        lines.append(line)
    return "".join(lines)


@lru_cache(maxsize=1)
def load_notebook_namespace(notebook_path: str | None = None) -> dict[str, Any]:
    path = Path(notebook_path) if notebook_path else DEFAULT_NOTEBOOK_PATH
    notebook = json.loads(path.read_text(encoding="utf-8"))

    namespace: dict[str, Any] = {}
    for cell in notebook.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        code = _clean_code_cell(cell.get("source", []))
        if "results = run_similarity_pipeline(" in code:
            continue
        if not code.strip():
            continue
        exec(compile(code, str(path), "exec"), namespace)

    if "run_similarity_pipeline" not in namespace:
        raise RuntimeError("Notebook did not expose run_similarity_pipeline.")

    return namespace


def _pick_timestamp_column(df: pd.DataFrame) -> str | None:
    for candidate in ("Timestamp", "timestamp"):
        if candidate in df.columns:
            return candidate
    return None


def _safe_get(row: pd.Series, column_name: str | None) -> str:
    if not column_name or column_name not in row.index:
        return ""
    value = row[column_name]
    if pd.isna(value):
        return ""
    return str(value).strip()


def _to_dashboard_confidence(confidence_score: float) -> str:
    pct = confidence_score * 100
    if pct >= 85:
        return "High"
    if pct >= 60:
        return "Medium"
    return "Low"


def _average_pair_score(final_df: pd.DataFrame) -> float:
    names = final_df.index.tolist()
    scores = [
        float(final_df.loc[left, right])
        for index, left in enumerate(names)
        for right in names[index + 1 :]
    ]
    return round(float(np.mean(scores)), 4) if scores else 0.0


def run_notebook_pipeline(file_obj: Any) -> dict[str, Any]:
    namespace = load_notebook_namespace()
    return namespace["run_similarity_pipeline"](file_obj)


def build_dashboard_payload(results: dict[str, Any]) -> dict[str, Any]:
    namespace = load_notebook_namespace()
    question_columns = namespace["QUESTION_COLUMNS"]

    raw_df: pd.DataFrame = results["raw_df"]
    final_df: pd.DataFrame = results["final_df"]
    pair_report_df: pd.DataFrame = results["pair_report_df"]
    top_matches_df: pd.DataFrame = results["top_matches_df"]
    most_common_pair = results["most_common_pair"]
    least_common_pair = results["least_common_pair"]

    timestamp_column = _pick_timestamp_column(raw_df)

    participants = [
        {
            "timestamp": _safe_get(row, timestamp_column),
            "name": _safe_get(row, question_columns["name"]),
            "consent": _safe_get(row, question_columns["consent"]) or "Yes",
            "hobbies": _safe_get(row, question_columns["interests"][0]),
        }
        for _, row in raw_df.iterrows()
    ]

    pair_reports = [
        {
            "personA": row["Person A"],
            "personB": row["Person B"],
            "overallCommonalityScore": float(row["Overall Commonality Score"]),
            "categoryOverlap": float(row["Category Overlap"]),
            "mostCommonInterests": row["Most Common Interests"] or None,
            "mostCommonPersonalitySignals": row["Most Common Personality Signals"] or None,
            "pairConfidenceLabel": _to_dashboard_confidence(float(row["Pair Confidence Score"])),
            "qualitativeSummary": row["Sentence Insights"] or row["Interpretation"],
        }
        for _, row in pair_report_df.iterrows()
    ]

    top_matches = [
        {
            "person": row["Person"],
            "topMatchPerson": row["Most Common Match"],
            "score": float(row["Overall Commonality Score"]),
        }
        for _, row in top_matches_df[top_matches_df["Rank"] == 1].iterrows()
    ]

    insights = []
    if not pair_report_df.empty:
        strongest = pair_report_df.iloc[0]
        weakest = pair_report_df.iloc[-1]
        insights = [
            {
                "title": f"Most Common Pair Highlight — {strongest['Person A']} & {strongest['Person B']}",
                "subtitle": f"{float(strongest['Overall Commonality Score']) * 100:.1f}%",
                "text": strongest["Sentence Insights"] or strongest["Interpretation"],
            },
            {
                "title": f"Least Common Pair Highlight — {weakest['Person A']} & {weakest['Person B']}",
                "subtitle": f"{float(weakest['Overall Commonality Score']) * 100:.1f}%",
                "text": weakest["Sentence Insights"] or weakest["Interpretation"],
            },
        ]

        # Add Top Pair #2-#5 (next four highest after the strongest), if available.
        top_pairs = pair_report_df.head(5)
        for rank, (_, row) in enumerate(top_pairs.iterrows(), start=1):
            if rank == 1:
                continue  # strongest already included
            insights.append(
                {
                    "title": f"Top Pair #{rank} — {row['Person A']} & {row['Person B']}",
                    "subtitle": f"{float(row['Overall Commonality Score']) * 100:.1f}%",
                    "text": row["Sentence Insights"] or row["Interpretation"],
                }
            )

    return {
        "summary": {
            "totalParticipants": len(participants),
            "averageScore": _average_pair_score(final_df),
            "highConfidencePairsCount": sum(
                1 for report in pair_reports if report["overallCommonalityScore"] >= 0.5
            ),
            "mostCommonPair": {
                "personA": most_common_pair[0],
                "personB": most_common_pair[1],
                "score": round(float(most_common_pair[2]), 4),
            }
            if most_common_pair
            else {"personA": "-", "personB": "-", "score": 0.0},
            "leastCommonPair": {
                "personA": least_common_pair[0],
                "personB": least_common_pair[1],
                "score": round(float(least_common_pair[2]), 4),
            }
            if least_common_pair
            else {"personA": "-", "personB": "-", "score": 0.0},
        },
        "participants": participants,
        "matrixData": {
            "names": final_df.index.tolist(),
            "matrix": np.round(final_df.to_numpy(dtype=float), 4).tolist(),
        },
        "pairReports": pair_reports,
        "topMatches": top_matches,
        "insights": insights,
    }
