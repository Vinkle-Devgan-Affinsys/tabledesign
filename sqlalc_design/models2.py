from sqlalchemy import (
    String,
    Integer,
    DateTime,
    CheckConstraint,
    PrimaryKeyConstraint,
    ForeignKeyConstraint,
    text
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from typing import Optional
import datetime
import uuid

class Base(DeclarativeBase):
    pass

class TransactionMaster(Base):
    __tablename__ = 'transaction_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    transaction_code: Mapped[str] = mapped_column(String(50), primary_key=True)
    transaction_desc: Mapped[str] = mapped_column(String(100))

    __table_args__ = (
        PrimaryKeyConstraint('transaction_code', name='txn_master_pkey')
    )

class BranchMaster(Base):
    __tablename__ = 'branch_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    branch_name: Mapped[str] = mapped_column(String(50))
    branch_type: Mapped[str] = mapped_column(String(200))

    __table_args__ = (
        PrimaryKeyConstraint('branch_id', name='branch_master_pkey')
    )

class SessionMaster(Base):
    __tablename__ = 'session_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    session_id: Mapped[uuid.UUID] = mapped_column(UUID, server_default=text('gen_random_uuid()'), primary_key=True)
    customer_rep: Mapped[Optional[str]] = mapped_column(String(1))
    authentication_method: Mapped[Optional[str]] = mapped_column(String(20))
    cif: Mapped[str] = mapped_column(String(50))
    account_no: Mapped[Optional[dict]] = mapped_column(JSONB)
    session_start: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    session_end: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    userid: Mapped[int] = mapped_column(Integer)
    provider_name: Mapped[str] = mapped_column(String(100))
    username: Mapped[str] = mapped_column(String(100))
    id_type: Mapped[str] = mapped_column(String(20))
    id_no: Mapped[str] = mapped_column(String(50))
    first_name: Mapped[str] = mapped_column(String(50))
    last_name: Mapped[str] = mapped_column(String(50))
    dob: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=False))
    gender: Mapped[Optional[str]] = mapped_column(String(1))

    __table_args__ = (
        PrimaryKeyConstraint('session_id', name='session_master_pkey'),
        CheckConstraint("customer_rep::text = ANY (ARRAY['Card'::character varying, 'R'::character varying]::text[])",
                        name='customer_rep_check'),
        CheckConstraint("authentication_method::text = ANY (ARRAY['Card'::text, 'CIF'::text, 'Account number'::text, 'NID'::text, 'Passport'::text, 'DL'::text]::text[])",
                        name='authentication_method_check') ,
        CheckConstraint("gender::text = ANY (ARRAY['M'::character varying, 'F'::character varying, 'O'::character varying]::text[])",
                        name='gender_check')
    )

class CurrencyMaster(Base):
    __tablename__ = 'currency_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    currency_code: Mapped[str] = mapped_column(String(10), primary_key=True)
    currency_name: Mapped[str] = mapped_column(String(100))

    __table_args__ = (
        PrimaryKeyConstraint('currency_code', name='currency_master_pkey')
    )

class DenominationMaster(Base):
    __tablename__ = 'denomination_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    currency_code: Mapped[str] = mapped_column(String(10))
    denomination_code: Mapped[str] = mapped_column(primary_key=True)
    denomination_label: Mapped[str] = mapped_column(String(100))
    denomination_value: Mapped[int] = mapped_column(Integer)

    __table_args__ = (
        PrimaryKeyConstraint('denomination_code', name='denomination_master_pkey'),
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                             name='denom_master_fk_ccy_code')
    )

class Transactions(Base):
    __tablename__ = 'transactions'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    transaction_id: Mapped[str] = mapped_column(String(50), primary_key=True)
    transaction_code: Mapped[str] = mapped_column(String(50))
    transaction_status: Mapped[Optional[str]] = mapped_column(String(1))
    auth_status: Mapped[Optional[str]] = mapped_column(String(1))
    session_id: Mapped[uuid.UUID] = mapped_column(UUID)
    created_by: Mapped[str] = mapped_column(String(50))
    created_by_user_id: Mapped[int] = mapped_column(Integer)
    created_by_provider: Mapped[str] = mapped_column(String(50))
    create_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    last_updated_user: Mapped[str] = mapped_column(String(50))
    last_updated_user_id: Mapped[int] = mapped_column(Integer)
    last_updated_user_provider: Mapped[str] = mapped_column(String(50))
    last_updated_timestamp: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    comments: Mapped[Optional[str]] = mapped_column(String(1))
    callback_done: Mapped[Optional[str]] = mapped_column(String(1))
    data_table: Mapped[Optional[dict]] = mapped_column(JSONB)

    __table_args__ = (
        PrimaryKeyConstraint('transaction_id', name='transactions_pkey'),
        CheckConstraint("transaction_status::text = ANY (ARRAY['D'::character varying, 'I'::character varying, 'B'::character varying, 'S'::character varying, 'F'::character varying, 'R'::character varying]::text[])",
                        name='transaction_status_check'),
        CheckConstraint("auth_status::text = ANY (ARRAY['A'::character varying, 'U'::character varying, 'R'::character varying]::text[])",
                        name='auth_status_check'),
        CheckConstraint("comments::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='comments_check'),
        CheckConstraint("callback_done::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='callback_done_check'),
        ForeignKeyConstraint(['transaction_code'], ['transaction_master.transaction_code'],
                        name='txns_fk_transaction_code'),
        ForeignKeyConstraint(['session_id'], ['session_master.session_id'],
                        name='txns_fk_session_id')
    )

class FinancialTransactions(Base):
    __tablename__ = 'financial_transactions'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    transaction_id: Mapped[str] = mapped_column(String(50), primary_key=True)
    session_id: Mapped[uuid.UUID] = mapped_column(UUID)
    denom_tracking: Mapped[Optional[str]] = mapped_column(String(1))
    from_account: Mapped[str] = mapped_column(String(50))
    to_account: Mapped[str] = mapped_column(String(50))
    from_currency: Mapped[str] = mapped_column(String(50))
    to_currency: Mapped[str] = mapped_column(String(50))
    from_amount: Mapped[int] = mapped_column(Integer)
    to_amount: Mapped[int] = mapped_column(Integer)
    source_of_funds: Mapped[str] = mapped_column(String(100))
    purpose: Mapped[str] = mapped_column(String(200))
    remarks1: Mapped[str] = mapped_column(String(200))
    remarks2: Mapped[str] = mapped_column(String(200))
    exchange_rate_type: Mapped[str] = mapped_column(String(50))
    exchange_rate: Mapped[str] = mapped_column(String(50))
    special_rate: Mapped[Optional[str]] = mapped_column(String(1))
    treasury_remarks: Mapped[str] = mapped_column(String(200))
    treasury_approved: Mapped[Optional[str]] = mapped_column(String(1))
    treasury_approved_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    instrument_type: Mapped[str] = mapped_column(String(50))
    instrument_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    instrument_number: Mapped[str] = mapped_column(String(50))
    value_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
    
    __table_args__ = (
        PrimaryKeyConstraint('transaction_id', name='financial_transactions_pkey'),
        CheckConstraint("denom_tracking::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='denom_tracking_check'),
        CheckConstraint("special_rate::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='special_rate_check'),
        CheckConstraint("treasury_approved::text = ANY (ARRAY['Y'::character varying, 'N'::character varying]::text[])",
                        name='treasury_approved_check'),
        ForeignKeyConstraint(['transaction_id'], ['transactions.transaction_id'],
                        name='fintxns_fk_transaction_id'),
        ForeignKeyConstraint(['session_id'], ['session_master.session_id'],
                        name='fintxns_fk_session_id')
    )


class Comments(Base):
    __tablename__ = 'comments'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    session_id: Mapped[uuid.UUID] = mapped_column(UUID)
    transaction_id: Mapped[str] = mapped_column(String(50))
    sequence_number: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_provider: Mapped[str] = mapped_column(String(100))
    username: Mapped[str] = mapped_column(String(100))
    userid: Mapped[int] = mapped_column(Integer)
    comments: Mapped[str] = mapped_column(String(200))
    comments_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))

    __table_args__ = (
        PrimaryKeyConstraint('sequence_number', name='comments_pkey'),
        ForeignKeyConstraint(['transaction_id'], ['transactions.transaction_id'],
                        name='comments_fk_transaction_id'),
        ForeignKeyConstraint(['session_id'], ['session_master.session_id'],
                        name='comments_fk_session_id')
    )

class TillMaster(Base):
    __tablename__ = 'till_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    till_id: Mapped[int] = mapped_column(Integer)
    till_status: Mapped[Optional[str]] = mapped_column(String(1))
    till_type: Mapped[Optional[str]] = mapped_column(String(20))
    currency_code: Mapped[str] = mapped_column(String(10))
    denominations: Mapped[Optional[dict]] = mapped_column(JSONB)
    amount: Mapped[int] = mapped_column(Integer)

    __table_args__ = (
        PrimaryKeyConstraint(['tenant', 'branch_id', 'till_id', 'currency_code'], name='till_master_pkey'),
        CheckConstraint("till_type::text = ANY (ARRAY['Till'::text, 'vault'::text, 'chief teller'::text, 'cash center'::text]::text[])",
                        name='till_type_check') ,
        CheckConstraint("till_status::text = ANY (ARRAY['O'::character varying, 'C'::character varying]::text[])",
                        name='till_status_check'),
        ForeignKeyConstraint(['currency_code'], ['currency_master.currency_code'],
                        name='till_master_fk_currency_code')
    )

class UserTillMaster(Base):
    __tablename__ = 'user_till_master'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    user_provider: Mapped[str] = mapped_column(String(50))
    username: Mapped[str] = mapped_column(String(50))
    userid: Mapped[int] = mapped_column(Integer)
    till_id: Mapped[int] = mapped_column(Integer)
    aprover_provider: Mapped[str] = mapped_column(String(50))
    aprover_id: Mapped[int] = mapped_column(Integer)
    aprover_name: Mapped[str] = mapped_column(String(50))

    __table_args__ = (
        PrimaryKeyConstraint(['tenant', 'branch_id', 'userid'], name='user_till_master_pkey')
    )


class TransactionDenomination(Base):
    __tablename__ = 'transaction_denomination'
    tenant: Mapped[str] = mapped_column(String(100))
    branch_id: Mapped[int] = mapped_column(Integer)
    till_id: Mapped[int] = mapped_column(Integer)
    transaction_id: Mapped[str] = mapped_column(String(50), primary_key=True)
    currency_code: Mapped[str] = mapped_column(String(10))
    related_account: Mapped[str] = mapped_column(String(100))
    amount: Mapped[int] = mapped_column(Integer)
    denominations: Mapped[Optional[dict]] = mapped_column(JSONB)

    __table_args__ = (
        PrimaryKeyConstraint(['tenant', 'branch_id', 'transaction_id'], name='transaction_denomination_pkey'),
        ForeignKeyConstraint(['transaction_id'], ['transactions.transaction_id'],
                        name='transaction_denomination_fk_transaction_id'),
        ForeignKeyConstraint(['tenant', 'branch_id', 'till_id', 'currency_code'], ['till_master.tenant', 'till_master.branch_id', 'till_master.till_id', 'till_master.currency_code'],
                        name='transaction_denomination_fk_composite')
    )

# class AuditLogTxns(Base):
#     __tablename__ = 'audit_log_txns'
#     tenant: Mapped[str] = mapped_column(String(100))
#     branch_id: Mapped[int] = mapped_column(Integer)
#     till_id: Mapped[int] = mapped_column(Integer)
#     audit_id: Mapped[int] = mapped_column(Integer, primary_key=True)
#     transaction_id: Mapped[str] = mapped_column(String(50))
#     currency_code: Mapped[str] = mapped_column(String(10))
#     amount: Mapped[int] = mapped_column(Integer)
#     updated_denominations: Mapped[Optional[dict]] = mapped_column(JSONB)
#     update_date: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))
#     userid: Mapped[int] = mapped_column(Integer)
#     username: Mapped[str] = mapped_column(String(100))

#     __table_args__ = (
#         PrimaryKeyConstraint('audit_id', name='audit_log_txns_pkey'),
#         ForeignKeyConstraint(['transaction_id'], ['transactions.transaction_id'],
#                         name='audit_log_fk_transaction_id')
#     )