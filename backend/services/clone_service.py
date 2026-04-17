"""Service for cloning user data between users (admin only)."""
from typing import List, Optional
from sqlalchemy.orm import Session
from database.database import (
    SessionLocal, Transaction as DBTransaction, BudgetItem as DBBudgetItem,
    CreditCard as DBCreditCard, CreditCardPurchase as DBCreditCardPurchase,
    InstallmentPlan as DBInstallmentPlan, InstallmentScheduleItem as DBInstallmentScheduleItem,
    CreditCardStatement as DBCreditCardStatement, CreditCardPayment as DBCreditCardPayment,
    CreditCardPeriodConfig as DBCreditCardPeriodConfig,
)
from datetime import datetime


def _parse_month_year(fecha_str):
    """Extract (month, year) from a date string (DD/MM/YYYY or YYYY-MM-DD)."""
    try:
        if '/' in fecha_str:
            parts = fecha_str.split('/')
            return int(parts[1]), int(parts[2])
        else:
            parts = fecha_str.split('-')
            return int(parts[1]), int(parts[0])
    except (ValueError, IndexError):
        return None, None


def _in_month_range(month, year, start_month, start_year, end_month, end_year):
    """Check if (month, year) is within the inclusive range."""
    val = year * 12 + month
    lo = start_year * 12 + start_month
    hi = end_year * 12 + end_month
    return lo <= val <= hi


def clone_user_data(
    source_user_id: int,
    target_user_id: int,
    modules: List[str],
    clone_all: bool = True,
    start_month: Optional[int] = None,
    start_year: Optional[int] = None,
    end_month: Optional[int] = None,
    end_year: Optional[int] = None,
) -> dict:
    """
    Clone data from source_user to target_user.

    modules: list of module names to clone: 'transactions', 'budget_items', 'credit_cards'
    clone_all: if False, filter by month range using start/end month/year.
    
    Returns a summary dict with counts per module.
    """
    db = SessionLocal()
    try:
        result = {
            "transactions_cloned": 0,
            "budget_items_cloned": 0,
            "credit_cards_cloned": 0,
            "purchases_cloned": 0,
        }

        # Maps from old IDs to new IDs (for preserving relationships)
        budget_item_id_map = {}  # old_budget_item_id -> new_budget_item_id
        card_id_map = {}  # old_card_id -> new_card_id
        purchase_id_map = {}  # old_purchase_id -> new_purchase_id
        plan_id_map = {}  # old_plan_id -> new_plan_id
        transaction_id_map = {}  # old_transaction_id -> new_transaction_id

        # ── 1. Clone budget items first (transactions reference them via debt_id) ──
        if "budget_items" in modules:
            items = db.query(DBBudgetItem).filter(DBBudgetItem.user_id == source_user_id).all()
            for item in items:
                if not clone_all:
                    m, y = _parse_month_year(item.fecha_vencimiento)
                    if m is None or not _in_month_range(m, y, start_month, start_year, end_month, end_year):
                        continue

                new_item = DBBudgetItem(
                    user_id=target_user_id,
                    fecha=item.fecha,
                    tipo=item.tipo,
                    categoria=item.categoria,
                    monto_total=item.monto_total,
                    monto_pagado=0.0,
                    detalle=item.detalle,
                    fecha_vencimiento=item.fecha_vencimiento,
                    status="PENDIENTE",
                    tipo_presupuesto=item.tipo_presupuesto,
                    tipo_flujo=item.tipo_flujo,
                    monto_ejecutado=0.0,
                    estimated_payment=item.estimated_payment if item.estimated_payment is not None else item.monto_total,
                )
                db.add(new_item)
                db.flush()
                budget_item_id_map[item.id] = new_item.id
                result["budget_items_cloned"] += 1

        # ── 2. Clone transactions ──
        if "transactions" in modules:
            txns = db.query(DBTransaction).filter(DBTransaction.user_id == source_user_id).all()
            for txn in txns:
                if not clone_all:
                    m, y = _parse_month_year(txn.date)
                    if m is None or not _in_month_range(m, y, start_month, start_year, end_month, end_year):
                        continue

                new_txn = DBTransaction(
                    user_id=target_user_id,
                    date=txn.date,
                    type=txn.type,
                    category_id=txn.category_id,
                    amount=txn.amount,
                    necessity=txn.necessity,
                    payment_method=txn.payment_method,
                    detail=txn.detail,
                    debt_id=budget_item_id_map.get(txn.debt_id) if txn.debt_id else None,
                    assignment_status=txn.assignment_status,
                )
                db.add(new_txn)
                db.flush()
                transaction_id_map[txn.id] = new_txn.id
                result["transactions_cloned"] += 1

        # ── 3. Clone credit cards and related data ──
        if "credit_cards" in modules:
            cards = db.query(DBCreditCard).filter(DBCreditCard.user_id == source_user_id).all()
            # Get existing card names for the target user to avoid duplicates
            existing_names = {
                c.card_name for c in
                db.query(DBCreditCard.card_name).filter(DBCreditCard.user_id == target_user_id).all()
            }
            for card in cards:
                # Generate a unique card name for the target user
                base_name = card.card_name
                new_name = base_name
                counter = 2
                while new_name in existing_names:
                    new_name = f"{base_name} ({counter})"
                    counter += 1
                existing_names.add(new_name)

                new_card = DBCreditCard(
                    user_id=target_user_id,
                    card_name=new_name,
                    bank_name=card.bank_name,
                    closing_day=card.closing_day,
                    due_day=card.due_day,
                    currency=card.currency,
                    credit_limit=card.credit_limit,
                    is_active=card.is_active,
                    notes=card.notes,
                )
                db.add(new_card)
                db.flush()
                card_id_map[card.id] = new_card.id
                result["credit_cards_cloned"] += 1

                # Clone period configs for this card
                configs = db.query(DBCreditCardPeriodConfig).filter(
                    DBCreditCardPeriodConfig.card_id == card.id
                ).all()
                for cfg in configs:
                    if not clone_all and not _in_month_range(cfg.month, cfg.year, start_month, start_year, end_month, end_year):
                        continue
                    db.add(DBCreditCardPeriodConfig(
                        card_id=new_card.id,
                        year=cfg.year,
                        month=cfg.month,
                        closing_day=cfg.closing_day,
                        due_day=cfg.due_day,
                    ))

                # Clone purchases for this card
                purchases = db.query(DBCreditCardPurchase).filter(
                    DBCreditCardPurchase.card_id == card.id
                ).all()
                for purchase in purchases:
                    if not clone_all:
                        p_month = purchase.purchase_date.month
                        p_year = purchase.purchase_date.year
                        if not _in_month_range(p_month, p_year, start_month, start_year, end_month, end_year):
                            continue

                    new_purchase = DBCreditCardPurchase(
                        card_id=new_card.id,
                        transaction_id=transaction_id_map.get(purchase.transaction_id) if purchase.transaction_id else None,
                        purchase_date=purchase.purchase_date,
                        total_amount=purchase.total_amount,
                        category=purchase.category,
                        description=purchase.description,
                        installments=purchase.installments,
                        has_financing=purchase.has_financing,
                        currency=purchase.currency,
                        exchange_rate=purchase.exchange_rate,
                        amount_in_pesos=purchase.amount_in_pesos,
                    )
                    db.add(new_purchase)
                    db.flush()
                    purchase_id_map[purchase.id] = new_purchase.id
                    result["purchases_cloned"] += 1

                    # Clone installment plan for this purchase
                    plan = db.query(DBInstallmentPlan).filter(
                        DBInstallmentPlan.purchase_id == purchase.id
                    ).first()
                    if plan:
                        new_plan = DBInstallmentPlan(
                            purchase_id=new_purchase.id,
                            debt_id=budget_item_id_map.get(plan.debt_id) if plan.debt_id else None,
                            total_amount=plan.total_amount,
                            number_of_installments=plan.number_of_installments,
                            interest_rate=plan.interest_rate,
                            start_date=plan.start_date,
                            plan_type=plan.plan_type,
                            notes=plan.notes,
                        )
                        db.add(new_plan)
                        db.flush()
                        plan_id_map[plan.id] = new_plan.id

                        # Clone schedule items
                        schedule_items = db.query(DBInstallmentScheduleItem).filter(
                            DBInstallmentScheduleItem.plan_id == plan.id
                        ).all()
                        for si in schedule_items:
                            db.add(DBInstallmentScheduleItem(
                                plan_id=new_plan.id,
                                installment_number=si.installment_number,
                                due_date=si.due_date,
                                principal_amount=si.principal_amount,
                                interest_amount=si.interest_amount,
                                total_installment_amount=si.total_installment_amount,
                                status="PENDING",
                                notes=si.notes,
                            ))

                # Clone statements for this card
                statements = db.query(DBCreditCardStatement).filter(
                    DBCreditCardStatement.card_id == card.id
                ).all()
                for stmt in statements:
                    if not clone_all:
                        s_month = stmt.period_start.month
                        s_year = stmt.period_start.year
                        if not _in_month_range(s_month, s_year, start_month, start_year, end_month, end_year):
                            continue
                    db.add(DBCreditCardStatement(
                        card_id=new_card.id,
                        period_start=stmt.period_start,
                        period_end=stmt.period_end,
                        statement_date=stmt.statement_date,
                        due_date=stmt.due_date,
                        previous_balance=stmt.previous_balance,
                        total_purchases=stmt.total_purchases,
                        total_installments=stmt.total_installments,
                        total_interest=stmt.total_interest,
                        total_fees=stmt.total_fees,
                        total_taxes=stmt.total_taxes,
                        total_credits=stmt.total_credits,
                        total_amount=stmt.total_amount,
                        minimum_payment=stmt.minimum_payment,
                        paid_amount=0.0,
                        status="PENDING",
                        notes=stmt.notes,
                    ))

        db.commit()
        return result
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
