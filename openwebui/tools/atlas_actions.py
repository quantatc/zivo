"""
title: Atlas Actions
author: Zivo
author_url: https://zivo.tafarax.com
description: Mutating actions on Atlas Operations data — review transactions, open investigation cases, draft vendor emails, trigger n8n workflows.
required_open_webui_version: 0.4.0
requirements: httpx
version: 0.1.0
license: MIT
"""

from __future__ import annotations

import httpx
from pydantic import BaseModel, Field


class Tools:
    class Valves(BaseModel):
        atlas_api_url: str = Field(
            default="http://atlas-api:8000",
            description="Base URL of the atlas-api service.",
        )
        timeout_seconds: float = Field(default=30.0)

    def __init__(self) -> None:
        self.valves = self.Valves()

    def _post(self, path: str, json: dict | None = None) -> dict | list:
        url = f"{self.valves.atlas_api_url.rstrip('/')}{path}"
        with httpx.Client(timeout=self.valves.timeout_seconds) as client:
            r = client.post(url, json=json or {})
            r.raise_for_status()
            return r.json()

    # ---- LLM-exposed tools --------------------------------------------------
    def mark_transaction_reviewed(
        self,
        transaction_id: int,
        reviewer: str,
        note: str,
        mark_resolved: bool = False,
    ) -> dict:
        """
        Record a reviewer's note on a transaction. Optionally clear the flagged bit.

        :param transaction_id: The transaction ID.
        :param reviewer: Name or email of the reviewer (e.g. 'maya.chen').
        :param note: Reviewer's notes.
        :param mark_resolved: If True, also un-flag the transaction.
        """
        return self._post(
            f"/transactions/{transaction_id}/review",
            {"reviewer": reviewer, "note": note, "mark_resolved": mark_resolved},
        )

    def create_investigation_case(
        self,
        transaction_id: int,
        notes: str,
        opened_by: str = "open-webui",
    ) -> dict:
        """
        Open an investigation case against a flagged transaction.

        Always summarize what the case will record and confirm with the user before calling this.

        :param transaction_id: The transaction the case is about.
        :param notes: Case notes — what was found, why it warrants investigation.
        :param opened_by: Owner identifier (default 'open-webui'; use the operator's name if known).
        """
        return self._post(
            "/cases",
            {"transaction_id": transaction_id, "notes": notes, "opened_by": opened_by},
        )

    def draft_vendor_email(
        self,
        vendor_id: int,
        topic: str,
        tone: str = "polite",
    ) -> dict:
        """
        Generate a short draft email to a vendor. Returns subject + body, with the vendor's contact email if on file.

        Always show the draft to the user and ask if they want to send it themselves — this tool only drafts, it does not send.

        :param vendor_id: Target vendor's ID.
        :param topic: What the email is about (e.g. 'late invoice 4471', 'expense limit exceeded').
        :param tone: 'polite', 'firm', or 'friendly'. Defaults to 'polite'.
        """
        return self._post(
            "/actions/draft-vendor-email",
            {"vendor_id": vendor_id, "topic": topic, "tone": tone},
        )

    def trigger_workflow(self, workflow_slug: str, payload: dict | None = None) -> dict:
        """
        Trigger an n8n workflow by its webhook slug.

        Available slugs in this demo:
          - 'fraud-policy-check' — runs an LLM policy check on a transaction payload.

        :param workflow_slug: The webhook slug.
        :param payload: JSON payload sent to the workflow.
        """
        return self._post(
            "/actions/trigger-workflow",
            {"workflow_slug": workflow_slug, "payload": payload or {}},
        )
